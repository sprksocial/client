import 'package:spark/src/core/storage/preferences/local_storage_interface.dart';

/// Small deterministic storage fake shared by tests that exercise persistence.
class InMemoryStorage implements LocalStorageInterface {
  final Map<String, Object?> values = <String, Object?>{};

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => values[key] as double?;

  @override
  Future<int?> getInt(String key) async => values[key] as int?;

  @override
  Future<T?> getObject<T>(String key) async => values[key] as T?;

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = values[key] as List<dynamic>?;
    return value?.cast<String>();
  }

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;

  @override
  Future<void> setDouble(String key, double value) async => values[key] = value;

  @override
  Future<void> setInt(String key, int value) async => values[key] = value;

  @override
  Future<void> setObject<T>(String key, T value) async => values[key] = value;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      values[key] = List<String>.of(value);
}
