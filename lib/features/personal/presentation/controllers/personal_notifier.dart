import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../../../../core/enums.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/personal_element_with_items.dart';
import '../../domain/repositories/ipersonal_repository.dart';

class PersonalNotifier extends ChangeNotifier {
  final IPersonalRepository _repository;

  List<ElementoPersonalConItems> _elementos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TipoElementoPersonal? _filterTipo;

  PersonalNotifier(this._repository) {
    _escucharElementos();
  }

  List<ElementoPersonalConItems> get elementos => _elementos;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TipoElementoPersonal? get filterTipo => _filterTipo;

  // Búsqueda global y filtrado
  List<ElementoPersonalConItems> get elementosFiltrados {
    return _elementos.where((item) {
      // 1. Filtro por tipo/pestaña
      if (_filterTipo != null && item.elemento.tipo != _filterTipo) {
        return false;
      }

      // 2. Filtro por búsqueda global (título, contenido, categoría e ítems de lista)
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitulo = item.elemento.titulo.toLowerCase().contains(query);
        final matchContenido = (item.elemento.contenido ?? '').toLowerCase().contains(query);
        final matchCategoria = item.elemento.categoria.toLowerCase().contains(query);
        final matchItems = item.items.any((i) => i.texto.toLowerCase().contains(query));

        return matchTitulo || matchContenido || matchCategoria || matchItems;
      }

      return true;
    }).toList();
  }

  void _escucharElementos() {
    _isLoading = true;
    notifyListeners();

    _repository.watchElementos().listen((data) {
      _elementos = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterTipo(TipoElementoPersonal? tipo) {
    _filterTipo = tipo;
    notifyListeners();
  }

  Future<int> guardarNotaODato({
    required String titulo,
    required String? contenido,
    required String categoria,
    required Prioridad prioridad,
  }) async {
    final now = DateTime.now();
    final companion = ElementosPersonalesCompanion.insert(
      titulo: titulo,
      contenido: Value(contenido),
      tipo: TipoElementoPersonal.nota,
      categoria: Value(categoria.isEmpty ? 'General' : categoria),
      prioridad: Value(prioridad),
      fechaCreacion: now,
      fechaActualizacion: now,
    );
    return await _repository.guardarElemento(companion);
  }

  Future<void> guardarLista({
    int? idExistente,
    required String titulo,
    required String categoria,
    required Prioridad prioridad,
    required List<String> itemsText,
  }) async {
    final now = DateTime.now();
    int elementoId;

    if (idExistente != null) {
      final companion = ElementosPersonalesCompanion(
        id: Value(idExistente),
        titulo: Value(titulo),
        categoria: Value(categoria.isEmpty ? 'General' : categoria),
        prioridad: Value(prioridad),
        tipo: const Value(TipoElementoPersonal.lista),
        fechaActualizacion: Value(now),
      );
      await _repository.actualizarElemento(companion);
      elementoId = idExistente;
    } else {
      final companion = ElementosPersonalesCompanion.insert(
        titulo: titulo,
        tipo: TipoElementoPersonal.lista,
        categoria: Value(categoria.isEmpty ? 'General' : categoria),
        prioridad: Value(prioridad),
        fechaCreacion: now,
        fechaActualizacion: now,
      );
      elementoId = await _repository.guardarElemento(companion);
    }

    await _repository.guardarItemsLista(elementoId, itemsText);
  }

  Future<int> guardarMeta({
    required String titulo,
    required String? descripcion,
    required String categoria,
    required Prioridad prioridad,
    required int progresoTotal,
    required DateTime? fechaObjetivo,
  }) async {
    final now = DateTime.now();
    final companion = ElementosPersonalesCompanion.insert(
      titulo: titulo,
      contenido: Value(descripcion),
      tipo: TipoElementoPersonal.meta,
      categoria: Value(categoria.isEmpty ? 'General' : categoria),
      prioridad: Value(prioridad),
      progresoActual: const Value(0),
      progresoTotal: Value(progresoTotal < 1 ? 1 : progresoTotal),
      fechaObjetivo: Value(fechaObjetivo),
      fechaCreacion: now,
      fechaActualizacion: now,
    );
    return await _repository.guardarElemento(companion);
  }

  Future<void> toggleFijado(ElementoPersonal elemento) async {
    await _repository.toggleFijado(elemento.id, elemento.esFijado);
  }

  Future<void> toggleItemLista(int itemId, bool completado) async {
    await _repository.toggleItemLista(itemId, completado);
  }

  Future<void> incrementarProgresoMeta(ElementoPersonal meta) async {
    final actual = meta.progresoActual ?? 0;
    final total = meta.progresoTotal ?? 1;
    if (actual < total) {
      await _repository.actualizarProgresoMeta(meta.id, actual + 1);
    }
  }

  Future<void> decrementarProgresoMeta(ElementoPersonal meta) async {
    final actual = meta.progresoActual ?? 0;
    if (actual > 0) {
      await _repository.actualizarProgresoMeta(meta.id, actual - 1);
    }
  }

  Future<void> eliminarElemento(int id) async {
    await _repository.eliminarElemento(id);
  }
}
