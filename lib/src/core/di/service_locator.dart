import 'package:get_it/get_it.dart';
import '../storage/storage.dart';
import '../theme/theme_provider.dart';
import '../network/auth_service.dart';
import '../network/sprk_client.dart';
import '../utils/logging/log_service.dart';

/// Global ServiceLocator instance
final GetIt sl = GetIt.instance;

/// Initializes the service locator with all required dependencies
Future<void> initServiceLocator() async {
  // Register core dependencies
  _registerCore();
  
  // Register network dependencies
  _registerNetwork();
  
  // Register storage dependencies
  await _registerStorage();
  
  // Register logging dependencies
  _registerLogging();
  
  // As features are migrated, their dependencies will be registered here
}

/// Registers core dependencies
void _registerCore() {
  // Register theme notifier
  sl.registerSingleton<ThemeNotifier>(
    ThemeNotifier(sl<StorageManager>())
  );
}

/// Registers network dependencies
void _registerNetwork() {
  // Register AuthService
  sl.registerSingleton<AuthService>(AuthService());
  
  // Register SprkClient
  sl.registerSingleton<SprkClient>(SprkClient(sl<AuthService>()));
}

/// Registers storage dependencies
Future<void> _registerStorage() async {
  // Initialize storage manager
  final storageManager = StorageManager.instance;
  await storageManager.init();
  
  // Register storage manager
  sl.registerSingleton<StorageManager>(storageManager);
  
  // Register cache manager
  sl.registerSingleton<AppCacheManager>(AppCacheManager.instance);
}

/// Registers logging dependencies
void _registerLogging() {
  // Register LogService
  sl.registerSingleton<LogService>(LogService());
} 