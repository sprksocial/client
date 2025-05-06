import 'package:get_it/get_it.dart';
import '../storage/storage.dart';

/// Global ServiceLocator instance
final GetIt sl = GetIt.instance;

/// Initializes the service locator with all required dependencies
Future<void> initServiceLocator() async {
  // Register core dependencies
  _registerCore();
  
  // Register network dependencies
  _registerNetwork();
  
  // Register storage dependencies
  _registerStorage();
  
  // As features are migrated, their dependencies will be registered here
}

/// Registers core dependencies
void _registerCore() {
  // Register utilities
  // sl.registerSingleton<SomeUtility>(SomeUtilityImpl());
}

/// Registers network dependencies
void _registerNetwork() {
  // Register network clients and repositories
  // sl.registerSingleton<ApiClient>(ApiClientImpl());
}

/// Registers storage dependencies
void _registerStorage() async {
  // Initialize storage manager
  final storageManager = StorageManager.instance;
  await storageManager.init();
  
  // Register storage manager
  sl.registerSingleton<StorageManager>(storageManager);
  
  // Register cache manager
  sl.registerSingleton<AppCacheManager>(AppCacheManager.instance);
} 