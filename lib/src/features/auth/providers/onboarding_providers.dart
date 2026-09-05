import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';

part 'onboarding_providers.g.dart';

/// Provider for OnboardingRepository
@riverpod
OnboardingRepository onboardingRepository(Ref ref) {
  final repoRepository = GetIt.instance<SprkRepository>().repo;
  final authRepository = GetIt.instance<AuthRepository>();

  return OnboardingRepositoryImpl(
    repoRepository: repoRepository,
    authRepository: authRepository,
  );
}

/// Provider to check if the user has a Spark profile
@riverpod
Future<bool> hasSparkProfile(Ref ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.hasSparkProfile();
}

/// Provider to manage the onboarding state
@riverpod
class OnboardingState extends _$OnboardingState {
  @override
  Future<void> build() async {
    // Initial build does nothing
  }

  /// Import Bluesky profile to create a Spark profile
  Future<void> importProfile(ActorProfileRecord bskyProfile) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(onboardingRepositoryProvider);

      await repository.createSparkProfile(
        displayName: bskyProfile.displayName ?? '',
        description: bskyProfile.description ?? '',
        avatar: bskyProfile.avatar,
      );

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError(e, stackTrace);
    }
  }

  /// Create a custom Spark profile
  Future<void> createCustomProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(onboardingRepositoryProvider);

      await repository.createSparkProfile(
        displayName: displayName,
        description: description,
        avatar: avatar,
      );

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      if (ref.mounted) {
        state = AsyncError(e, stackTrace);
      }
      Error.throwWithStackTrace(e, stackTrace);
    }
  }
}
