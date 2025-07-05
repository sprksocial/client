import 'package:sparksocial/src/core/storage/preferences/local_storage_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/secure_storage.dart';
import 'package:sparksocial/src/core/storage/preferences/shared_prefs_storage.dart';

/// Storage manager providing centralized access to different storage implementations
/// This is the one that should be used to store and retrieve data from the app
class StorageManager {
  /// Private constructor
  StorageManager._();
  late final LocalStorageInterface _preferences;
  late final LocalStorageInterface _secureStorage;

  /// Singleton instance
  static final StorageManager _instance = StorageManager._();

  /// Get the singleton instance
  static StorageManager get instance => _instance;

  /// Initialize the storage manager
  Future<void> init() async {
    _preferences = await SharedPrefsStorage.create();
    _secureStorage = SecureStorage();
  }

  /// Access to shared preferences storage for non-sensitive data
  LocalStorageInterface get preferences => _preferences;

  /// Access to secure storage for sensitive data
  LocalStorageInterface get secure => _secureStorage;
}
