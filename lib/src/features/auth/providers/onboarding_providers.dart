import 'package:bluesky/app_bsky_actor_profile.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/graph_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';

part 'onboarding_providers.g.dart';

/// Provider for OnboardingRepository
@riverpod
OnboardingRepository onboardingRepository(Ref ref) {
  final repoRepository = GetIt.instance<SprkRepository>().repo;
  final authRepository = GetIt.instance<AuthRepository>();

  return OnboardingRepositoryImpl(repoRepository: repoRepository, authRepository: authRepository);
}

/// Provider to check if the user has a Spark profile
@riverpod
Future<bool> hasSparkProfile(Ref ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.hasSparkProfile();
}

/// Provider to get the user's Bluesky profile for import
@riverpod
Future<ActorProfileRecord?> bskyProfile(Ref ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getBskyProfile() as ActorProfileRecord?;
}

/// Provider to get Bluesky follows
@riverpod
Future<FollowsResponse> bskyFollows(Ref ref, {String? cursor}) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getBskyFollows(cursor: cursor) as FollowsResponse;
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

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// Create a custom Spark profile
  Future<void> createCustomProfile({required String displayName, required String description, dynamic avatar}) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(onboardingRepositoryProvider);

      await repository.createSparkProfile(displayName: displayName, description: description, avatar: avatar);

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// Import follows from Bluesky
  Future<void> importFollows() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(onboardingRepositoryProvider);
      String? cursor;
      var hasMore = true;

      // Loop to get all follows with pagination
      while (hasMore) {
        final bskyFollows = await repository.getBskyFollows(cursor: cursor);

        // Create a follow record for each DID
        for (final follow in bskyFollows.follows) {
          await repository.createSparkFollow(follow.did);
        }

        cursor = bskyFollows.cursor;
        hasMore = cursor != null;
      }

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}
