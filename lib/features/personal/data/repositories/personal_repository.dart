import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/personal_element_with_items.dart';
import '../../domain/repositories/ipersonal_repository.dart';

class PersonalRepository implements IPersonalRepository {
  final AppDatabase _db;

  PersonalRepository(this._db);

  @override
  Stream<List<ElementoPersonalConItems>> watchElementos() {
    final query = _db.select(_db.elementosPersonales)
      ..orderBy([
        (t) => OrderingTerm(expression: t.esFijado, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.prioridad, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.fechaActualizacion, mode: OrderingMode.desc),
      ]);

    return query.watch().asyncMap((elementos) async {
      if (elementos.isEmpty) return [];

      final allItems = await (_db.select(_db.itemsLista)
            ..orderBy([(i) => OrderingTerm(expression: i.orden)]))
          .get();

      final Map<int, List<ItemListaData>> itemsByElementId = {};
      for (final item in allItems) {
        itemsByElementId.putIfAbsent(item.elementoId, () => []).add(item);
      }

      return elementos.map((el) {
        return ElementoPersonalConItems(
          elemento: el,
          items: itemsByElementId[el.id] ?? const [],
        );
      }).toList();
    });
  }

  @override
  Future<List<ElementoPersonalConItems>> getElementos() async {
    final query = _db.select(_db.elementosPersonales)
      ..orderBy([
        (t) => OrderingTerm(expression: t.esFijado, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.prioridad, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.fechaActualizacion, mode: OrderingMode.desc),
      ]);

    final elementos = await query.get();
    if (elementos.isEmpty) return [];

    final allItems = await (_db.select(_db.itemsLista)
          ..orderBy([(i) => OrderingTerm(expression: i.orden)]))
        .get();

    final Map<int, List<ItemListaData>> itemsByElementId = {};
    for (final item in allItems) {
      itemsByElementId.putIfAbsent(item.elementoId, () => []).add(item);
    }

    return elementos.map((el) {
      return ElementoPersonalConItems(
        elemento: el,
        items: itemsByElementId[el.id] ?? const [],
      );
    }).toList();
  }

  @override
  Future<int> guardarElemento(ElementosPersonalesCompanion companion) async {
    final now = DateTime.now();
    final compConFechas = companion.copyWith(
      fechaCreacion: companion.fechaCreacion.present ? companion.fechaCreacion : Value(now),
      fechaActualizacion: Value(now),
    );
    return await _db.into(_db.elementosPersonales).insert(compConFechas);
  }

  @override
  Future<void> actualizarElemento(ElementosPersonalesCompanion companion) async {
    final compConFecha = companion.copyWith(
      fechaActualizacion: Value(DateTime.now()),
    );
    await _db.update(_db.elementosPersonales).replace(compConFecha);
  }

  @override
  Future<void> eliminarElemento(int id) async {
    await (_db.delete(_db.elementosPersonales)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> toggleFijado(int id, bool esFijadoActual) async {
    await (_db.update(_db.elementosPersonales)..where((t) => t.id.equals(id))).write(
      ElementosPersonalesCompanion(
        esFijado: Value(!esFijadoActual),
        fechaActualizacion: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> agregarItemLista(ItemsListaCompanion item) async {
    await _db.into(_db.itemsLista).insert(item);
    if (item.elementoId.present) {
      await _actualizarFechaElemento(item.elementoId.value);
    }
  }

  @override
  Future<void> toggleItemLista(int itemId, bool completado) async {
    final item = await (_db.select(_db.itemsLista)..where((i) => i.id.equals(itemId))).getSingleOrNull();
    if (item != null) {
      await (_db.update(_db.itemsLista)..where((i) => i.id.equals(itemId))).write(
        ItemsListaCompanion(completado: Value(!completado)),
      );
      await _actualizarFechaElemento(item.elementoId);
    }
  }

  @override
  Future<void> eliminarItemLista(int itemId) async {
    final item = await (_db.select(_db.itemsLista)..where((i) => i.id.equals(itemId))).getSingleOrNull();
    if (item != null) {
      await (_db.delete(_db.itemsLista)..where((i) => i.id.equals(itemId))).go();
      await _actualizarFechaElemento(item.elementoId);
    }
  }

  @override
  Future<void> guardarItemsLista(int elementoId, List<String> textosItems) async {
    await _db.transaction(() async {
      await (_db.delete(_db.itemsLista)..where((i) => i.elementoId.equals(elementoId))).go();
      for (int i = 0; i < textosItems.length; i++) {
        final txt = textosItems[i].trim();
        if (txt.isNotEmpty) {
          await _db.into(_db.itemsLista).insert(
            ItemsListaCompanion.insert(
              elementoId: elementoId,
              texto: txt,
              orden: Value(i),
            ),
          );
        }
      }
      await _actualizarFechaElemento(elementoId);
    });
  }

  @override
  Future<void> actualizarProgresoMeta(int id, int nuevoProgreso) async {
    await (_db.update(_db.elementosPersonales)..where((t) => t.id.equals(id))).write(
      ElementosPersonalesCompanion(
        progresoActual: Value(nuevoProgreso),
        fechaActualizacion: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _actualizarFechaElemento(int elementoId) async {
    await (_db.update(_db.elementosPersonales)..where((t) => t.id.equals(elementoId))).write(
      ElementosPersonalesCompanion(fechaActualizacion: Value(DateTime.now())),
    );
  }
}
