import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralised service to handle encrypted storage of sensitive information
/// such as API tokens, refresh tokens, secrets, and private keys.
///
/// Follows the Local-First and Privacy-First architecture principles.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Default constructor initializes storage with platform-specific options.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  /// Standard storage keys used across the application.
  static const String keyMercadoPagoAccessToken = 'mp_access_token';
  static const String keyMercadoPagoRefreshToken = 'mp_refresh_token';
  static const String keyUserPinSecret = 'user_pin_secret';
  static const String keyBackupEncryptionKey = 'backup_encryption_key';

  /// Writes a key-value pair to encrypted storage.
  Future<bool> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error writing key "$key": $e');
      return false;
    }
  }

  /// Reads a value associated with [key] from encrypted storage.
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error reading key "$key": $e');
      return null;
    }
  }

  /// Checks if [key] exists in encrypted storage.
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error checking key "$key": $e');
      return false;
    }
  }

  /// Deletes a specific [key] from encrypted storage.
  Future<bool> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error deleting key "$key": $e');
      return false;
    }
  }

  /// Reads all key-value pairs stored in encrypted storage.
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error reading all keys: $e');
      return {};
    }
  }

  /// Deletes all entries from encrypted storage.
  Future<bool> deleteAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error deleting all entries: $e');
      return false;
    }
  }

  /// Safe one-time migration utility from legacy unencrypted sources to SecureStorage.
  ///
  /// Takes a [legacyValueFetcher] to obtain the old value, and a [legacyValueCleaner]
  /// that is only invoked AFTER successful write verification to SecureStorage.
  Future<bool> migrateLegacyCredential({
    required String targetKey,
    required Future<String?> Function() legacyValueFetcher,
    required Future<void> Function() legacyValueCleaner,
  }) async {
    try {
      // 1. Check if already migrated to secure storage
      final existsInSecure = await containsKey(key: targetKey);
      if (existsInSecure) {
        // Clean legacy if it still exists
        await legacyValueCleaner();
        return true;
      }

      // 2. Fetch legacy value
      final legacyValue = await legacyValueFetcher();
      if (legacyValue == null || legacyValue.trim().isEmpty) {
        return false;
      }

      // 3. Write to secure storage
      final written = await write(key: targetKey, value: legacyValue);
      if (!written) {
        debugPrint('⚠️ [SecureStorage Migration] Failed to write legacy value for key "$targetKey"');
        return false;
      }

      // 4. Verify read-back from secure storage before deleting legacy value
      final verifiedValue = await read(key: targetKey);
      if (verifiedValue == legacyValue) {
        // 5. Safe removal of legacy value only after successful verification
        await legacyValueCleaner();
        debugPrint('✅ [SecureStorage Migration] Successfully migrated key "$targetKey"');
        return true;
      } else {
        debugPrint('⚠️ [SecureStorage Migration] Verification failed for key "$targetKey"');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [SecureStorage Migration] Migration exception for key "$targetKey": $e');
      return false;
    }
  }
}
