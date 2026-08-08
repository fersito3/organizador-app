import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/app_database.dart';
import '../../enums.dart';
import '../../security/secure_storage_service.dart';
import 'backup_crypto_service.dart';
import 'backup_models.dart';
import 'backup_validator.dart';

class BackupRestoreException implements Exception {
  final String message;
  BackupRestoreException(this.message);

  @override
  String toString() => message;
}

class BackupManager {
  final AppDatabase _db;
  final SecureStorageService _secureStorage;

  BackupManager({
    required AppDatabase db,
    required SecureStorageService secureStorage,
  })  : _db = db,
        _secureStorage = secureStorage;

  /// Serializes all database tables and optional secure storage items into an
  /// encrypted container string (.organizador_backup).
  Future<String> exportBackup({
    required String password,
    bool includeExternalSecrets = false,
  }) async {
    // 1. Fetch data from all SQLite tables
    final categories = await _db.select(_db.categorias).get();
    final transacciones = await _db.select(_db.transacciones).get();
    final conocidos = await _db.select(_db.conocidos).get();
    final eventos = await _db.select(_db.eventos).get();
    final tareas = await _db.select(_db.tareas).get();
    final elementosPersonales = await _db.select(_db.elementosPersonales).get();
    final itemsLista = await _db.select(_db.itemsLista).get();
    final ajustesProyectados = await _db.select(_db.ajustesProyectados).get();

    final dbPayload = <String, dynamic>{
      'categorias': categories.map((c) => {
        'id': c.id,
        'nombre': c.nombre,
        'colorHex': c.colorHex,
        'tipo': c.tipo.index,
      }).toList(),
      'transacciones': transacciones.map((t) => {
        'id': t.id,
        'descripcion': t.descripcion,
        'monto': t.monto,
        'fecha': t.fecha.toIso8601String(),
        'tipo': t.tipo.index,
        'categoriaId': t.categoriaId,
        'mpPaymentId': t.mpPaymentId,
        'proveedor': t.proveedor,
        'conocidoId': t.conocidoId,
        'contraparteMpId': t.contraparteMpId,
      }).toList(),
      'conocidos': conocidos.map((c) => {
        'id': c.id,
        'nombre': c.nombre,
        'apellido': c.apellido,
        'mpUserId': c.mpUserId,
      }).toList(),
      'eventos': eventos.map((e) => {
        'id': e.id,
        'titulo': e.titulo,
        'descripcion': e.descripcion,
        'fechaInicio': e.fechaInicio.toIso8601String(),
        'fechaFin': e.fechaFin.toIso8601String(),
        'colorHex': e.colorHex,
        'esRecurrente': e.esRecurrente,
        'patronRecurrencia': e.patronRecurrencia,
        'transaccionId': e.transaccionId,
      }).toList(),
      'tareas': tareas.map((t) => {
        'id': t.id,
        'titulo': t.titulo,
        'descripcion': t.descripcion,
        'fecha': t.fecha.toIso8601String(),
        'tipo': t.tipo.index,
        'completada': t.completada,
        'eventoId': t.eventoId,
      }).toList(),
      'elementosPersonales': elementosPersonales.map((e) => {
        'id': e.id,
        'titulo': e.titulo,
        'contenido': e.contenido,
        'tipo': e.tipo.index,
        'categoria': e.categoria,
        'prioridad': e.prioridad.index,
        'esFijado': e.esFijado,
        'fechaCreacion': e.fechaCreacion.toIso8601String(),
        'fechaActualizacion': e.fechaActualizacion.toIso8601String(),
        'progresoActual': e.progresoActual,
        'progresoTotal': e.progresoTotal,
        'fechaObjetivo': e.fechaObjetivo?.toIso8601String(),
      }).toList(),
      'itemsLista': itemsLista.map((i) => {
        'id': i.id,
        'elementoId': i.elementoId,
        'texto': i.texto,
        'completado': i.completado,
        'orden': i.orden,
      }).toList(),
      'ajustesProyectados': ajustesProyectados.map((a) => {
        'id': a.id,
        'descripcion': a.descripcion,
        'monto': a.monto,
        'esIngreso': a.esIngreso,
        'fecha': a.fecha.toIso8601String(),
        'completado': a.completado,
      }).toList(),
    };

    Map<String, String>? securePayload;
    if (includeExternalSecrets) {
      securePayload = await _secureStorage.readAll();
    }

    final payload = BackupPayload(
      backupVersion: 1,
      appVersion: '1.0.0',
      createdAt: DateTime.now().toUtc().toIso8601String(),
      database: dbPayload,
      settings: {'app': 'organizador_app'},
      metadata: {'exportDevice': Platform.operatingSystem},
      secureStorage: securePayload,
    );

    final container = BackupCryptoService.encryptPayload(
      payload: payload,
      password: password,
    );

    return container.toRawJson();
  }

  /// Decrypts and previews a backup container without writing changes to the database.
  Future<BackupSummary> previewBackup({
    required String rawContainerJson,
    required String password,
  }) async {
    final container = EncryptedBackupContainer.fromRawJson(rawContainerJson);
    final payload = BackupCryptoService.decryptContainer(
      container: container,
      password: password,
    );
    return BackupValidator.validateAndSummarize(payload);
  }

  /// Restores a backup from [rawContainerJson] using [password].
  ///
  /// Uses a temporary database safety snapshot to guarantee rollback on any failure.
  Future<BackupSummary> restoreBackup({
    required String rawContainerJson,
    required String password,
    bool restoreSecureSecrets = false,
  }) async {
    // 1. Decrypt & Validate first
    final container = EncryptedBackupContainer.fromRawJson(rawContainerJson);
    final payload = BackupCryptoService.decryptContainer(
      container: container,
      password: password,
    );
    final summary = BackupValidator.validateAndSummarize(payload);

    // 2. Database Safety Snapshot
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'db.sqlite'));
    final tempBackupFile = File(p.join(dbFolder.path, 'db.sqlite.tmp_restore_backup'));

    if (await dbFile.exists()) {
      await dbFile.copy(tempBackupFile.path);
    }

    try {
      // 3. Clear existing database tables inside a transaction
      await _db.transaction(() async {
        await _db.delete(_db.itemsLista).go();
        await _db.delete(_db.elementosPersonales).go();
        await _db.delete(_db.tareas).go();
        await _db.delete(_db.eventos).go();
        await _db.delete(_db.transacciones).go();
        await _db.delete(_db.categorias).go();
        await _db.delete(_db.conocidos).go();
        await _db.delete(_db.ajustesProyectados).go();

        final dbMap = payload.database;

        // Restore Categories
        final categoriesJson = (dbMap['categorias'] as List<dynamic>?) ?? [];
        for (var c in categoriesJson) {
          await _db.into(_db.categorias).insert(
            CategoriasCompanion.insert(
              id: Value(c['id'] as int),
              nombre: c['nombre'] as String,
              colorHex: c['colorHex'] as String,
              tipo: TipoTransaccion.values[c['tipo'] as int],
            ),
          );
        }

        // Restore Conocidos
        final conocidosJson = (dbMap['conocidos'] as List<dynamic>?) ?? [];
        for (var c in conocidosJson) {
          await _db.into(_db.conocidos).insert(
            ConocidosCompanion.insert(
              id: Value(c['id'] as int),
              nombre: c['nombre'] as String,
              apellido: c['apellido'] as String,
              mpUserId: Value(c['mpUserId'] as String?),
            ),
          );
        }

        // Restore Transactions
        final transactionsJson = (dbMap['transacciones'] as List<dynamic>?) ?? [];
        for (var t in transactionsJson) {
          await _db.into(_db.transacciones).insert(
            TransaccionesCompanion.insert(
              id: Value(t['id'] as int),
              descripcion: t['descripcion'] as String,
              monto: (t['monto'] as num).toDouble(),
              fecha: DateTime.parse(t['fecha'] as String),
              tipo: TipoTransaccion.values[t['tipo'] as int],
              categoriaId: t['categoriaId'] as int,
              mpPaymentId: Value(t['mpPaymentId'] as String?),
              proveedor: Value(t['proveedor'] as String? ?? 'MANUAL'),
              conocidoId: Value(t['conocidoId'] as int?),
              contraparteMpId: Value(t['contraparteMpId'] as String?),
            ),
          );
        }

        // Restore Eventos
        final eventosJson = (dbMap['eventos'] as List<dynamic>?) ?? [];
        for (var e in eventosJson) {
          await _db.into(_db.eventos).insert(
            EventosCompanion.insert(
              id: Value(e['id'] as int),
              titulo: e['titulo'] as String,
              descripcion: Value(e['descripcion'] as String?),
              fechaInicio: DateTime.parse(e['fechaInicio'] as String),
              fechaFin: DateTime.parse(e['fechaFin'] as String),
              colorHex: Value(e['colorHex'] as String? ?? 'F59E0B'),
              esRecurrente: Value(e['esRecurrente'] as bool? ?? false),
              patronRecurrencia: Value(e['patronRecurrencia'] as String?),
              transaccionId: Value(e['transaccionId'] as int?),
            ),
          );
        }

        // Restore Tareas
        final tareasJson = (dbMap['tareas'] as List<dynamic>?) ?? [];
        for (var t in tareasJson) {
          await _db.into(_db.tareas).insert(
            TareasCompanion.insert(
              id: Value(t['id'] as int),
              titulo: t['titulo'] as String,
              descripcion: Value(t['descripcion'] as String?),
              fecha: DateTime.parse(t['fecha'] as String),
              tipo: TipoTarea.values[t['tipo'] as int],
              completada: Value(t['completada'] as bool? ?? false),
              eventoId: Value(t['eventoId'] as int?),
            ),
          );
        }

        // Restore Elementos Personales
        final elementosJson = (dbMap['elementosPersonales'] as List<dynamic>?) ?? [];
        for (var e in elementosJson) {
          await _db.into(_db.elementosPersonales).insert(
            ElementosPersonalesCompanion.insert(
              id: Value(e['id'] as int),
              titulo: e['titulo'] as String,
              contenido: Value(e['contenido'] as String?),
              tipo: TipoElementoPersonal.values[e['tipo'] as int],
              categoria: Value(e['categoria'] as String? ?? 'General'),
              prioridad: Value(Prioridad.values[e['prioridad'] as int]),
              esFijado: Value(e['esFijado'] as bool? ?? false),
              fechaCreacion: DateTime.parse(e['fechaCreacion'] as String),
              fechaActualizacion: DateTime.parse(e['fechaActualizacion'] as String),
              progresoActual: Value(e['progresoActual'] as int?),
              progresoTotal: Value(e['progresoTotal'] as int?),
              fechaObjetivo: Value(e['fechaObjetivo'] != null ? DateTime.parse(e['fechaObjetivo'] as String) : null),
            ),
          );
        }

        // Restore Items Lista
        final itemsJson = (dbMap['itemsLista'] as List<dynamic>?) ?? [];
        for (var i in itemsJson) {
          await _db.into(_db.itemsLista).insert(
            ItemsListaCompanion.insert(
              id: Value(i['id'] as int),
              elementoId: i['elementoId'] as int,
              texto: i['texto'] as String,
              completado: Value(i['completado'] as bool? ?? false),
              orden: Value(i['orden'] as int? ?? 0),
            ),
          );
        }

        // Restore Ajustes Proyectados
        final ajustesJson = (dbMap['ajustesProyectados'] as List<dynamic>?) ?? [];
        for (var a in ajustesJson) {
          await _db.into(_db.ajustesProyectados).insert(
            AjustesProyectadosCompanion.insert(
              id: Value(a['id'] as int),
              descripcion: a['descripcion'] as String,
              monto: (a['monto'] as num).toDouble(),
              esIngreso: a['esIngreso'] as bool,
              fecha: DateTime.parse(a['fecha'] as String),
              completado: Value(a['completado'] as bool? ?? false),
            ),
          );
        }
      });

      // Restore Secure Storage if requested
      if (restoreSecureSecrets && payload.secureStorage != null) {
        for (var entry in payload.secureStorage!.entries) {
          await _secureStorage.write(key: entry.key, value: entry.value.toString());
        }
      }

      // Cleanup temp backup after clean restoration
      if (await tempBackupFile.exists()) {
        await tempBackupFile.delete();
      }

      return summary;
    } catch (e) {
      debugPrint('❌ [BackupRestore] Restore failed: $e. Reverting from temp backup...');
      // Safe rollback
      if (await tempBackupFile.exists()) {
        await tempBackupFile.copy(dbFile.path);
        await tempBackupFile.delete();
      }
      throw BackupRestoreException('Fallo durante la restauración: $e. Se restauró el estado anterior intacto.');
    }
  }
}
