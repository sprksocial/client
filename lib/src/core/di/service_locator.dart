import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_impl.dart';
import 'package:sparksocial/src/core/storage/cache/download_manager_interface.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/theme/data/repositories/theme_repository.dart';
import 'package:sparksocial/src/core/theme/data/repositories/theme_repository_impl.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/features/auth/auth.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository_impl.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/actor_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/graph_repository_impl.dart';
import 'package:sparksocial/src/core/network/messages/data/services/chat_socket_service.dart';
import 'package:sparksocial/src/core/network/messages/data/services/chat_api_service.dart';
import 'package:sparksocial/src/core/network/messages/data/repositories/chat_repository.dart';
import 'package:sparksocial/src/core/network/messages/data/repositories/chat_repository_impl.dart';

// This is the ONLY PLACE IN THE ENTIRE APP where implementations are imported
// All the other files should import interfaces only (polymorphism) to keep everything decoupled

/// Global ServiceLocator instance
final GetIt sl = GetIt.instance;

/// Initializes the service locator with all required dependencies
/// sl.registerSingleton < Interface > (Implementation)
Future<void> initServiceLocator() async {
  // Register LogService
  sl.registerSingleton<LogService>(LogService());

  // Register storage dependencies
  // Initialize storage manager
  final storageManager = StorageManager.instance;
  await storageManager.init();

  final sqlCache = SQLCacheImpl();
  await sqlCache.database;
  sl.registerSingleton<SQLCacheInterface>(sqlCache);

  // Register cache manager
  sl.registerSingleton<CacheManagerInterface>(CacheManagerImpl.instance);

  final downloadManager = DownloadManagerImpl();
  sl.registerSingleton<DownloadManagerInterface>(downloadManager);

  // Register storage manager
  sl.registerSingleton<StorageManager>(storageManager);

  // Register network dependencies
  // Register AuthRepository
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Register Chat dependencies
  sl.registerLazySingleton<ChatSocketService>(() => ChatSocketService());
  sl.registerLazySingleton<ChatApiService>(() => ChatApiService());
  sl.registerSingleton<ChatRepository>(ChatRepositoryImpl());

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
  sl.registerSingleton<SettingsRepository>(SettingsRepositoryImpl());
  await downloadManager.init();

  // Register OnboardingRepository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(repoRepository: sl<SprkRepository>().repo, authRepository: sl<AuthRepository>()),
  );
}
