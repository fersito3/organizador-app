import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/icalendar_repository.dart';

class CalendarRepository implements ICalendarRepository {
  final AppDatabase db;

  CalendarRepository(this.db);

  @override
  Stream<List<Evento>> watchEventos() {
    return (db.select(db.eventos)
          ..orderBy([(e) => OrderingTerm.asc(e.fechaInicio)]))
        .watch();
  }

  @override
  Future<List<Evento>> obtenerEventos() {
    return (db.select(db.eventos)
          ..orderBy([(e) => OrderingTerm.asc(e.fechaInicio)]))
        .get();
  }

  @override
  Future<int> guardarEvento(EventosCompanion companion) {
    if (companion.id.present) {
      return (db.update(db.eventos)
            ..where((e) => e.id.equals(companion.id.value)))
          .write(companion)
          .then((_) => companion.id.value);
    } else {
      return db.into(db.eventos).insert(companion);
    }
  }

  @override
  Future<void> eliminarEvento(int id) {
    return (db.delete(db.eventos)..where((e) => e.id.equals(id))).go().then((_) => {});
  }
}
