import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/actor_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/graph_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/pref_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/story_repository_impl.dart';
import 'package:sparksocial/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:sparksocial/src/core/network/messages/data/repository/messages_repository_xrpc.dart';
import 'package:sparksocial/src/core/network/xrpc/service_auth_helper.dart';
import 'package:sparksocial/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:sparksocial/src/core/pro_video_editor/pro_video_editor_repository_impl.dart';
import 'package:sparksocial/src/core/storage/cache/download_manager_interface.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/ui/theme/data/repositories/theme_repository.dart';
import 'package:sparksocial/src/core/ui/theme/data/repositories/theme_repository_impl.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/auth/auth.dart';

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

  final downloadManager = DownloadManagerImpl();
  sl.registerSingleton<DownloadManagerInterface>(downloadManager);

  // Register storage manager
  sl.registerSingleton<StorageManager>(storageManager);

  // Register network dependencies
  // Register AuthRepository
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Register service auth helper for XRPC
  sl.registerSingleton<ServiceAuthHelper>(ServiceAuthHelper(sl<AuthRepository>()));

  // Register Chat dependencies with XRPC implementation
  sl.registerSingleton<MessagesRepository>(MessagesRepositoryXrpc(sl<ServiceAuthHelper>()));

  // Register SprkRepository with its interface
  sl.registerSingleton<SprkRepository>(SprkRepositoryImpl(sl<AuthRepository>()));

  // Register PrefRepository
  sl.registerSingleton<PrefRepository>(PrefRepositoryImpl(sl<SprkRepository>()));

  // Register identity repository
  sl.registerSingleton<IdentityRepository>(IdentityRepositoryImpl(sl<StorageManager>()));

  // Register theme repository
  sl.registerSingleton<ThemeRepository>(ThemeRepositoryImpl(sl<StorageManager>()));

  // Register ActorRepository
  sl.registerSingleton<ActorRepository>(ActorRepositoryImpl(sl.get<SprkRepository>()));

  // Register GraphRepository
  sl.registerSingleton<GraphRepository>(GraphRepositoryImpl(sl.get<SprkRepository>()));

  // Register StoryRepository
  sl.registerSingleton<StoryRepository>(StoryRepositoryImpl(sl.get<SprkRepository>()));

  await downloadManager.init();

  // Register OnboardingRepository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(repoRepository: sl<SprkRepository>().repo, authRepository: sl<AuthRepository>()),
  );

  // Register ProVideoEditorRepository (image/video editing abstraction)
  sl.registerSingleton<ProVideoEditorRepository>(const ProVideoEditorRepositoryImpl());
}
