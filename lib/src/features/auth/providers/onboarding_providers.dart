import 'package:bluesky/bluesky.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/graph_models.dart';
import '../../../core/network/data/repositories/sprk_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/onboarding_repository_impl.dart';
import '../data/repositories/onboarding_repository.dart';

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
Future<ProfileRecord?> bskyProfile(Ref ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  final profileData = await repository.getBskyProfile();

  if (profileData == null) return null;

  return profileData;
}

/// Provider to get Bluesky follows
@riverpod
Future<FollowsResponse> bskyFollows(Ref ref, {String? cursor}) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getBskyFollows(cursor: cursor);
}

/// Provider to manage the onboarding state
@riverpod
class OnboardingState extends _$OnboardingState {
  @override
  Future<void> build() async {
    // Initial build does nothing
    return;
  }

  /// Import Bluesky profile to create a Spark profile
  Future<void> importProfile(ProfileRecord bskyProfile) async {
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
      bool hasMore = true;

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
