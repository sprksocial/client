import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage_interface.dart';

/// Implementation of LocalStorageInterface using SharedPreferences
class SharedPrefsStorage implements LocalStorageInterface {
  final SharedPreferences _prefs;

  SharedPrefsStorage(this._prefs);

  /// Factory constructor to create a SharedPrefsStorage instance
  static Future<SharedPrefsStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsStorage(prefs);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  @override
  Future<void> setObject<T>(String key, T value, T Function(Map<String, dynamic> json) fromJson) async {
    if (value == null) {
      await remove(key);
      return;
    }
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  @override
  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) async {
    final jsonString = await getString(key);
    if (jsonString == null) {
      return null;
    }
    try {
      return fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
} 