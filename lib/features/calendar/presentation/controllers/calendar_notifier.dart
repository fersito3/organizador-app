import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/icalendar_repository.dart';

class CalendarNotifier extends ChangeNotifier {
  final ICalendarRepository _calendarRepository;

  List<Evento> _eventos = [];
  List<Evento> get eventos => _eventos;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  DateTime _focusedMonth = DateTime.now();
  DateTime get focusedMonth => _focusedMonth;

  StreamSubscription<List<Evento>>? _subscription;

  CalendarNotifier(this._calendarRepository) {
    _subscribeToEventos();
  }

  void _subscribeToEventos() {
    _subscription = _calendarRepository.watchEventos().listen(
      (list) {
        _eventos = list;
        notifyListeners();
      },
    );
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void changeMonth(DateTime month) {
    _focusedMonth = month;
    notifyListeners();
  }

  List<Evento> get eventosDelDia {
    return _eventos.where((e) {
      final inicio = e.fechaInicio;
      final dateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final inicioOnly = DateTime(inicio.year, inicio.month, inicio.day);
      
      if (dateOnly.isBefore(inicioOnly)) return false;
      
      if (e.esRecurrente && e.patronRecurrencia == 'WEEKLY') {
        return dateOnly.weekday == inicioOnly.weekday;
      }
      
      final fin = e.fechaFin;
      final finOnly = DateTime(fin.year, fin.month, fin.day);
      return !dateOnly.isAfter(finOnly);
    }).toList();
  }

  Future<int> guardarEvento(EventosCompanion companion) async {
    final id = await _calendarRepository.guardarEvento(companion);
    return id;
  }

  Future<void> eliminarEvento(int id) async {
    await _calendarRepository.eliminarEvento(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
