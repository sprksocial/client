import 'dart:async';

import 'package:atproto/atproto.dart' as atp;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/profile/data/repositories/profile_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/features/profile/providers/profile_state.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final SprkRepository sprkRepository;
  late final SparkLogger logger;

  ProfileNotifier() {
    authRepository = GetIt.instance<AuthRepository>();
    profileRepository = GetIt.instance<ProfileRepository>();
    sprkRepository = GetIt.instance<SprkRepository>();
    logger = GetIt.instance<LogService>().getLogger('ProfileNotifier');
  }

  @override
  Future<ProfileState> build({String? did}) async {
    logger.d('Building ProfileNotifier for did: $did');
    final initialState = ProfileState(currentViewDid: did);
    await loadProfileData(did, initialState);
    return state.asData!.value;
  }

  Future<void> loadProfileData(String? targetDidArgument, ProfileState currentState) async {
    final String? effectiveDid = targetDidArgument ?? authRepository.session?.did;

    if (!authRepository.isAuthenticated && effectiveDid == null) {
      logger.i('User not authenticated and no DID provided, showing auth prompt.');
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
      final profile = await profileRepository.getProfile(effectiveDid);

      if (profile == null) {
        logger.w('Profile not found for DID: $effectiveDid');
        state = AsyncError('Profile not found', StackTrace.current);
        return;
      }

      logger.d('Profile loaded successfully for $effectiveDid: ${profile.handle}');

      final bool isEarlySupporter = await profileRepository.isEarlySupporter(effectiveDid);
      logger.d('Early supporter status for $effectiveDid: $isEarlySupporter');

      state = AsyncData(
        currentState.copyWith(
          profile: profile,
          isEarlySupporter: isEarlySupporter,
          showAuthPrompt: false,
          currentViewDid: effectiveDid,
        ),
      );
    } catch (e, s) {
      logger.e('Error loading profile for DID: $effectiveDid', error: e, stackTrace: s);
      state = AsyncError(e, s);
    }
  }

  Future<void> refreshProfile() async {
    final currentProfileState = state.asData?.value;
    final currentDid = currentProfileState?.currentViewDid;
    logger.d('Refreshing profile for DID: $currentDid');

    if (currentDid == null && !authRepository.isAuthenticated) {
      logger.w('Cannot refresh, no DID and user not authenticated.');
      return;
    }
    final didToRefresh = currentDid ?? authRepository.session!.did;

    state = const AsyncLoading();

    try {
      await profileRepository.clearProfileCache(didToRefresh);
      await loadProfileData(didToRefresh, ProfileState(currentViewDid: didToRefresh));
      logger.i('Profile for $didToRefresh refreshed successfully.');
    } catch (e, s) {
      logger.e('Error refreshing profile for $didToRefresh', error: e, stackTrace: s);
      state = AsyncError(e, s);
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
    return authRepository.isAuthenticated && authRepository.session?.did == profileDid;
  }

  Future<String?> toggleFollow() async {
    final currentData = state.asData!.value;
    final profile = currentData.profile;

    if (profile == null) {
      logger.w('Cannot toggle follow, profile not loaded.');
      throw Exception('Profile not loaded, cannot toggle follow.');
    }
    if (!authRepository.isAuthenticated) {
      logger.i('User not authenticated, showing auth prompt for follow action.');
      state = AsyncData(currentData.copyWith(showAuthPrompt: true));
      return null;
    }

    logger.d('Toggling follow for profile: ${profile.did}, current follow URI: ${profile.viewer?.following ?? 'none'}');
    final originalStateValue = currentData;

    final bool newIsFollowing = profile.viewer?.following == null;

    try {
      String? newFollowUriResult;
      if (newIsFollowing) {
        final response = await sprkRepository.graph.followUser(profile.did);
        newFollowUriResult = response.uri;
        logger.i('Successfully followed ${profile.did}. New follow URI: $newFollowUriResult');
      } else {
        if (profile.viewer?.following != null) {
          await sprkRepository.graph.unfollowUser(profile.viewer!.following!);
          newFollowUriResult = null;
          logger.i('Successfully unfollowed ${profile.did}.');
        } else {
          logger.w('Attempted to unfollow ${profile.did} but followUri is null.');
          throw Exception('Cannot unfollow, follow URI is missing.');
        }
      }

      final refreshedProfile = await profileRepository.getProfile(profile.did, forceRefresh: true);
      final isEarlySupporter = await profileRepository.isEarlySupporter(profile.did);

      state = AsyncData(originalStateValue.copyWith(profile: refreshedProfile, isEarlySupporter: isEarlySupporter));
      return newFollowUriResult;
    } catch (e, s) {
      logger.e('Error toggling follow for ${profile.did}', error: e, stackTrace: s);
      state = AsyncData(originalStateValue);
      throw Exception('Failed to toggle follow: ${e.toString()}');
    }
  }

  Future<bool> createReport({required String did, required atp.ModerationReasonType reasonType, String? reason}) async {
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
      final subject = atp.ReportSubject.repoRef(data: atp.RepoRef(did: did));
      final result = await sprkRepository.repo.createReport(subject: subject, reasonType: reasonType, reason: reason);
      logger.i('Report created successfully for $did');
      return result;
    } catch (e, s) {
      logger.e('Error creating report for $did', error: e, stackTrace: s);
      throw Exception('Failed to create report: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    logger.i('User logging out.');
    await authRepository.logout();

    final currentProfileState = state.asData?.value;
    final currentDid = currentProfileState?.currentViewDid;

    state = const AsyncLoading();
    await loadProfileData(currentDid, ProfileState(currentViewDid: currentDid));
  }

  void triggerAuthPrompt() {
    final currentData = state.asData?.value;
    if (currentData != null) {
      state = AsyncData(currentData.copyWith(showAuthPrompt: true));
      logger.i('Auth prompt triggered from notifier.');
    } else {
      logger.i('Auth prompt trigger requested, but no current data state to update.');
    }
  }
}
