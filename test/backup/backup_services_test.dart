import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/services.dart';

import 'package:organizador_app/core/database/app_database.dart';
import 'package:organizador_app/core/enums.dart';
import 'package:organizador_app/core/security/secure_storage_service.dart';
import 'package:organizador_app/core/services/backup/backup_crypto_service.dart';
import 'package:organizador_app/core/services/backup/backup_manager.dart';
import 'package:organizador_app/core/services/backup/backup_models.dart';
import 'package:organizador_app/core/services/backup/backup_validator.dart';

import '../security/secure_storage_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        final tempDir = Directory.systemTemp.createTempSync('backup_test_');
        return tempDir.path;
      },
    );
  });
  group('BackupCryptoService Tests', () {
    const testPassword = 'MySecretPassphrase123!';
    late BackupPayload testPayload;

    setUp(() {
      testPayload = BackupPayload(
        backupVersion: 1,
        appVersion: '1.0.0',
        createdAt: DateTime.now().toUtc().toIso8601String(),
        database: {
          'transacciones': [
            {
              'id': 1,
              'descripcion': 'Supermercado',
              'monto': 1500.50,
              'fecha': '2026-08-06T12:00:00.000Z',
              'tipo': 1,
              'categoriaId': 1,
            }
          ],
          'tareas': [
            {
              'id': 1,
              'titulo': 'Estudiar Parcial',
              'fecha': '2026-08-10T10:00:00.000Z',
              'tipo': 0,
              'completada': false,
            }
          ]
        },
        settings: {'theme': 'system'},
        metadata: {'platform': 'test'},
      );
    });

    test('Encrypt and decrypt payload with correct password succeeds', () {
      final container = BackupCryptoService.encryptPayload(
        payload: testPayload,
        password: testPassword,
      );

      expect(container.salt, isNotEmpty);
      expect(container.iv, isNotEmpty);
      expect(container.mac, isNotEmpty);
      expect(container.cipherText, isNotEmpty);

      final decrypted = BackupCryptoService.decryptContainer(
        container: container,
        password: testPassword,
      );

      expect(decrypted.backupVersion, equals(testPayload.backupVersion));
      expect(decrypted.appVersion, equals(testPayload.appVersion));
      expect(decrypted.database['transacciones'].length, equals(1));
      expect(decrypted.database['transacciones'][0]['descripcion'], equals('Supermercado'));
    });

    test('Decrypting with wrong password throws BackupCryptoException', () {
      final container = BackupCryptoService.encryptPayload(
        payload: testPayload,
        password: testPassword,
      );

      expect(
        () => BackupCryptoService.decryptContainer(
          container: container,
          password: 'WRONG_PASSWORD_XYZ',
        ),
        throwsA(isA<BackupCryptoException>()),
      );
    });

    test('Decrypting corrupted cipherText or MAC throws BackupCryptoException', () {
      final container = BackupCryptoService.encryptPayload(
        payload: testPayload,
        password: testPassword,
      );

      final corruptedContainer = EncryptedBackupContainer(
        version: container.version,
        salt: container.salt,
        iv: container.iv,
        mac: '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff',
        cipherText: container.cipherText,
        createdAt: container.createdAt,
      );

      expect(
        () => BackupCryptoService.decryptContainer(
          container: corruptedContainer,
          password: testPassword,
        ),
        throwsA(isA<BackupCryptoException>()),
      );
    });
  });

  group('BackupValidator Tests', () {
    test('Validate valid payload generates correct summary', () {
      final payload = BackupPayload(
        backupVersion: 1,
        appVersion: '1.0.0',
        createdAt: '2026-08-06T14:00:00Z',
        database: {
          'transacciones': [{'id': 1}, {'id': 2}],
          'tareas': [{'id': 1}],
          'conocidos': [{'id': 1}],
        },
        settings: {},
        metadata: {},
      );

      final summary = BackupValidator.validateAndSummarize(payload);
      expect(summary.transactionCount, equals(2));
      expect(summary.taskCount, equals(1));
      expect(summary.conocidoCount, equals(1));
      expect(summary.totalRecords, equals(4));
    });

    test('Unsupported higher backupVersion throws BackupValidationException', () {
      final payload = BackupPayload(
        backupVersion: 99,
        appVersion: '9.9.0',
        createdAt: '2030-01-01T00:00:00Z',
        database: {'transacciones': []},
        settings: {},
        metadata: {},
      );

      expect(
        () => BackupValidator.validateAndSummarize(payload),
        throwsA(isA<BackupValidationException>()),
      );
    });
  });

  group('BackupManager Integration Tests', () {
    late AppDatabase db;
    late SecureStorageService secureStorage;
    late BackupManager backupManager;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      secureStorage = SecureStorageService(storage: FakeFlutterSecureStorage());
      backupManager = BackupManager(db: db, secureStorage: secureStorage);

      await db.inicializarCategoriasBase();
    });

    tearDown(() async {
      await db.close();
    });

    test('Export and restore full database workflow succeeds', () async {
      const pass = 'SuperSecurePassphrase2026!';

      // 1. Insert test transaction into in-memory SQLite DB
      await db.into(db.transacciones).insert(
        TransaccionesCompanion.insert(
          descripcion: 'Almuerzo de prueba',
          monto: 2500.0,
          fecha: DateTime.now(),
          tipo: TipoTransaccion.egreso,
          categoriaId: 1,
        ),
      );

      final initialTxs = await db.select(db.transacciones).get();
      expect(initialTxs.length, equals(1));

      // 2. Export encrypted backup container
      final rawContainerJson = await backupManager.exportBackup(
        password: pass,
        includeExternalSecrets: false,
      );

      expect(rawContainerJson, isNotEmpty);

      // 3. Preview backup summary
      final summary = await backupManager.previewBackup(
        rawContainerJson: rawContainerJson,
        password: pass,
      );

      expect(summary.transactionCount, equals(1));

      // 4. Delete existing transaction to simulate fresh restore
      await db.delete(db.transacciones).go();
      expect((await db.select(db.transacciones).get()), isEmpty);

      // 5. Restore database
      final restoredSummary = await backupManager.restoreBackup(
        rawContainerJson: rawContainerJson,
        password: pass,
      );

      expect(restoredSummary.transactionCount, equals(1));

      final restoredTxs = await db.select(db.transacciones).get();
      expect(restoredTxs.length, equals(1));
      expect(restoredTxs.first.descripcion, equals('Almuerzo de prueba'));
      expect(restoredTxs.first.monto, equals(2500.0));
    });
  });
}
