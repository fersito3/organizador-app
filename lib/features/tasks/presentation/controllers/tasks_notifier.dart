import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums.dart';
import '../../domain/repositories/itasks_repository.dart';

class TasksNotifier extends ChangeNotifier {
  final ITasksRepository _tasksRepository;

  List<Tarea> _tareas = [];
  List<Tarea> get tareas => _tareas;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  TipoTarea? _filtroTipo;
  TipoTarea? get filtroTipo => _filtroTipo;

  int _filtroEstado = 0; // 0 = Todas, 1 = Pendientes, 2 = Completadas
  int get filtroEstado => _filtroEstado;

  StreamSubscription<List<Tarea>>? _subscription;

  TasksNotifier(this._tasksRepository) {
    _subscribeToTareas();
  }

  void _subscribeToTareas() {
    _subscription = _tasksRepository.watchTareas().listen((list) {
      _tareas = list;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFiltroTipo(TipoTarea? tipo) {
    _filtroTipo = tipo;
    notifyListeners();
  }

  void setFiltroEstado(int estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  List<Tarea> get tareasFiltradas {
    return _tareas.where((t) {
      if (_filtroEstado == 1 && t.completada) return false;
      if (_filtroEstado == 2 && !t.completada) return false;

      if (_filtroTipo != null && t.tipo != _filtroTipo) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitulo = t.titulo.toLowerCase().contains(query);
        
        String descText = t.descripcion ?? '';
        if (t.tipo == TipoTarea.deudas) {
          descText = '${obtenerAmigoDeuda(t)} ${obtenerDescripcionLimpiaDeuda(t)}';
        }
        final matchDesc = descText.toLowerCase().contains(query);

        return matchTitulo || matchDesc;
      }

      return true;
    }).toList();
  }

  Future<int> guardarTarea(TareasCompanion companion) async {
    return await _tasksRepository.guardarTarea(companion);
  }

  Future<void> toggleCompletada(Tarea tarea) async {
    await _tasksRepository.guardarTarea(
      TareasCompanion(
        id: Value(tarea.id),
        completada: Value(!tarea.completada),
      ),
    );
  }

  Future<void> eliminarTarea(int id) async {
    await _tasksRepository.eliminarTarea(id);
  }

  // --- PARSEO DE DEUDAS (monto:3500|amigo:Juan|detalles:Pizza) ---
  double obtenerMontoDeuda(Tarea tarea) {
    if (tarea.tipo != TipoTarea.deudas || tarea.descripcion == null) return 0.0;
    final parts = tarea.descripcion!.split('|');
    for (final part in parts) {
      if (part.startsWith('monto:')) {
        return double.tryParse(part.substring(6)) ?? 0.0;
      }
    }
    return 0.0;
  }

  String obtenerAmigoDeuda(Tarea tarea) {
    if (tarea.tipo != TipoTarea.deudas || tarea.descripcion == null) return '';
    final parts = tarea.descripcion!.split('|');
    for (final part in parts) {
      if (part.startsWith('amigo:')) {
        return part.substring(6);
      }
    }
    return '';
  }

  String obtenerDescripcionLimpiaDeuda(Tarea tarea) {
    if (tarea.tipo != TipoTarea.deudas || tarea.descripcion == null) return '';
    final parts = tarea.descripcion!.split('|');
    for (final part in parts) {
      if (part.startsWith('detalles:')) {
        return part.substring(9);
      }
    }
    return tarea.descripcion!;
  }

  static String formatearDescripcionDeuda(double monto, String amigo, String detalles) {
    return 'monto:$monto|amigo:$amigo|detalles:$detalles';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
