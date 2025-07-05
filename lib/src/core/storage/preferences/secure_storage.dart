import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sparksocial/src/core/storage/preferences/local_storage_interface.dart';
import 'package:synchronized/synchronized.dart';

/// Implementation of LocalStorageInterface using FlutterSecureStorage
/// for storing sensitive data like tokens, credentials, etc.
class SecureStorage implements LocalStorageInterface {
  /// Creates a new SecureStorage instance
  /// If no secureStorage is provided, a default one will be created
  SecureStorage({FlutterSecureStorage? secureStorage}) : _secureStorage = secureStorage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _secureStorage;
  final Lock _lock = Lock();

  @override
  Future<void> setString(String key, String value) async {
    // Use synchronized to prevent concurrent writes that can cause OperationError on web
    await _lock.synchronized(() async {
      await _secureStorage.write(key: key, value: value);
    });
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      // Handle potential OperationError on web platform
      return null;
    }
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _lock.synchronized(() async {
      await _secureStorage.write(key: key, value: value.toString());
    });
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _lock.synchronized(() async {
      await _secureStorage.write(key: key, value: value.toString());
    });
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null ? double.tryParse(value) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _lock.synchronized(() async {
      await _secureStorage.write(key: key, value: value.toString());
    });
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) return null;
      return value.toLowerCase() == 'true';
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    final encoded = jsonEncode(value);
    await _lock.synchronized(() async {
      await _secureStorage.write(key: key, value: encoded);
    });
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) return null;
      try {
        final decoded = jsonDecode(value) as List;
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setObject<T>(String key, T value) async {
    if (value == null) {
      await remove(key);
      return;
    }
    final jsonString = jsonEncode(value);
    await _lock.synchronized(() async {
      await setString(key, jsonString);
    });
  }

  @override
  Future<T?> getObject<T>(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) {
        return null;
      }
      try {
        return jsonDecode(jsonString) as T;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return (await _secureStorage.read(key: key)) != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> remove(String key) async {
    await _lock.synchronized(() async {
      await _secureStorage.delete(key: key);
    });
  }

  @override
  Future<void> clear() async {
    await _lock.synchronized(() async {
      await _secureStorage.deleteAll();
    });
  }
}
