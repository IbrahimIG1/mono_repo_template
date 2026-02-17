import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorageHelper {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save a key-value pair
  static Future<void> saveToken(String key, String value) async {
    log(" Saving key: $key with value: $value");
    await _storage.write(key: key, value: value);
  }

  // Get the value for a specific key
  static Future<String> getToken(String key) async {
    String token=  await _storage.read(key: key)??"";
    return token;
  }

  // Delete a specific key-value pair
  static Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all saved data
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
