import 'package:flutter/foundation.dart';
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
    debugPrint('🚩 [REPO_FLAG 1: INICIO GUARDAR SYNC] Recibidas ${transaccionesList.length} transacciones de red.');
    
    // PASO 1: Obtener categorías y lista de conocidos existente en la BDD
    final categoriasExistentes = await db.select(db.categorias).get();
    final conocidosExistentes = await db.select(db.conocidos).get();
    debugPrint('🚩 [REPO_FLAG 2: ESTADO INICIAL BBDD] Total conocidos en BBDD: ${conocidosExistentes.length}');
    for (final c in conocidosExistentes) {
      debugPrint('   -> Conocido BBDD: id=${c.id}, nombre="${c.nombre} ${c.apellido}", mpUserId="${c.mpUserId}"');
    }

    int? findCategoryIdByName(String name) {
      final match = categoriasExistentes.where((c) => c.nombre.toLowerCase() == name.toLowerCase());
      return match.isNotEmpty ? match.first.id : null;
    }

    final idVarios = findCategoryIdByName('Varios');
    final catFallbackId = idVarios ?? 1;

    // Fecha límite de corte del lado del cliente
    final cutoffDate = DateTime.parse('2026-08-05T02:35:00Z');

    // PASO 2: Mapear e insertar / actualizar transacciones entrantes de la red
    for (final item in transaccionesList) {
      if (item.mpPaymentId == null) continue;

      // Ignorar transacciones previas a la fecha de corte
      if (item.fecha.isBefore(cutoffDate)) continue;

      final int categoriaFinalId = (item.categoriaId > 0) ? item.categoriaId : catFallbackId;
      final cleanContraparteMpId = item.contraparteMpId?.trim();

      debugPrint('🚩 [REPO_FLAG 3: PROCESANDO ITEM] paymentId=${item.mpPaymentId}, desc="${item.descripcion}", contraparteMpId="$cleanContraparteMpId"');

      // Verificar duplicados por ID único de Mercado Pago
      final query = db.select(db.transacciones)
        ..where((t) => t.mpPaymentId.equals(item.mpPaymentId!));
      final result = await query.get();
      final existing = result.isNotEmpty ? result.first : null;

      if (existing != null) {
        debugPrint('   -> Registro ya existente en BBDD local: txId=${existing.id}, conocidoIdActual=${existing.conocidoId}, contraparteActual="${existing.contraparteMpId}", categoriaIdActual=${existing.categoriaId}');
      } else {
        debugPrint('   -> Nueva transacción a insertar.');
      }

      // Preservar la categoría si la transacción ya existía previamente en la BDD local
      final int categoriaFinalId = existing != null
          ? existing.categoriaId
          : ((item.categoriaId > 0) ? item.categoriaId : catFallbackId);

      // 1. Determinar el conocidoId final (preservar conocidoId si la transacción ya lo tenía guardado)
      int? conocidoId = item.conocidoId ?? existing?.conocidoId;

      // 2. Si no tenía conocidoId aún pero tenemos contraparteMpId, buscar si coincide con algún conocido existente
      if (conocidoId == null && cleanContraparteMpId != null && cleanContraparteMpId.isNotEmpty) {
        try {
          final matchedConocido = conocidosExistentes.firstWhere(
            (c) => c.mpUserId != null && c.mpUserId!.trim() == cleanContraparteMpId,
          );
          conocidoId = matchedConocido.id;
          debugPrint('   -> Coincidencia hallada por mpUserId: asignando conocidoId=$conocidoId ("${matchedConocido.nombre}")');
        } catch (_) {
          debugPrint('   -> No hay ningún conocido guardado con mpUserId="$cleanContraparteMpId"');
        }
      }

      // 3. AUTO-VINCULACIÓN: Si tenemos conocidoId Y contraparteMpId, aseguramos persisitr el mpUserId
      if (conocidoId != null && cleanContraparteMpId != null && cleanContraparteMpId.isNotEmpty) {
        final idx = conocidosExistentes.indexWhere((c) => c.id == conocidoId);
        if (idx != -1) {
          final conocido = conocidosExistentes[idx];
          debugPrint('🚩 [REPO_FLAG 4: AUTO-VINCULACIÓN] Evaluando conocido id=$conocidoId ("${conocido.nombre}"), mpUserIdActual="${conocido.mpUserId}" contra nuevo mpId="$cleanContraparteMpId"');

          if (conocido.mpUserId == null || conocido.mpUserId!.trim().isEmpty || conocido.mpUserId!.trim() != cleanContraparteMpId) {
            await (db.update(db.conocidos)..where((c) => c.id.equals(conocidoId!)))
                .write(ConocidosCompanion(mpUserId: Value(cleanContraparteMpId)));

            conocidosExistentes[idx] = conocido.copyWith(mpUserId: Value(cleanContraparteMpId));
            debugPrint('✅ [EXITO AUTO-VINCULAR] Guardado mpUserId "$cleanContraparteMpId" al conocido id=$conocidoId (${conocido.nombre})');
          }
        }
      }

      // 4. Definir la descripción según el conocidoId final
      String finalDesc = 'Transferencia';

      if (conocidoId != null) {
        try {
          final conocido = conocidosExistentes.firstWhere((c) => c.id == conocidoId);
          finalDesc = '${conocido.nombre} ${conocido.apellido}'.trim();
        } catch (_) {}
      } else if (item.descripcion.isNotEmpty) {
        finalDesc = item.descripcion;
      }

      // 5. Inserción o Actualización en BDD (preservando la categoría elegida por el usuario)
      if (existing == null) {
        await db.into(db.transacciones).insert(
              TransaccionesCompanion.insert(
                descripcion: finalDesc,
                monto: item.monto,
                fecha: item.fecha,
                tipo: item.tipo,
                categoriaId: categoriaFinalId,
                mpPaymentId: Value(item.mpPaymentId),
                proveedor: const Value('MP'),
                conocidoId: Value(conocidoId),
                contraparteMpId: Value(cleanContraparteMpId),
              ),
            );
        debugPrint('   -> Insertada transacción nueva en BBDD local.');
      } else {
        // Auto-curación de transacciones guardadas previamente (sin sobreescribir la categoría editada)
        if (existing.tipo != item.tipo || 
            existing.descripcion != finalDesc ||
            existing.conocidoId != conocidoId ||
            existing.contraparteMpId != cleanContraparteMpId) {
          await (db.update(db.transacciones)..where((t) => t.id.equals(existing.id)))
            .write(TransaccionesCompanion(
              tipo: Value(item.tipo),
              descripcion: Value(finalDesc),
              conocidoId: Value(conocidoId),
              contraparteMpId: Value(cleanContraparteMpId),
            ));
          debugPrint('   -> Actualizada transacción id=${existing.id} con nuevo conocidoId=$conocidoId, desc="$finalDesc"');
        }
      }
    }

    // PASO 3: Un solo autocompletado final para propagar cualquier cambio reciente en cascada
    debugPrint('🚩 [REPO_FLAG 5: EJECUTANDO AUTOCOMPLETAR EN CASCADA]');
    await autocompletarIdsConocidos();
  }

  @override
  Future<void> eliminarTransaccion(int id) async {
    await (db.delete(db.transacciones)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> actualizarTransaccion(int id, String descripcion, int categoriaId, {int? conocidoId}) async {
    debugPrint('🚩 [REPO_FLAG: ACTUALIZAR TRANSACCIÓN] txId=$id, conocidoIdSeleccionado=$conocidoId');
    // 1. Obtener la transacción actual para ver si tiene contraparteMpId
    final query = db.select(db.transacciones)..where((t) => t.id.equals(id));
    final list = await query.get();
    if (list.isNotEmpty) {
      final tx = list.first;
      debugPrint('   -> Transacción en BBDD: contraparteMpId="${tx.contraparteMpId}"');

      // 2. Si se seleccionó un conocido y la transacción tiene contraparteMpId
      if (conocidoId != null && tx.contraparteMpId != null && tx.contraparteMpId!.trim().isNotEmpty) {
        final conQuery = db.select(db.conocidos)..where((c) => c.id.equals(conocidoId));
        final conList = await conQuery.get();
        if (conList.isNotEmpty) {
          final conocido = conList.first;
          final nombreCompleto = '${conocido.nombre} ${conocido.apellido}'.trim();
          debugPrint('🚩 [REPO_FLAG: ACTUALIZAR TRANSACCIÓN] Asociando mpUserId="${tx.contraparteMpId}" al conocido id=$conocidoId ("$nombreCompleto")');
          await asociarTransaccionesConConocido(
            mpUserId: tx.contraparteMpId!.trim(),
            conocidoId: conocidoId,
            nombreCompleto: nombreCompleto,
          );
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
    debugPrint('🚩 [REPO_FLAG: ASOCIAR CONOCIDO A TX] txId=$transaccionId, conocidoId=$conocidoId');
    final query = db.select(db.transacciones)..where((t) => t.id.equals(transaccionId));
    final list = await query.get();
    if (list.isEmpty) return;
    final tx = list.first;

    await (db.update(db.transacciones)..where((t) => t.id.equals(transaccionId)))
        .write(TransaccionesCompanion(conocidoId: Value(conocidoId)));

    if (tx.contraparteMpId != null && tx.contraparteMpId!.trim().isNotEmpty) {
      final conocidoQuery = db.select(db.conocidos)..where((c) => c.id.equals(conocidoId));
      final conList = await conocidoQuery.get();
      if (conList.isNotEmpty) {
        final conocido = conList.first;
        final nombreCompleto = '${conocido.nombre} ${conocido.apellido}'.trim();
        await asociarTransaccionesConConocido(
          mpUserId: tx.contraparteMpId!.trim(),
          conocidoId: conocidoId,
          nombreCompleto: nombreCompleto,
        );
      }
    }
  }

  @override
  Future<void> autocompletarIdsConocidos() async {
    debugPrint('🚩 [AUTOCOMPLETE_FLAG] Inicio de autocompletarIdsConocidos');
    final conocidosList = await db.select(db.conocidos).get();
    debugPrint('   -> Total de conocidos registrados: ${conocidosList.length}');

    for (final conocido in conocidosList) {
      final nombreCompleto = '${conocido.nombre} ${conocido.apellido}'.trim();
      debugPrint('   -> Evaluando conocido id=${conocido.id}, nombre="$nombreCompleto", mpUserId="${conocido.mpUserId}"');

      // Caso A: El conocido ya tiene mpUserId. Propagar a transacciones que coincidan.
      if (conocido.mpUserId != null && conocido.mpUserId!.trim().isNotEmpty) {
        final mpIdVal = conocido.mpUserId!.trim();
        debugPrint('      [Caso A] mpUserId="$mpIdVal" no nulo. Propagando asociación...');
        await asociarTransaccionesConConocido(
          mpUserId: mpIdVal,
          conocidoId: conocido.id,
          nombreCompleto: nombreCompleto,
        );
      } 
      // Caso B: El conocido NO tiene mpUserId. Buscar si hay transacciones asociadas que tengan contraparteMpId.
      else {
        debugPrint('      [Caso B] mpUserId es NULO. Buscando transacciones locales vinculadas a conocidoId=${conocido.id}...');
        final query = db.select(db.transacciones)
          ..where((t) => t.conocidoId.equals(conocido.id));
        final txList = await query.get();
        debugPrint('      [Caso B] Transacciones encontradas con conocidoId=${conocido.id}: ${txList.length}');
        
        final txConContraparte = txList.where((t) => t.contraparteMpId != null && t.contraparteMpId!.trim().isNotEmpty).toList();
        if (txConContraparte.isNotEmpty) {
          final tx = txConContraparte.first;
          final mpIdVal = tx.contraparteMpId!.trim();
          debugPrint('      [Caso B Match!] ¡Encontrada tx con contraparteMpId="$mpIdVal"! Asociando al conocido id=${conocido.id}...');
          await asociarTransaccionesConConocido(
            mpUserId: mpIdVal,
            conocidoId: conocido.id,
            nombreCompleto: nombreCompleto,
          );
        } else {
          debugPrint('      [Caso B] Ninguna transacción asociada a id=${conocido.id} tiene contraparteMpId.');
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
  Future<int> guardarConocido({int? id, required String nombre, required String apellido, String? mpUserId}) async {
    final mpIdVal = mpUserId?.trim();

    if (id != null) {
      // Edición explícita de conocido existente
      await (db.update(db.conocidos)..where((c) => c.id.equals(id)))
          .write(ConocidosCompanion(
            nombre: Value(nombre),
            apellido: Value(apellido),
            mpUserId: Value(mpIdVal),
          ));
      
      if (mpIdVal != null && mpIdVal.isNotEmpty) {
        await asociarTransaccionesConConocido(
          mpUserId: mpIdVal,
          conocidoId: id,
          nombreCompleto: '$nombre $apellido'.trim(),
        );
      }
      return id;
    }

    if (mpIdVal != null && mpIdVal.isNotEmpty) {
      final query = db.select(db.conocidos)..where((c) => c.mpUserId.equals(mpIdVal));
      final exists = await query.get();
      if (exists.isNotEmpty) {
        final existingId = exists.first.id;
        await (db.update(db.conocidos)..where((c) => c.id.equals(existingId)))
            .write(ConocidosCompanion(
              nombre: Value(nombre),
              apellido: Value(apellido),
            ));
        await asociarTransaccionesConConocido(
          mpUserId: mpIdVal,
          conocidoId: existingId,
          nombreCompleto: '$nombre $apellido'.trim(),
        );
        return existingId;
      }
    }

    final newId = await db.into(db.conocidos).insert(
      ConocidosCompanion.insert(
        nombre: nombre,
        apellido: apellido,
        mpUserId: Value(mpIdVal),
      ),
    );

    if (mpIdVal != null && mpIdVal.isNotEmpty) {
      await asociarTransaccionesConConocido(
        mpUserId: mpIdVal,
        conocidoId: newId,
        nombreCompleto: '$nombre $apellido'.trim(),
      );
    }

    return newId;
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
    final cleanMpId = mpUserId.trim();
    if (cleanMpId.isEmpty) return;

    // Actualizar el conocido con su nuevo mpUserId
    await (db.update(db.conocidos)..where((c) => c.id.equals(conocidoId)))
        .write(ConocidosCompanion(mpUserId: Value(cleanMpId)));

    // Asignar conocidoId a las transacciones de esa contraparte
    await (db.update(db.transacciones)..where((t) => t.contraparteMpId.equals(cleanMpId)))
        .write(TransaccionesCompanion(
          conocidoId: Value(conocidoId),
        ));

    // PROTECCIÓN DE DESCRIPCIONES (Punto 2):
    // Solo actualizamos la descripción a 'Nombre Apellido' en las transacciones que tengan la descripción por defecto
    await (db.update(db.transacciones)
          ..where((t) => t.contraparteMpId.equals(cleanMpId) & 
                        (t.descripcion.equals('Transferencia') | t.descripcion.equals(''))))
        .write(TransaccionesCompanion(
          descripcion: Value(nombreCompleto),
        ));
  }
}