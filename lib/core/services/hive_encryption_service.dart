import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class HiveEncryptionService {
  static const _keyName = 'hive_aes_key';
  static final _secureStorage = FlutterSecureStorage();

  static Future<HiveAesCipher> getCipher() async {
    final existingKey = await _secureStorage.read(key: _keyName);

    if (existingKey != null) {
      final key = base64Url.decode(existingKey);
      return HiveAesCipher(key);
    }

    final newKey = Hive.generateSecureKey();
    final encodedKey = base64Url.encode(newKey);
    await _secureStorage.write(key: _keyName, value: encodedKey);
    return HiveAesCipher(newKey);
  }
}
