import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStore {
  SecureKeyStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _dbKeyName = 'offline_assistant.db_encryption_key';
  static const _messageKeyName = 'offline_assistant.message_key';

  Future<String> getOrCreateDatabaseKey() => _getOrCreate(_dbKeyName, length: 64);

  Future<String> getOrCreateMessageKey() => _getOrCreate(_messageKeyName, length: 32);

  Future<String> _getOrCreate(String key, {required int length}) async {
    final existing = await _storage.read(key: key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final idx = random.nextInt(chars.length);
      buffer.write(chars[idx]);
    }
    final generated = buffer.toString();
    await _storage.write(key: key, value: generated);
    return generated;
  }
}
