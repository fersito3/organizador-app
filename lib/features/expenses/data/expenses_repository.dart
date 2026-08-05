import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart' hide Conocido;
import '../../../core/enums.dart';
import '../domain/models/categoria_domain.dart';
import '../domain/models/transaccion.dart';
import '../domain/models/conocido.dart';
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
    int? conocidoId,
    String? contraparteMpId,
  }) {
    return db.into(db.transacciones).insert(
          TransaccionesCompanion.insert(
            descripcion: descripcion,
            monto: monto,
            fecha: fecha,
            tipo: tipo,
            categoriaId: categoriaId,
            conocidoId: Value(conocidoId),
            contraparteMpId: Value(contraparteMpId),
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
      mpPaymentId: t.mpPaymentId,
      proveedor: t.proveedor,
      conocidoId: t.conocidoId,
      contraparteMpId: t.contraparteMpId,
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
    
    // 2. Obtener conocidos existentes para traducción de nombres
    final conocidosExistentes = await db.select(db.conocidos).get();
    
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

    // 3. Guardar transacciones
    for (final item in transaccionesList) {
      if (item.mpPaymentId == null) continue;

      // Ignorar transacciones previas a la fecha de corte (doble seguridad)
      if (item.fecha.isBefore(cutoffDate)) continue;

      // Verificar duplicados por ID único de Mercado Pago
      final query = db.select(db.transacciones)
        ..where((t) => t.mpPaymentId.equals(item.mpPaymentId!));
      final result = await query.get();

      // Buscar si la contraparte es un conocido guardado para auto-resolver conocidoId
    int? conocidoId = item.conocidoId;
    
    if (item.contraparteMpId != null) {
      // Caso A: Si la transacción ya tiene un conocidoId asociado localmente, 
      // actualizamos el mpUserId de ese conocido para vincularlo a futuro.
      if (conocidoId != null) {
        try {
          final matchedConocido = conocidosExistentes.firstWhere(
            (c) => c.id == conocidoId,
          );
          // Si el conocido aún no tenía guardado su MP ID, se le asigna
          if (matchedConocido.mpUserId != item.contraparteMpId) {
            await (db.update(db.conocidos)..where((c) => c.id.equals(conocidoId!)))
              .write(ConocidosCompanion(
                mpUserId: Value(item.contraparteMpId),
              ));
          }
        } catch (_) {}
      } 
      // Caso B: Si la transacción NO tiene conocidoId, buscamos si algún conocido 
      // guardado tiene este mismo ID de Mercado Pago.
      else {
        try {
          final matchedConocido = conocidosExistentes.firstWhere(
            (c) => c.mpUserId == item.contraparteMpId,
          );
          conocidoId = matchedConocido.id;
        } catch (_) {}
      }
    }

      // Encriptar / guardar nombre de contraparte genérica en la descripción
      // Si la descripción de MP es genérica ("Transferencia") pero viene con destinatarioEmisor, lo adjuntamos a la descripción
      // Esto previene perder quién envió/recibió la plata si no hay un conocido guardado aún!
    String finalDesc = 'Transferencia';

    if (conocidoId != null) {
      try {
        final conocido = conocidosExistentes.firstWhere((c) => c.id == conocidoId);
        finalDesc = '${conocido.nombre} ${conocido.apellido}'.trim();
      } catch (_) {}
    } else if (item.descripcion.isNotEmpty) {
      finalDesc = item.descripcion;
    }

      final catId = idVarios ?? 1;

      if (result.isEmpty) {
      await db.into(db.transacciones).insert(
            TransaccionesCompanion.insert(
              descripcion: finalDesc,
              monto: item.monto,
              fecha: item.fecha,
              tipo: item.tipo,
              categoriaId: catId,
              mpPaymentId: Value(item.mpPaymentId),
              proveedor: const Value('MP'),
              conocidoId: Value(conocidoId),
              contraparteMpId: Value(item.contraparteMpId),
            ),
          );
    } else {
      final existing = result.first;
      if (existing.tipo != item.tipo || 
          existing.descripcion != finalDesc ||
          existing.conocidoId != conocidoId ||
          existing.categoriaId != catId) {
        await (db.update(db.transacciones)..where((t) => t.id.equals(existing.id)))
          .write(TransaccionesCompanion(
            tipo: Value(item.tipo),
            descripcion: Value(finalDesc),
            categoriaId: Value(catId),
            conocidoId: Value(conocidoId),
            contraparteMpId: Value(item.contraparteMpId),
          ));
      }
      }
    }
    await autocompletarIdsConocidos();
  }

  @override
  Future<void> eliminarTransaccion(int id) async {
    await (db.delete(db.transacciones)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> actualizarTransaccion(int id, String descripcion, int categoriaId, {int? conocidoId}) async {
    // 1. Obtener la transacción actual para ver si tiene contraparteMpId
    final query = db.select(db.transacciones)..where((t) => t.id.equals(id));
    final list = await query.get();
    if (list.isNotEmpty) {
      final tx = list.first;
      
      // 2. Si se seleccionó un conocido y la transacción tiene contraparteMpId
      if (conocidoId != null && tx.contraparteMpId != null) {
        final conQuery = db.select(db.conocidos)..where((c) => c.id.equals(conocidoId));
        final conList = await conQuery.get();
        if (conList.isNotEmpty) {
          final conocido = conList.first;
          
          // Si el conocido no tiene mpUserId cargado, se lo asignamos
          if (conocido.mpUserId == null || conocido.mpUserId!.trim().isEmpty) {
            await (db.update(db.conocidos)..where((c) => c.id.equals(conocidoId)))
                .write(ConocidosCompanion(mpUserId: Value(tx.contraparteMpId!.trim())));
          }
          
          // Propagar el conocidoId a todas las transacciones que tengan esta contraparte
          await (db.update(db.transacciones)..where((t) => t.contraparteMpId.equals(tx.contraparteMpId!.trim())))
              .write(TransaccionesCompanion(conocidoId: Value(conocidoId)));
        }
      }
    }

    // 3. Actualizar la transacción editada
    await (db.update(db.transacciones)..where((t) => t.id.equals(id)))
      .write(TransaccionesCompanion(
        descripcion: Value(descripcion),
        categoriaId: Value(categoriaId),
        conocidoId: Value(conocidoId),
      ));
  }

  @override
  Future<void> asociarConocidoATransaccion(int transaccionId, int conocidoId) async {
    final query = db.select(db.transacciones)..where((t) => t.id.equals(transaccionId));
    final list = await query.get();
    if (list.isEmpty) return;
    final tx = list.first;

    await (db.update(db.transacciones)..where((t) => t.id.equals(transaccionId)))
        .write(TransaccionesCompanion(conocidoId: Value(conocidoId)));

    if (tx.contraparteMpId != null) {
      final conocidoQuery = db.select(db.conocidos)..where((c) => c.id.equals(conocidoId));
      final conList = await conocidoQuery.get();
      if (conList.isNotEmpty) {
        final conocido = conList.first;
        final nombreCompleto = '${conocido.nombre} ${conocido.apellido}'.trim();
        await asociarTransaccionesConConocido(
          mpUserId: tx.contraparteMpId!,
          conocidoId: conocidoId,
          nombreCompleto: nombreCompleto,
        );
      }
    }
  }

  // --- MÉTODOS DE CONOCIDOS ---
  Future<void> autocompletarIdsConocidos() async {
    final conocidosList = await db.select(db.conocidos).get();
    for (final conocido in conocidosList) {
      if (conocido.mpUserId == null || conocido.mpUserId!.trim().isEmpty) {
        final query = db.select(db.transacciones)
          ..where((t) => t.conocidoId.equals(conocido.id) & t.contraparteMpId.isNotNull())
          ..limit(1);
        final txList = await query.get();
        if (txList.isNotEmpty) {
          final tx = txList.first;
          if (tx.contraparteMpId != null && tx.contraparteMpId!.trim().isNotEmpty) {
            final mpIdVal = tx.contraparteMpId!.trim();
            // Actualizar mpUserId del conocido
            await (db.update(db.conocidos)..where((c) => c.id.equals(conocido.id)))
                .write(ConocidosCompanion(mpUserId: Value(mpIdVal)));
            // Propagar conocidoId a todas las transacciones con este ID
            await (db.update(db.transacciones)..where((t) => t.contraparteMpId.equals(mpIdVal)))
                .write(TransaccionesCompanion(conocidoId: Value(conocido.id)));
          }
        }
      }
    }
  }

  @override
  Future<List<Conocido>> obtenerConocidos() async {
    await autocompletarIdsConocidos();
    final list = await db.select(db.conocidos).get();
    return list.map((c) => Conocido(
      id: c.id,
      nombre: c.nombre,
      apellido: c.apellido,
      mpUserId: c.mpUserId,
    )).toList();
  }

  @override
  Future<int> guardarConocido({required String nombre, required String apellido, String? mpUserId}) async {
    if (mpUserId != null && mpUserId.trim().isNotEmpty) {
      final query = db.select(db.conocidos)..where((c) => c.mpUserId.equals(mpUserId.trim()));
      final exists = await query.get();
      if (exists.isNotEmpty) {
        return exists.first.id;
      }
    }
    return db.into(db.conocidos).insert(
      ConocidosCompanion.insert(
        nombre: nombre,
        apellido: apellido,
        mpUserId: Value(mpUserId?.trim()),
      ),
    );
  }

  @override
  Future<void> eliminarConocido(int conocidoId) async {
    await (db.update(db.transacciones)..where((t) => t.conocidoId.equals(conocidoId)))
        .write(const TransaccionesCompanion(conocidoId: Value(null)));
    
    await (db.delete(db.conocidos)..where((c) => c.id.equals(conocidoId))).go();
  }

  @override
  Future<void> asociarTransaccionesConConocido({
    required String mpUserId,
    required int conocidoId,
    required String nombreCompleto,
  }) async {
    await (db.update(db.conocidos)..where((c) => c.id.equals(conocidoId)))
        .write(ConocidosCompanion(mpUserId: Value(mpUserId.trim())));

    await (db.update(db.transacciones)..where((t) => t.contraparteMpId.equals(mpUserId.trim())))
        .write(TransaccionesCompanion(
          conocidoId: Value(conocidoId),
        ));
  }
}