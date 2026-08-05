import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/enums.dart';
import '../../domain/models/categoria_domain.dart';
import '../../domain/models/transaccion.dart';
import '../../domain/repository_interfaces/iexpenses_repository.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/models/conocido.dart';

class ExpensesNotifier extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final IExpensesRepository _expensesRepository;

  List<Conocido> _conocidos = [];
  List<Conocido> get conocidos => _conocidos;

  // URL del backend en Render (se puede cambiar por localhost:3000 para pruebas locales)
  static const String backendUrl = 'https://organizador-app-server.onrender.com';

  List<Transaccion> _transacciones = [];
  List<Transaccion> get transacciones => _transacciones;

  List<CategoriaDomain> _categorias = [];
  List<CategoriaDomain> get categorias => _categorias;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Estados de Sincronización
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String? _syncErrorMessage;
  String? get syncErrorMessage => _syncErrorMessage;

  // Estados de Filtro
  TipoTransaccion? _filtroTipo;
  TipoTransaccion? get filtroTipo => _filtroTipo;

  String _filtroBusqueda = '';
  String get filtroBusqueda => _filtroBusqueda;

  StreamSubscription<List<Transaccion>>? _subscription;

  ExpensesNotifier(
    this._getTransactionsUseCase,
    this._getCategoriesUseCase,
    this._expensesRepository,
  ) {
    _loadCategorias();
    cargarConocidos();
    _subscribeToTransactions();
    sincronizarMercadoPago();
  }

  // Carga inicial de categorías de forma asíncrona
  Future<void> _loadCategorias() async {
    try {
      _categorias = await _getCategoriesUseCase.execute();
      notifyListeners();
    } catch (_) {
      // Ignorar o registrar error en desarrollo
    }
  }

  // Buscar categoría por ID
  CategoriaDomain? findCategoriaById(int id) {
    try {
      return _categorias.firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }

  // Buscar conocido por ID
  Conocido? findConocidoById(int? id) {
    if (id == null) return null;
    try {
      return _conocidos.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Sincronizar transacciones desde el servidor Render (con control de estado y mayor timeout)
  Future<void> sincronizarMercadoPago() async {
    if (_isSyncing) return; // Evitar peticiones paralelas
    
    _isSyncing = true;
    _syncErrorMessage = null;
    notifyListeners();

    try {
      // 1. Obtener la transacción más reciente de MP cargada localmente para filtrar la fecha de inicio
      final transaccionesMp = _transacciones
          .where((t) => t.proveedor == 'MP' && t.mpPaymentId != null)
          .toList();
      
      String? beginDate;
      if (transaccionesMp.isNotEmpty) {
        final masReciente = transaccionesMp
            .map((t) => t.fecha)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        beginDate = masReciente.toUtc().toIso8601String();
      }

      // 2. Configurar la URL
      var url = Uri.parse('$backendUrl/api/mercadopago/transactions');
      if (beginDate != null) {
        url = url.replace(queryParameters: {'begin_date': beginDate});
      }

      debugPrint('Iniciando sincronización con Mercado Pago. URL: $url');

      // 3. Realizar la petición HTTP con timeout de 60 segundos (permite despertar a Render si está suspendido)
      final response = await http.get(url).timeout(const Duration(seconds: 60));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> transactionsJson = data['transactions'] ?? [];
        
        if (transactionsJson.isNotEmpty) {
          final transaccionesNuevas = transactionsJson.map<Transaccion>((tx) {
            return Transaccion(
              id: 0, // Autoincremental
              descripcion: tx['descripcion'] ?? '',
              monto: (tx['monto'] as num).toDouble(),
              fecha: DateTime.parse(tx['fecha']),
              tipo: tx['tipo'] == 'ingreso' ? TipoTransaccion.ingreso : TipoTransaccion.egreso,
              categoriaId: 0, // Categorizado automáticamente por el repo
              destinatarioEmisor: tx['destinatarioEmisor'],
              mpPaymentId: tx['mpPaymentId'],
              proveedor: 'MP',
            );
          }).toList();

          // 4. Guardar en SQLite (la UI se actualizará automáticamente por el Stream)
          await _expensesRepository.guardarTransaccionesSincronizadas(transaccionesNuevas);
          debugPrint('Sincronizados ${transaccionesNuevas.length} nuevos pagos de Mercado Pago.');
        } else {
          debugPrint('Sincronización al día. No hay nuevas transacciones.');
        }
        _syncErrorMessage = null;
      } else {
        _syncErrorMessage = 'Fallo de servidor (HTTP ${response.statusCode})';
        debugPrint('Fallo al sincronizar con Mercado Pago: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _syncErrorMessage = 'No se pudo conectar al servidor';
      debugPrint('Error de red al sincronizar con Mercado Pago: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Getters para cálculos del resumen financiero global (usados por el Dashboard)
  double get totalIngresos => _transacciones
      .where((t) => t.tipo == TipoTransaccion.ingreso)
      .fold(0.0, (sum, t) => sum + t.monto);

  double get totalEgresos => _transacciones
      .where((t) => t.tipo == TipoTransaccion.egreso)
      .fold(0.0, (sum, t) => sum + t.monto);

  double get balance => totalIngresos - totalEgresos;

  // Lógica de Filtrado Interactivo
  List<Transaccion> get transaccionesFiltradas {
    return _transacciones.where((t) {
      if (_filtroTipo != null && t.tipo != _filtroTipo) {
        return false;
      }
      if (_filtroBusqueda.isNotEmpty) {
        final query = _filtroBusqueda.toLowerCase();
        final coincideDesc = t.descripcion.toLowerCase().contains(query);
        final coincideEntidad = t.destinatarioEmisor?.toLowerCase().contains(query) ?? false;
        
        final cat = findCategoriaById(t.categoriaId);
        final coincideCat = cat?.nombre.toLowerCase().contains(query) ?? false;
        
        return coincideDesc || coincideEntidad || coincideCat;
      }
      return true;
    }).toList();
  }

  // Getters para cálculos filtrados interactivos (usados por la sección de Finanzas)
  double get totalIngresosFiltrados => transaccionesFiltradas
      .where((t) => t.tipo == TipoTransaccion.ingreso)
      .fold(0.0, (sum, t) => sum + t.monto);

  double get totalEgresosFiltrados => transaccionesFiltradas
      .where((t) => t.tipo == TipoTransaccion.egreso)
      .fold(0.0, (sum, t) => sum + t.monto);

  double get balanceFiltrado => totalIngresosFiltrados - totalEgresosFiltrados;

  // Métodos para cambiar los filtros
  void setFiltroTipo(TipoTransaccion? tipo) {
    _filtroTipo = tipo;
    notifyListeners();
  }

  void setFiltroBusqueda(String busqueda) {
    _filtroBusqueda = busqueda;
    notifyListeners();
  }

  void _subscribeToTransactions() {
    _subscription = _getTransactionsUseCase.execute().listen(
      (list) {
        _transacciones = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> eliminarTransaccion(int id) async {
    await _expensesRepository.eliminarTransaccion(id);
  }

  Future<void> actualizarTransaccion(int id, String descripcion, int categoriaId, {int? conocidoId}) async {
    await _expensesRepository.actualizarTransaccion(id, descripcion, categoriaId, conocidoId: conocidoId);
  }

  Future<void> asociarConocidoATransaccion(int transaccionId, int conocidoId) async {
    await _expensesRepository.asociarConocidoATransaccion(transaccionId, conocidoId);
    await cargarConocidos();
  }

  // --- MÉTODOS DE CONOCIDOS ---
  Future<void> cargarConocidos() async {
    try {
      _conocidos = await _expensesRepository.obtenerConocidos();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar conocidos: $e');
    }
  }

  Future<int> guardarConocido({
    required String nombre,
    required String apellido,
    String? mpUserId,
  }) async {
    final id = await _expensesRepository.guardarConocido(
      nombre: nombre,
      apellido: apellido,
      mpUserId: mpUserId,
    );
    await cargarConocidos();
    return id;
  }

  Future<void> eliminarConocido(int conocidoId) async {
    await _expensesRepository.eliminarConocido(conocidoId);
    await cargarConocidos();
  }

  Future<void> asociarTransaccionesConConocido({
    required String mpUserId,
    required int conocidoId,
    required String nombreCompleto,
  }) async {
    await _expensesRepository.asociarTransaccionesConConocido(
      mpUserId: mpUserId,
      conocidoId: conocidoId,
      nombreCompleto: nombreCompleto,
    );
    await cargarConocidos();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

