import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/storage/cache_manager_interface.dart';
import '../auth/auth.dart';
import '../storage/storage.dart';
import '../theme/theme.dart';
import '../network/network.dart' hide SprkRepository;
import '../utils/logging/logging.dart';
import '../network/sprk_repository_interface.dart';
import '../network/sprk_repository_impl.dart';
import '../../features/settings/data/repositories/settings_repository.dart';

/// Global ServiceLocator instance
final GetIt sl = GetIt.instance;

/// Initializes the service locator with all required dependencies
Future<void> initServiceLocator() async {
  // Register core dependencies
  await _registerCore();
  
  // Register features dependencies
  await _registerFeatures();
  
  // As features are migrated, their dependencies will be registered here
}

/// Registers features dependencies
Future<void> _registerFeatures() async {
  // Register settings dependencies
  await _registerSettings();
}

/// Registers core dependencies
Future<void> _registerCore() async {
  // Register theme notifier
  sl.registerSingleton<ThemeNotifier>(
    ThemeNotifier(sl<StorageManager>())
  );
  
  // Register storage dependencies
  // Initialize storage manager
  final storageManager = StorageManager.instance;
  await storageManager.init();
  
  // Register storage manager
  sl.registerSingleton<StorageManager>(storageManager);
  
  // Register cache manager
  sl.registerSingleton<CacheManagerInterface>(AppCacheManager.instance);
  
  // Register logging dependencies
  // Register LogService
  sl.registerSingleton<LogService>(LogService());
  
  // Register network dependencies
  // Register AuthRepository
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  
  // Register SprkRepository with its interface
  sl.registerSingleton<SprkRepositoryInterface>(SprkRepository(sl<AuthRepository>()));
  
  // Register core repositories from SprkRepository
  sl.registerLazySingleton<ActorRepositoryInterface>(
    () => sl<SprkRepositoryInterface>().actor
  );
  
  sl.registerLazySingleton<RepoRepositoryInterface>(
    () => sl<SprkRepositoryInterface>().repo
  );
  
  // Register auth dependencies
  // Register AuthNotifier
  sl.registerSingleton<AuthNotifier>(
    AuthNotifier(sl<AuthRepository>())
  );
}

/// Registers settings dependencies
Future<void> _registerSettings() async {
  // Register SettingsRepository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(sl<StorageManager>())
  );
}
