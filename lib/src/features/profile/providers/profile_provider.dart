import 'dart:async';

import 'package:atproto/com_atproto_admin_defs.dart';
import 'package:atproto/com_atproto_moderation_createreport.dart';
import 'package:atproto/com_atproto_moderation_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';
import 'package:spark/src/features/profile/providers/profile_state.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  ProfileNotifier() {
    authRepository = GetIt.instance<AuthRepository>();
    actorRepository = GetIt.instance<ActorRepository>();
    sprkRepository = GetIt.instance<SprkRepository>();
    logger = GetIt.instance<LogService>().getLogger('ProfileNotifier');
  }
  late final AuthRepository authRepository;
  late final ActorRepository actorRepository;
  late final SprkRepository sprkRepository;
  late final SparkLogger logger;

  @override
  Future<ProfileState> build({String? did}) async {
    logger.d('Building ProfileNotifier for did: $did');
    final initialState = ProfileState(currentViewDid: did);
    await loadProfileData(did, initialState);
    // Return the state value if available, otherwise return initial state
    // This handles edge cases where loadProfileData sets an error/auth prompt
    return state.asData?.value ?? initialState;
  }

  Future<void> loadProfileData(
    String? targetDidArgument,
    ProfileState currentState,
  ) async {
    final effectiveDid = targetDidArgument ?? authRepository.did;

    if (!authRepository.isAuthenticated && effectiveDid == null) {
      logger.i(
        'User not authenticated and no DID provided, showing auth prompt.',
      );
      state = AsyncData(currentState.copyWith(showAuthPrompt: true));
      return;
    }

    if (effectiveDid == null) {
      logger.w('No profile DID specified and user not logged in.');
      state = AsyncError('No profile specified', StackTrace.current);
      return;
    }

    try {
      logger.d('Loading profile for DID: $effectiveDid');
      final profile = await actorRepository.getProfile(effectiveDid);

      logger.d(
        'Profile loaded successfully for $effectiveDid: ${profile.handle}',
      );

      state = AsyncData(
        currentState.copyWith(
          profile: profile,
          showAuthPrompt: false,
          currentViewDid: effectiveDid,
        ),
      );
    } catch (e, s) {
      logger.e(
        'Error loading profile for DID: $effectiveDid',
        error: e,
        stackTrace: s,
      );
      state = AsyncError(e, s);
    }
  }

  Future<void> refreshProfile() async {
    final currentProfileState = state.asData?.value;
    final currentDid = currentProfileState?.currentViewDid;
    logger.d('Refreshing profile for DID: $currentDid');

    final didToRefresh = currentDid ?? authRepository.did;
    if (didToRefresh == null) {
      logger.w('Cannot refresh, no DID available.');
      return;
    }

    try {
      final profileUri = AtUri.parse('at://$didToRefresh');

      // Invalidate feed providers to force a rebuild rather than calling
      // notifier methods directly, which can fail if providers are disposed
      ref
        ..invalidate(profileFeedProvider(profileUri, true))
        ..invalidate(profileFeedProvider(profileUri, false));

      // Load profile data
      await loadProfileData(
        didToRefresh,
        currentProfileState ?? ProfileState(currentViewDid: didToRefresh),
      );

      logger.i('Profile for $didToRefresh refreshed successfully.');
    } catch (e, s) {
      logger.e(
        'Error refreshing profile for $didToRefresh',
        error: e,
        stackTrace: s,
      );
      // If we have current data, keep it; otherwise show error
      if (currentProfileState == null) {
        state = AsyncError(e, s);
      }
    }
  }

  void hideAuthPrompt() {
    final currentData = state.asData?.value;
    if (currentData != null) {
      state = AsyncData(currentData.copyWith(showAuthPrompt: false));
    }
  }

  bool isCurrentUser() {
    final profileDid = state.asData?.value.profile?.did;
    if (profileDid == null) return false;
    return authRepository.isAuthenticated && authRepository.did == profileDid;
  }

  Future<String?> toggleFollow() async {
    final currentData = state.asData!.value;
    final profile = currentData.profile;

    if (profile == null) {
      logger.w('Cannot toggle follow, profile not loaded.');
      throw Exception('Profile not loaded, cannot toggle follow.');
    }
    if (!authRepository.isAuthenticated) {
      logger.i(
        'User not authenticated, showing auth prompt for follow action.',
      );
      state = AsyncData(currentData.copyWith(showAuthPrompt: true));
      return null;
    }

    logger.d(
      'Toggling follow for profile: ${profile.did}, '
      'current follow URI: ${profile.viewer?.following ?? 'none'}',
    );
    final originalStateValue = currentData;

    try {
      final newFollowUriResult = await sprkRepository.graph.toggleFollow(
        profile.did,
        profile.viewer?.following,
      );

      if (newFollowUriResult != null) {
        logger.i(
          'Successfully followed ${profile.did}. '
          'New follow URI: $newFollowUriResult',
        );
      } else {
        logger.i('Successfully unfollowed ${profile.did}.');
      }

      // Update state optimistically first
      final optimisticViewer =
          profile.viewer?.copyWith(
            following: newFollowUriResult != null
                ? AtUri.parse(newFollowUriResult)
                : null,
          ) ??
          ActorViewer(
            following: newFollowUriResult != null
                ? AtUri.parse(newFollowUriResult)
                : null,
          );

      final optimisticProfile = profile.copyWith(viewer: optimisticViewer);
      state = AsyncData(
        originalStateValue.copyWith(profile: optimisticProfile),
      );

      // Then refresh the profile data in the background to ensure consistency
      // Use a small delay to allow backend to propagate changes
      // Note: This is intentionally unawaited - we use optimistic updates above
      // & refresh in the background. If this fails, optimistic state remains.
      unawaited(
        Future.delayed(const Duration(milliseconds: 500)).then((_) async {
          try {
            final refreshedProfile = await actorRepository.getProfile(
              profile.did,
            );

            // Only update if state hasn't changed (user hasn't navigated away)
            final currentState = state.asData?.value;
            if (currentState?.profile?.did == profile.did) {
              state = AsyncData(
                currentState!.copyWith(profile: refreshedProfile),
              );
            }
          } catch (e) {
            logger.w('Background profile refresh failed: $e');
            // Keep the optimistic state if refresh fails
          }
        }),
      );

      return newFollowUriResult;
    } catch (e, s) {
      logger.e(
        'Error toggling follow for ${profile.did}',
        error: e,
        stackTrace: s,
      );
      state = AsyncData(originalStateValue);
      throw Exception('Failed to toggle follow: $e');
    }
  }

  Future<String?> toggleBlock() async {
    final currentData = state.asData!.value;
    final profile = currentData.profile;

    if (profile == null) {
      logger.w('Cannot toggle block, profile not loaded.');
      throw Exception('Profile not loaded, cannot toggle block.');
    }
    if (!authRepository.isAuthenticated) {
      logger.i('User not authenticated, showing auth prompt for block action.');
      state = AsyncData(currentData.copyWith(showAuthPrompt: true));
      return null;
    }

    logger.d(
      'Toggling block for profile: ${profile.did}, '
      'current block URI: ${profile.viewer?.blocking ?? 'none'}',
    );
    final originalStateValue = currentData;

    try {
      final newBlockUriResult = await sprkRepository.graph.toggleBlock(
        profile.did,
        profile.viewer?.blocking,
      );

      if (newBlockUriResult != null) {
        logger.i(
          'Successfully blocked ${profile.did}. '
          'New block URI: $newBlockUriResult',
        );
      } else {
        logger.i('Successfully unblocked ${profile.did}.');
      }

      // Update state optimistically first
      final optimisticViewer =
          profile.viewer?.copyWith(
            blocking: newBlockUriResult != null
                ? AtUri.parse(newBlockUriResult)
                : null,
          ) ??
          ActorViewer(
            blocking: newBlockUriResult != null
                ? AtUri.parse(newBlockUriResult)
                : null,
          );

      final optimisticProfile = profile.copyWith(viewer: optimisticViewer);
      state = AsyncData(
        originalStateValue.copyWith(profile: optimisticProfile),
      );

      // Then refresh the profile data in the background to ensure consistency
      // Use a small delay to allow backend to propagate changes
      // Note: This is intentionally unawaited - we use optimistic updates above
      // & refresh in the background. If this fails, optimistic state remains.
      unawaited(
        Future.delayed(const Duration(milliseconds: 500)).then((_) async {
          try {
            final refreshedProfile = await actorRepository.getProfile(
              profile.did,
            );

            // Only update if state hasn't changed (user hasn't navigated away)
            final currentState = state.asData?.value;
            if (currentState?.profile?.did == profile.did) {
              state = AsyncData(
                currentState!.copyWith(profile: refreshedProfile),
              );
            }
          } catch (e) {
            logger.w('Background profile refresh failed: $e');
            // Keep the optimistic state if refresh fails
          }
        }),
      );

      return newBlockUriResult;
    } catch (e, s) {
      logger.e(
        'Error toggling block for ${profile.did}',
        error: e,
        stackTrace: s,
      );
      state = AsyncData(originalStateValue);
      throw Exception('Failed to toggle block: $e');
    }
  }

  Future<bool> createReport({
    required String did,
    required ReasonType reasonType,
    String? reason,
  }) async {
    if (!authRepository.isAuthenticated) {
      logger.w('Cannot create report, user not authenticated');
      final currentData = state.asData?.value;
      if (currentData != null) {
        state = AsyncData(currentData.copyWith(showAuthPrompt: true));
      }
      return false;
    }

    try {
      logger.d('Creating report for DID: $did with reason: $reasonType');
      final subject = UModerationCreateReportSubject.repoRef(
        data: RepoRef(did: did),
      );
      final result = await sprkRepository.repo.createReport(
        input: ModerationCreateReportInput(
          subject: subject,
          reasonType: reasonType,
          reason: reason,
        ),
      );
      logger.i('Report created successfully for $did');
      return result;
    } catch (e, s) {
      logger.e('Error creating report for $did', error: e, stackTrace: s);
      throw Exception('Failed to create report: $e');
    }
  }

  Future<void> logout() async {
    logger.i('User logging out.');
    await authRepository.logout();

    final currentProfileState = state.asData?.value;
    final currentDid = currentProfileState?.currentViewDid;

    await loadProfileData(
      currentDid,
      currentProfileState ?? ProfileState(currentViewDid: currentDid),
    );
  }

  void triggerAuthPrompt() {
    final currentData = state.asData?.value;
    if (currentData != null) {
      state = AsyncData(currentData.copyWith(showAuthPrompt: true));
      logger.i('Auth prompt triggered from notifier.');
    } else {
      logger.i(
        'Auth prompt trigger requested, but no current data state to update.',
      );
    }
  }
}
