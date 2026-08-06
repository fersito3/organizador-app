import '../../../../core/database/app_database.dart';
import '../models/personal_element_with_items.dart';

abstract class IPersonalRepository {
  Stream<List<ElementoPersonalConItems>> watchElementos();
  Future<List<ElementoPersonalConItems>> getElementos();
  Future<int> guardarElemento(ElementosPersonalesCompanion companion);
  Future<void> actualizarElemento(ElementosPersonalesCompanion companion);
  Future<void> eliminarElemento(int id);
  Future<void> toggleFijado(int id, bool esFijadoActual);
  
  // Operaciones de Ítems de Lista (1:N)
  Future<void> agregarItemLista(ItemsListaCompanion item);
  Future<void> toggleItemLista(int itemId, bool completado);
  Future<void> eliminarItemLista(int itemId);
  Future<void> guardarItemsLista(int elementoId, List<String> textosItems);

  // Metas (Objetivos)
  Future<void> actualizarProgresoMeta(int id, int nuevoProgreso);
}
