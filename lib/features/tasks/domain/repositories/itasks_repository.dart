import '../../../../core/database/app_database.dart';

abstract class ITasksRepository {
  Stream<List<Tarea>> watchTareas();
  Future<List<Tarea>> obtenerTareas();
  Future<int> guardarTarea(TareasCompanion companion);
  Future<void> eliminarTarea(int id);
}
