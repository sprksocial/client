/// Interface defining local storage operations
/// (in case we need to change the storage provider)
abstract class LocalStorageInterface {
  /// Store a string value with the provided key
  Future<void> setString(String key, String value);

  /// Retrieve a string value for the provided key
  Future<String?> getString(String key);

  /// Store an integer value with the provided key
  Future<void> setInt(String key, int value);

  /// Retrieve an integer value for the provided key
  Future<int?> getInt(String key);

  /// Store a double value with the provided key
  Future<void> setDouble(String key, double value);

  /// Retrieve a double value for the provided key
  Future<double?> getDouble(String key);

  /// Store a boolean value with the provided key
  Future<void> setBool(String key, bool value);

  /// Retrieve a boolean value for the provided key
  Future<bool?> getBool(String key);

  /// Store a list of strings with the provided key
  Future<void> setStringList(String key, List<String> value);

  /// Retrieve a list of strings for the provided key
  Future<List<String>?> getStringList(String key);

  /// Store any object that can be serialized to JSON
  Future<void> setObject<T>(String key, T value, T Function(Map<String, dynamic> json) fromJson);

  /// Retrieve and deserialize a JSON object
  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson);

  /// Check if key exists in storage
  Future<bool> containsKey(String key);

  /// Remove a specific key from storage
  Future<void> remove(String key);

  /// Clear all stored data
  Future<void> clear();
}
