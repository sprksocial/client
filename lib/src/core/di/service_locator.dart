import 'package:get_it/get_it.dart';
import 'package:pool/pool.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_impl.dart';
import 'package:sparksocial/src/core/storage/cache/download_manager.dart';
import 'package:sparksocial/src/core/theme/data/repositories/theme_repository.dart';
import 'package:sparksocial/src/core/theme/data/repositories/theme_repository_impl.dart';
import 'package:sparksocial/src/core/settings/repositories/settings_repository.dart';
import 'package:sparksocial/src/features/auth/auth.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/network/atproto.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository_impl.dart';
import 'package:sparksocial/src/core/settings/repositories/settings_repository_impl.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository_impl.dart';
import 'package:sparksocial/src/core/network/data/repositories/actor_repository_impl.dart';
import 'package:sparksocial/src/core/network/data/repositories/graph_repository_impl.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';

// This is the ONLY PLACE IN THE ENTIRE APP where implementations are imported
// All the other files should import interfaces only (polymorphism) to keep everything decoupled

/// Global ServiceLocator instance
final GetIt sl = GetIt.instance;

/// Initializes the service locator with all required dependencies
/// sl.registerSingleton < Interface > (Implementation)
Future<void> initServiceLocator() async {
  // Register storage dependencies
  // Initialize storage manager
  final storageManager = StorageManager.instance;
  await storageManager.init();

  final sqlCache = SQLCache();
  await sqlCache.database;
  sl.registerSingleton<SQLCache>(sqlCache);

  sl.registerSingleton<DownloadManager>(DownloadManager());

  // Register storage manager
  sl.registerSingleton<StorageManager>(storageManager);

  // Register cache manager
  sl.registerSingleton<CacheManagerInterface>(CacheManagerImpl.instance);

  // Register logging dependencies
  // Register LogService
  sl.registerSingleton<LogService>(LogService());

  // Register network dependencies
  // Register AuthRepository
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Register SprkRepository with its interface
  sl.registerSingleton<SprkRepository>(SprkRepositoryImpl(sl<AuthRepository>()));

  // Register identity repository
  sl.registerSingleton<IdentityRepository>(IdentityRepositoryImpl(sl<StorageManager>()));

  // Register theme repository
  sl.registerSingleton<ThemeRepository>(ThemeRepositoryImpl(sl<StorageManager>()));

  // Register ActorRepository
  sl.registerSingleton<ActorRepository>(ActorRepositoryImpl(sl.get<SprkRepository>()));

  // Register GraphRepository
  sl.registerSingleton<GraphRepository>(GraphRepositoryImpl(sl.get<SprkRepository>()));

  // Register SettingsRepository
  sl.registerSingleton<SettingsRepository>(SettingsRepositoryImpl(sl<StorageManager>()));

  // Register OnboardingRepository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(repoRepository: sl<SprkRepository>().repo, authRepository: sl<AuthRepository>()),
  );
}
