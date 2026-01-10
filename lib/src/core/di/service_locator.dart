import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository_impl.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository_impl.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository.dart';
import 'package:spark/src/core/network/messages/data/repository/messages_repository_xrpc.dart';
import 'package:spark/src/core/network/xrpc/service_auth_helper.dart';
import 'package:spark/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:spark/src/core/pro_video_editor/pro_video_editor_repository_impl.dart';
import 'package:spark/src/core/storage/cache/download_manager_interface.dart';
import 'package:spark/src/core/storage/storage.dart';
import 'package:spark/src/core/ui/theme/data/repositories/theme_repository.dart';
import 'package:spark/src/core/ui/theme/data/repositories/theme_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/auth/auth.dart';

// This is the ONLY PLACE IN THE ENTIRE APP where implementations are imported
// All the other files should import interfaces only (polymorphism).

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
  sl
    ..registerSingleton<DownloadManagerInterface>(downloadManager)
    ..registerSingleton<StorageManager>(storageManager)
    ..registerSingleton<AuthRepository>(AuthRepositoryImpl())
    ..registerSingleton<ServiceAuthHelper>(
      ServiceAuthHelper(sl<AuthRepository>()),
    )
    ..registerSingleton<MessagesRepository>(
      MessagesRepositoryXrpc(sl<ServiceAuthHelper>()),
    )
    ..registerSingleton<SprkRepository>(
      SprkRepositoryImpl(sl<AuthRepository>()),
    )
    ..registerSingleton<PrefRepository>(
      PrefRepositoryImpl(sl<SprkRepository>()),
    )
    ..registerSingleton<IdentityRepository>(
      IdentityRepositoryImpl(sl<StorageManager>()),
    )
    ..registerSingleton<ThemeRepository>(
      ThemeRepositoryImpl(sl<StorageManager>()),
    )
    ..registerSingleton<ActorRepository>(
      ActorRepositoryImpl(sl.get<SprkRepository>()),
    )
    ..registerSingleton<GraphRepository>(
      GraphRepositoryImpl(sl.get<SprkRepository>()),
    )
    ..registerSingleton<StoryRepository>(
      StoryRepositoryImpl(sl.get<SprkRepository>()),
    )
    ..registerSingleton<SoundRepository>(
      SoundRepositoryImpl(sl.get<SprkRepository>()),
    );

  await downloadManager.init();

  sl
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(
        repoRepository: sl<SprkRepository>().repo,
        authRepository: sl<AuthRepository>(),
      ),
    )
    ..registerSingleton<ProVideoEditorRepository>(
      const ProVideoEditorRepositoryImpl(),
    );
}
