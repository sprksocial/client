import 'cache/download_manager.dart';
import 'cache/sql_cache.dart';
import 'preferences/local_storage_interface.dart';
import 'preferences/shared_prefs_storage.dart';
import 'preferences/secure_storage.dart';

/// Storage manager providing centralized access to different storage implementations
/// This is the one that should be used to store and retrieve data from the app
class StorageManager {
  late final LocalStorageInterface _preferences;
  late final LocalStorageInterface _secureStorage;
  late final SQLCache _sqlCache;
  late final DownloadManager _downloadManager;

  /// Private constructor
  StorageManager._();

  /// Singleton instance
  static final StorageManager _instance = StorageManager._();

  /// Get the singleton instance
  static StorageManager get instance => _instance;

  /// Initialize the storage manager
  Future<void> init() async {
    _preferences = await SharedPrefsStorage.create();
    _secureStorage = SecureStorage();
    _sqlCache = SQLCache();
    await _sqlCache.database;

    _downloadManager = DownloadManager();
    await _downloadManager.init();
  }

  /// Access to shared preferences storage for non-sensitive data
  LocalStorageInterface get preferences => _preferences;

  /// Access to secure storage for sensitive data
  LocalStorageInterface get secure => _secureStorage;

  /// Access to the SQL cache
  SQLCache get sqlCache => _sqlCache;

  /// Access to the download manager
  DownloadManager get downloadManager => _downloadManager;
}
