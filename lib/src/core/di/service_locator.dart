import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/auth/repositories/auth_repository_impl.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_impl.dart';
import 'package:sparksocial/src/core/theme/data/repositories/theme_repository.dart';
import 'package:sparksocial/src/core/theme/data/repositories/theme_repository_impl.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/settings/data/repositories/settings_repository.dart';
import 'package:sparksocial/src/core/network/auth/auth.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/network/network.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';
import 'package:sparksocial/src/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:sparksocial/src/features/settings/data/repositories/labeler_repository.dart';
import 'package:sparksocial/src/features/settings/data/repositories/labeler_repository_impl.dart';

// This is the ONLY PLACE IN THE ENTIRE APP where implementations are imported
// All the other files should import interfaces only (polymorphism) to keep everything decoupled

/// Global ServiceLocator instance
final GetIt sl = GetIt.instance;

/// Initializes the service locator with all required dependencies
/// sl.registerSingleton < Interface > (Implementation)
Future<void> initServiceLocator() async {
  // Register core dependencies
  await _registerCore();
  
  // Register features dependencies
  await _registerFeatures();
}

/// Registers features dependencies
Future<void> _registerFeatures() async {
  // Register settings dependencies
  await _registerSettings();
  
}

/// Registers core dependencies
Future<void> _registerCore() async {
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
  sl.registerSingleton<SprkRepository>(SprkRepositoryImpl(sl<AuthRepository>()));
  
  // Register identity repository
  sl.registerSingleton<IdentityRepository>(
    IdentityRepositoryImpl(sl<StorageManager>())
  );

  // Register theme repository
  sl.registerSingleton<ThemeRepository>(
    ThemeRepositoryImpl(sl<StorageManager>())
  );
  
  // TODO: this should not exist
  sl.registerSingleton<AuthNotifier>(
    AuthNotifier(sl<AuthRepository>())
  );
}

/// Registers settings dependencies
Future<void> _registerSettings() async {
  // Register SettingsRepository
  sl.registerSingleton<SettingsRepository>(
    SettingsRepositoryImpl(sl<StorageManager>())
  );
  
  // Register labeler repository
  sl.registerLazySingleton<LabelerRepository>(
    () => LabelerRepositoryImpl(sl<SprkRepository>(), StorageManager.instance),
  );
}

