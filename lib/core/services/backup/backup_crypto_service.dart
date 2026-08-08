import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'backup_models.dart';

class BackupCryptoException implements Exception {
  final String message;
  BackupCryptoException(this.message);

  @override
  String toString() => message;
}

/// Service performing secure key derivation (PBKDF2-HMAC-SHA256) and
/// authenticated AES-256 encryption/decryption for backup files.
class BackupCryptoService {
  static const int _pbkdf2Iterations = 10000;
  static const int _derivedKeyLength = 64; // 32 bytes AES key + 32 bytes HMAC key

  /// Encrypts an unencrypted [BackupPayload] using [password].
  ///
  /// Returns an [EncryptedBackupContainer] ready for disk serialization.
  static EncryptedBackupContainer encryptPayload({
    required BackupPayload payload,
    required String password,
  }) {
    if (password.trim().isEmpty) {
      throw BackupCryptoException('La contraseña no puede estar vacía.');
    }

    final rawJson = payload.toRawJson();
    final saltBytes = _generateSecureRandomBytes(16);
    final ivBytes = _generateSecureRandomBytes(16);

    // 1. Derive 64 bytes (AES key + HMAC key) via PBKDF2-HMAC-SHA256
    final derivedKeys = _deriveKey(password, saltBytes, iterations: _pbkdf2Iterations, keyLength: _derivedKeyLength);
    final aesKeyBytes = derivedKeys.sublist(0, 32);
    final hmacKeyBytes = derivedKeys.sublist(32, 64);

    // 2. Encrypt with AES-256 CBC
    final key = enc.Key(aesKeyBytes);
    final iv = enc.IV(ivBytes);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(rawJson, iv: iv);

    // 3. Compute HMAC-SHA256 over IV + ciphertext (Encrypt-then-MAC)
    final macBytes = _computeHmac(
      hmacKey: hmacKeyBytes,
      data: Uint8List.fromList(ivBytes + encrypted.bytes),
    );

    return EncryptedBackupContainer(
      version: payload.backupVersion,
      salt: _bytesToHex(saltBytes),
      iv: _bytesToHex(ivBytes),
      mac: _bytesToHex(macBytes),
      cipherText: encrypted.base64,
      createdAt: payload.createdAt,
    );
  }

  /// Decrypts an [EncryptedBackupContainer] using [password].
  ///
  /// Throws [BackupCryptoException] if the password is wrong or file is corrupted.
  static BackupPayload decryptContainer({
    required EncryptedBackupContainer container,
    required String password,
  }) {
    if (password.trim().isEmpty) {
      throw BackupCryptoException('Debe ingresar la contraseña.');
    }

    try {
      final saltBytes = _hexToBytes(container.salt);
      final ivBytes = _hexToBytes(container.iv);
      final macBytes = _hexToBytes(container.mac);
      final cipherBytes = enc.Encrypted.fromBase64(container.cipherText).bytes;

      // 1. Derive keys
      final derivedKeys = _deriveKey(password, saltBytes, iterations: _pbkdf2Iterations, keyLength: _derivedKeyLength);
      final aesKeyBytes = derivedKeys.sublist(0, 32);
      final hmacKeyBytes = derivedKeys.sublist(32, 64);

      // 2. Verify HMAC MAC first (Authenticated Encryption check)
      final expectedMac = _computeHmac(
        hmacKey: hmacKeyBytes,
        data: Uint8List.fromList(ivBytes + cipherBytes),
      );

      if (!_constantTimeCompare(macBytes, expectedMac)) {
        throw BackupCryptoException('Contraseña incorrecta o archivo de backup alterado.');
      }

      // 3. Decrypt payload
      final key = enc.Key(aesKeyBytes);
      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decryptedStr = encrypter.decrypt(enc.Encrypted(cipherBytes), iv: iv);

      return BackupPayload.fromRawJson(decryptedStr);
    } on BackupCryptoException {
      rethrow;
    } catch (e) {
      throw BackupCryptoException('Fallo al desencriptar el backup: Contraseña incorrecta o formato inválido.');
    }
  }

  /// PBKDF2-HMAC-SHA256 implementation in pure Dart.
  static Uint8List _deriveKey(
    String password,
    Uint8List salt, {
    required int iterations,
    required int keyLength,
  }) {
    final passBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passBytes);
    final result = Uint8List(keyLength);

    int blockIndex = 1;
    int offset = 0;

    while (offset < keyLength) {
      final blockIndexBytes = ByteData(4)..setUint32(0, blockIndex, Endian.big);
      final saltPlusBlock = Uint8List.fromList(salt + blockIndexBytes.buffer.asUint8List());

      var u = hmac.convert(saltPlusBlock).bytes;
      final t = Uint8List.fromList(u);

      for (int i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (int j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }

      final copyLength = min(t.length, keyLength - offset);
      result.setRange(offset, offset + copyLength, t.sublist(0, copyLength));
      offset += copyLength;
      blockIndex++;
    }

    return result;
  }

  static Uint8List _computeHmac({required Uint8List hmacKey, required Uint8List data}) {
    final hmac = Hmac(sha256, hmacKey);
    return Uint8List.fromList(hmac.convert(data).bytes);
  }

  static Uint8List _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  static bool _constantTimeCompare(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
