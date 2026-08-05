import 'package:flutter/material.dart';
import '../../../../core/enums.dart';
import '../../domain/models/categoria_domain.dart';
import '../../domain/models/conocido.dart';
import '../../domain/repository_interfaces/iexpenses_repository.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';

class AddTransactionNotifier extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final AddTransactionUseCase _addTransactionUseCase;
  final IExpensesRepository _expensesRepository;

  List<CategoriaDomain> _allCategories = [];
  List<CategoriaDomain> _filteredCategories = [];
  List<CategoriaDomain> get filteredCategories => _filteredCategories;

  List<Conocido> _conocidos = [];
  List<Conocido> get conocidos => _conocidos;

  int? _conocidoIdSeleccionado;
  int? get conocidoIdSeleccionado => _conocidoIdSeleccionado;

  bool _isLoadingCategories = true;
  bool get isLoadingCategories => _isLoadingCategories;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  TipoTransaccion _tipoSeleccionado = TipoTransaccion.egreso;
  TipoTransaccion get tipoSeleccionado => _tipoSeleccionado;

  int? _categoriaIdSeleccionada;
  int? get categoriaIdSeleccionada => _categoriaIdSeleccionada;

  DateTime _fechaSeleccionada = DateTime.now();
  DateTime get fechaSeleccionada => _fechaSeleccionada;

  AddTransactionNotifier(
    this._getCategoriesUseCase,
    this._addTransactionUseCase,
    this._expensesRepository,
  ) {
    loadCategories();
    loadConocidos();
  }

  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _allCategories = await _getCategoriesUseCase.execute();
      _updateFilteredCategories();
    } catch (_) {
      // Manejar error en UI
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadConocidos() async {
    try {
      _conocidos = await _expensesRepository.obtenerConocidos();
      notifyListeners();
    } catch (_) {}
  }

  void selectConocido(int? id) {
    _conocidoIdSeleccionado = id;
    notifyListeners();
  }

  void selectTipo(TipoTransaccion tipo) {
    _tipoSeleccionado = tipo;
    _updateFilteredCategories();
    notifyListeners();
  }

  void selectCategoria(int? id) {
    _categoriaIdSeleccionada = id;
    notifyListeners();
  }

  void selectFecha(DateTime fecha) {
    _fechaSeleccionada = fecha;
    notifyListeners();
  }

  void _updateFilteredCategories() {
    _filteredCategories = _allCategories
        .where((cat) => cat.tipo == _tipoSeleccionado)
        .toList();

    if (_categoriaIdSeleccionada != null &&
        !_filteredCategories.any((cat) => cat.id == _categoriaIdSeleccionada)) {
      _categoriaIdSeleccionada = null;
    }

    if (_categoriaIdSeleccionada == null && _filteredCategories.isNotEmpty) {
      _categoriaIdSeleccionada = _filteredCategories.first.id;
    }
  }

  Future<void> save({
    required String descripcion,
    required double monto,
    String? destinatarioEmisor,
  }) async {
    if (_categoriaIdSeleccionada == null) {
      throw Exception('Por favor selecciona una categoría');
    }

    _isSaving = true;
    notifyListeners();

    try {
      String? finalDestinatario = destinatarioEmisor;
      String? finalContraparteMpId;
      if (_conocidoIdSeleccionado != null) {
        final seleccionado = _conocidos.firstWhere((c) => c.id == _conocidoIdSeleccionado);
        finalDestinatario = seleccionado.nombreCompleto;
        finalContraparteMpId = seleccionado.mpUserId;
      }

      await _addTransactionUseCase.execute(
        descripcion: descripcion,
        monto: monto,
        fecha: _fechaSeleccionada,
        tipo: _tipoSeleccionado,
        categoriaId: _categoriaIdSeleccionada!,
        destinatarioEmisor: finalDestinatario,
        conocidoId: _conocidoIdSeleccionado,
        contraparteMpId: finalContraparteMpId,
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
