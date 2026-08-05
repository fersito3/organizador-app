import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../domain/models/categoria_domain.dart';
import '../domain/models/transaccion.dart';
import '../domain/repository_interfaces/iexpenses_repository.dart';

class ExpensesRepository implements IExpensesRepository {
  final AppDatabase db;

  ExpensesRepository(this.db);

  @override
  Stream<List<Transaccion>> watchTransacciones() {
    return (db.select(db.transacciones)
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .watch()
        .map((list) => list.map(_mapToDomainTransaccion).toList());
  }

  @override
  Future<List<CategoriaDomain>> getCategorias() {
    return db.select(db.categorias).get().then(
          (list) => list.map(_mapToDomainCategoria).toList(),
        );
  }

  @override
  Future<int> agregarTransaccion({
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required TipoTransaccion tipo,
    required int categoriaId,
    String? destinatarioEmisor,
  }) {
    return db.into(db.transacciones).insert(
          TransaccionesCompanion.insert(
            descripcion: descripcion,
            monto: monto,
            fecha: fecha,
            tipo: tipo,
            categoriaId: categoriaId,
            destinatarioEmisor: Value(destinatarioEmisor),
          ),
        );
  }

  Transaccion _mapToDomainTransaccion(Transaccione t) {
    return Transaccion(
      id: t.id,
      descripcion: t.descripcion,
      monto: t.monto,
      fecha: t.fecha,
      tipo: t.tipo,
      categoriaId: t.categoriaId,
      destinatarioEmisor: t.destinatarioEmisor,
      mpPaymentId: t.mpPaymentId,
      proveedor: t.proveedor,
    );
  }

  CategoriaDomain _mapToDomainCategoria(Categoria c) {
    return CategoriaDomain(
      id: c.id,
      nombre: c.nombre,
      colorHex: c.colorHex,
      tipo: c.tipo,
    );
  }

  @override
  Future<void> guardarTransaccionesSincronizadas(List<Transaccion> transaccionesList) async {
    // 1. Obtener categorías existentes para hacer el mapeo inteligente
    final categoriasExistentes = await db.select(db.categorias).get();
    
    int? findCategoryIdByName(String name) {
      try {
        return categoriasExistentes.firstWhere((c) => c.nombre.toLowerCase() == name.toLowerCase()).id;
      } catch (_) {
        return null;
      }
    }

    final idComida = findCategoryIdByName('Comida');
    final idFacultad = findCategoryIdByName('Facultad');
    final idTransporte = findCategoryIdByName('Transporte');
    final idVarios = findCategoryIdByName('Varios');
    final idIngreso = findCategoryIdByName('Ingreso/Sueldo');
    final idAmigos = findCategoryIdByName('Amigos');
    final idFarmacia = findCategoryIdByName('Farmacia');

    // Fecha límite de corte del lado del cliente: 4 de agosto de 2026 a las 23:35 hs (UTC-3) -> 2026-08-05T02:35:00.000Z
    final cutoffDate = DateTime.parse('2026-08-05T02:35:00Z');

    // 2. Guardar transacciones
    for (final item in transaccionesList) {
      if (item.mpPaymentId == null) continue;

      // Ignorar transacciones previas a la fecha de corte (doble seguridad)
      if (item.fecha.isBefore(cutoffDate)) continue;

      // Verificar duplicados por ID único de Mercado Pago
      final query = db.select(db.transacciones)
        ..where((t) => t.mpPaymentId.equals(item.mpPaymentId!));
      final result = await query.get();

      // Algoritmo de categorización inteligente
      int catId = idVarios ?? 1; // Fallback por defecto
      
      if (item.tipo == TipoTransaccion.ingreso) {
        catId = idIngreso ?? catId;
      } else {
        final desc = item.descripcion.toLowerCase();
        if (desc.contains('coto') ||
            desc.contains('pedidosya') ||
            desc.contains('comida') ||
            desc.contains('almuerzo') ||
            desc.contains('restaurant') ||
            desc.contains('burger') ||
            desc.contains('mcdonald') ||
            desc.contains('supermercado') ||
            desc.contains('carrefour') ||
            desc.contains('dia') ||
            desc.contains('rotiseria') ||
            desc.contains('chino')) {
          catId = idComida ?? catId;
        } else if (desc.contains('facu') ||
            desc.contains('facultad') ||
            desc.contains('universidad') ||
            desc.contains('copia') ||
            desc.contains('apunte') ||
            desc.contains('libro') ||
            desc.contains('cuaderno')) {
          catId = idFacultad ?? catId;
        } else if (desc.contains('subte') ||
            desc.contains('colectivo') ||
            desc.contains('uber') ||
            desc.contains('cabify') ||
            desc.contains('didi') ||
            desc.contains('sube') ||
            desc.contains('nafta') ||
            desc.contains('combustible') ||
            desc.contains('peaje') ||
            desc.contains('estacionamiento')) {
          catId = idTransporte ?? catId;
        } else if (desc.contains('amigo') ||
            desc.contains('juntada') ||
            desc.contains('salida') ||
            desc.contains('junta') ||
            desc.contains('regalo') ||
            desc.contains('asado')) {
          catId = idAmigos ?? catId;
        } else if (desc.contains('farmacia') ||
            desc.contains('remedio') ||
            desc.contains('medicamento') ||
            desc.contains('pastilla') ||
            desc.contains('drogeria') ||
            desc.contains('ibuprofeno') ||
            desc.contains('doctor') ||
            desc.contains('consultorio')) {
          catId = idFarmacia ?? catId;
        }
      }

      if (result.isEmpty) {
        // Insertar en la base de datos SQLite
        await db.into(db.transacciones).insert(
              TransaccionesCompanion.insert(
                descripcion: item.descripcion,
                monto: item.monto,
                fecha: item.fecha,
                tipo: item.tipo,
                categoriaId: catId,
                destinatarioEmisor: Value(item.destinatarioEmisor),
                mpPaymentId: Value(item.mpPaymentId),
                proveedor: const Value('MP'),
              ),
            );
      } else {
        // Auto-curación de transacciones guardadas incorrectamente en el historial
        final existing = result.first;
        if (existing.tipo != item.tipo || existing.destinatarioEmisor != item.destinatarioEmisor) {
          await (db.update(db.transacciones)..where((t) => t.id.equals(existing.id)))
            .write(TransaccionesCompanion(
              tipo: Value(item.tipo),
              destinatarioEmisor: Value(item.destinatarioEmisor),
              categoriaId: Value(catId),
            ));
        }
      }
    }
  }

  @override
  Future<void> eliminarTransaccion(int id) async {
    await (db.delete(db.transacciones)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> actualizarTransaccion(int id, String descripcion, int categoriaId) async {
    await (db.update(db.transacciones)..where((t) => t.id.equals(id)))
      .write(TransaccionesCompanion(
        descripcion: Value(descripcion),
        categoriaId: Value(categoriaId),
      ));
  }
}