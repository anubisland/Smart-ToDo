import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class BackupCipher {
  const BackupCipher._();

  static const format = 'anubisland-smart-todo-encrypted-backup';
  static const _version = 1;
  static const _memoryKiB = 32000;
  static const _iterations = 3;
  static const _parallelism = 1;
  static const _hashLength = 32;

  static Future<Map<String, Object?>> encrypt(
    Map<String, Object?> backup,
    String password,
  ) async {
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final cipher = AesGcm.with256bits();
    final key = await _deriveKey(password, salt);
    final secretBox = await cipher.encrypt(
      utf8.encode(jsonEncode(backup)),
      secretKey: key,
    );
    return {
      'format': format,
      'version': _version,
      'cipher': 'aes-256-gcm',
      'kdf': 'argon2id',
      'memory_kib': _memoryKiB,
      'iterations': _iterations,
      'parallelism': _parallelism,
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  static Future<Map<String, dynamic>> decrypt(
    Map<String, dynamic> envelope,
    String password,
  ) async {
    if (envelope['format'] != format ||
        envelope['version'] != _version ||
        envelope['cipher'] != 'aes-256-gcm' ||
        envelope['kdf'] != 'argon2id' ||
        envelope['memory_kib'] != _memoryKiB ||
        envelope['iterations'] != _iterations ||
        envelope['parallelism'] != _parallelism) {
      throw const FormatException('Unsupported encrypted backup.');
    }

    final salt = base64Decode(envelope['salt'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final ciphertext = base64Decode(envelope['ciphertext'] as String);
    final mac = base64Decode(envelope['mac'] as String);
    if (salt.length != 16 || nonce.length != 12 || mac.length != 16) {
      throw const FormatException('Invalid encrypted backup data.');
    }

    final key = await _deriveKey(password, salt);
    final clearText = await AesGcm.with256bits().decrypt(
      SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
      secretKey: key,
    );
    final decoded = jsonDecode(utf8.decode(clearText));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup contents.');
    }
    return decoded;
  }

  static Future<SecretKey> _deriveKey(String password, List<int> salt) =>
      Argon2id(
        memory: _memoryKiB,
        parallelism: _parallelism,
        iterations: _iterations,
        hashLength: _hashLength,
      ).deriveKeyFromPassword(password: password, nonce: salt);
}
