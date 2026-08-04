import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/enums.dart';
import '../../domain/models/categoria_domain.dart';
import '../../domain/models/transaccion.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';

class ExpensesNotifier extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  List<Transaccion> _transacciones = [];
  List<Transaccion> get transacciones => _transacciones;

  List<CategoriaDomain> _categorias = [];
  List<CategoriaDomain> get categorias => _categorias;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Estados de Filtro
  TipoTransaccion? _filtroTipo;
  TipoTransaccion? get filtroTipo => _filtroTipo;

  String _filtroBusqueda = '';
  String get filtroBusqueda => _filtroBusqueda;

  StreamSubscription<List<Transaccion>>? _subscription;

  ExpensesNotifier(
    this._getTransactionsUseCase,
    this._getCategoriesUseCase,
  ) {
    _loadCategorias();
    _subscribeToTransactions();
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
        return coincideDesc || coincideEntidad;
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

