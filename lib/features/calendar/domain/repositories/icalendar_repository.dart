import '../../../../core/database/app_database.dart';

abstract class ICalendarRepository {
  Stream<List<Evento>> watchEventos();
  Future<List<Evento>> obtenerEventos();
  Future<int> guardarEvento(EventosCompanion companion);
  Future<void> eliminarEvento(int id);
}
