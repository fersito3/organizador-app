import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:organizador_app/core/security/secure_storage_service.dart';

/// Fake implementation of FlutterSecureStorage for testing
class FakeFlutterSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_data);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SecureStorageService Unit Tests', () {
    late FakeFlutterSecureStorage fakeStorage;
    late SecureStorageService secureStorageService;

    setUp(() {
      fakeStorage = FakeFlutterSecureStorage();
      secureStorageService = SecureStorageService(storage: fakeStorage);
    });

    test('Writing and reading a secure value works properly', () async {
      const key = SecureStorageService.keyMercadoPagoAccessToken;
      const value = 'TEST_TOKEN_123456';

      final writeResult = await secureStorageService.write(key: key, value: value);
      expect(writeResult, isTrue);

      final readValue = await secureStorageService.read(key: key);
      expect(readValue, equals(value));
    });

    test('Checking existence of key works', () async {
      const key = SecureStorageService.keyUserPinSecret;
      const value = 'PIN_9876';

      expect(await secureStorageService.containsKey(key: key), isFalse);

      await secureStorageService.write(key: key, value: value);

      expect(await secureStorageService.containsKey(key: key), isTrue);
    });

    test('Deleting a key removes it from storage', () async {
      const key = SecureStorageService.keyBackupEncryptionKey;
      const value = 'KEY_AES_256';

      await secureStorageService.write(key: key, value: value);
      expect(await secureStorageService.read(key: key), equals(value));

      final deleteResult = await secureStorageService.delete(key: key);
      expect(deleteResult, isTrue);
      expect(await secureStorageService.read(key: key), isNull);
    });

    test('Reading non-existent key returns null', () async {
      final value = await secureStorageService.read(key: 'non_existent_key');
      expect(value, isNull);
    });

    test('Reading all keys returns all stored pairs', () async {
      await secureStorageService.write(key: 'key1', value: 'val1');
      await secureStorageService.write(key: 'key2', value: 'val2');

      final all = await secureStorageService.readAll();
      expect(all.length, equals(2));
      expect(all['key1'], equals('val1'));
      expect(all['key2'], equals('val2'));
    });

    test('Deleting all keys clears the storage', () async {
      await secureStorageService.write(key: 'key1', value: 'val1');
      await secureStorageService.write(key: 'key2', value: 'val2');

      await secureStorageService.deleteAll();

      final all = await secureStorageService.readAll();
      expect(all, isEmpty);
    });

    test('Migration utility transfers legacy value and deletes old value safely', () async {
      String? legacyStorageValue = 'LEGACY_UNENCRYPTED_TOKEN_ABC';
      bool legacyCleaned = false;

      final result = await secureStorageService.migrateLegacyCredential(
        targetKey: SecureStorageService.keyMercadoPagoAccessToken,
        legacyValueFetcher: () async => legacyStorageValue,
        legacyValueCleaner: () async {
          legacyStorageValue = null;
          legacyCleaned = true;
        },
      );

      expect(result, isTrue);
      expect(legacyCleaned, isTrue);
      expect(legacyStorageValue, isNull);

      final migratedValue = await secureStorageService.read(key: SecureStorageService.keyMercadoPagoAccessToken);
      expect(migratedValue, equals('LEGACY_UNENCRYPTED_TOKEN_ABC'));
    });

    test('Migration utility skips if key already exists in secure storage', () async {
      await secureStorageService.write(
        key: SecureStorageService.keyMercadoPagoAccessToken,
        value: 'EXISTING_SECURE_TOKEN',
      );

      String? legacyStorageValue = 'OLD_UNENCRYPTED_TOKEN';
      bool legacyCleaned = false;

      final result = await secureStorageService.migrateLegacyCredential(
        targetKey: SecureStorageService.keyMercadoPagoAccessToken,
        legacyValueFetcher: () async => legacyStorageValue,
        legacyValueCleaner: () async {
          legacyStorageValue = null;
          legacyCleaned = true;
        },
      );

      expect(result, isTrue);
      expect(legacyCleaned, isTrue);
      expect(await secureStorageService.read(key: SecureStorageService.keyMercadoPagoAccessToken), equals('EXISTING_SECURE_TOKEN'));
    });
  });
}
