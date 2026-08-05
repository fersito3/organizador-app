import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/itasks_repository.dart';

class TasksRepository implements ITasksRepository {
  final AppDatabase db;

  TasksRepository(this.db);

  @override
  Stream<List<Tarea>> watchTareas() {
    return (db.select(db.tareas)
          ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
        .watch();
  }

  @override
  Future<List<Tarea>> obtenerTareas() {
    return (db.select(db.tareas)
          ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
        .get();
  }

  @override
  Future<int> guardarTarea(TareasCompanion companion) {
    if (companion.id.present) {
      return (db.update(db.tareas)
            ..where((t) => t.id.equals(companion.id.value)))
          .write(companion)
          .then((_) => companion.id.value);
    } else {
      return db.into(db.tareas).insert(companion);
    }
  }

  @override
  Future<void> eliminarTarea(int id) {
    return (db.delete(db.tareas)..where((t) => t.id.equals(id))).go().then((_) => {});
  }
}
