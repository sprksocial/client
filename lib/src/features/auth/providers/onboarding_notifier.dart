import 'dart:typed_data';

import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/models/onboarding_screen_state.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

part 'onboarding_notifier.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  late final SparkLogger _logger;
  late final OnboardingRepository _onboardingRepository;
  late final AuthRepository _authRepository;

  @override
  Future<OnboardingScreenState> build() async {
    _logger = GetIt.instance<LogService>().getLogger('OnboardingNotifier');
    _onboardingRepository = GetIt.instance<OnboardingRepository>();
    _authRepository = GetIt.instance<AuthRepository>();

    return _fetchInitialProfileData();
  }

  Future<OnboardingScreenState> _fetchInitialProfileData() async {
    try {
      final userDid = _authRepository.did;
      if (userDid == null || userDid.isEmpty) {
        _logger.e('User not authenticated or DID is missing.');
        return const OnboardingScreenState(
          isLoading: false,
          errorMessage: 'User not authenticated',
        );
      }

      final profileDataMap = await _onboardingRepository.getBskyProfile();
      final avatarCid = profileDataMap?.avatar?.ref.link;
      final avatarUrl = await _onboardingRepository.getBskyAvatarUrl();

      return OnboardingScreenState(
        isLoading: false,
        bskyProfileRecord: profileDataMap,
        displayName: profileDataMap?.displayName ?? '',
        description: profileDataMap?.description ?? '',
        initialAvatarCid: avatarCid,
        initialAvatarUrl: avatarUrl,
        userDid: userDid,
      );
    } catch (e, s) {
      _logger.e('Failed to load Bsky profile', error: e, stackTrace: s);
      return const OnboardingScreenState(
        isLoading: false,
        errorMessage: 'Failed to load profile.',
      );
    }
  }

  // Public method to reload profile if needed
  Future<void> reloadProfile() async {
    state = const AsyncValue.loading();
    try {
      final newState = await _fetchInitialProfileData();
      state = AsyncValue.data(newState);
    } catch (e, s) {
      _logger.e('Error reloading profile', error: e, stackTrace: s);
      state = AsyncValue.error(e, s);
    }
  }

  void updateDisplayName(String name) {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(displayName: name));
    }
  }

  void updateDescription(String desc) {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(description: desc));
    }
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && state.hasValue) {
      final bytes = await pickedFile.readAsBytes();
      state = AsyncValue.data(
        state.value!.copyWith(
          localAvatarBytes: bytes,
          removeInitialAvatar: false,
        ),
      );
    }
  }

  void resetDisplayName() {
    if (state.hasValue) {
      final currentProfileData = state.value!.bskyProfileRecord;
      final originalDisplayName = currentProfileData?.displayName ?? '';
      state = AsyncValue.data(
        state.value!.copyWith(displayName: originalDisplayName),
      );
    }
  }

  void resetDescription() {
    if (state.hasValue) {
      final currentProfileData = state.value!.bskyProfileRecord;
      final originalDescription = currentProfileData?.description ?? '';
      state = AsyncValue.data(
        state.value!.copyWith(description: originalDescription),
      );
    }
  }

  void revertAvatarToInitial() {
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(
          localAvatarBytes: null,
          removeInitialAvatar: false,
        ),
      );
    }
  }

  void clearAvatarSelection() {
    if (state.hasValue) {
      final current = state.value!;
      final hasInitialAvatar =
          (current.initialAvatarUrl?.isNotEmpty ?? false) ||
          (current.initialAvatarCid?.isNotEmpty ?? false);

      state = AsyncValue.data(
        current.copyWith(
          localAvatarBytes: null,
          removeInitialAvatar: hasInitialAvatar,
        ),
      );
    }
  }

  String? get currentAvatarDisplayUrl {
    final currentVal = state.value;
    if (currentVal == null) return null;

    if (currentVal.localAvatarBytes != null) {
      return null;
    }

    if (currentVal.removeInitialAvatar) {
      return null;
    }

    if (currentVal.initialAvatarUrl != null &&
        currentVal.initialAvatarUrl!.isNotEmpty) {
      return currentVal.initialAvatarUrl;
    }

    if (currentVal.initialAvatarCid != null &&
        currentVal.initialAvatarCid!.isNotEmpty &&
        currentVal.userDid != null &&
        currentVal.userDid!.isNotEmpty) {
      return 'https://cdn.bsky.app/img/avatar/plain/${currentVal.userDid}/${currentVal.initialAvatarCid}@jpeg';
    }

    return null;
  }

  ({
    String displayName,
    String description,
    Uint8List? avatarBytes,
    String? initialAvatarUrl,
    String? initialAvatarCid,
    bool removeInitialAvatar,
  })?
  getOnboardingDataForNextStep() {
    if (!state.hasValue) return null;
    final current = state.value!;
    return (
      displayName: current.displayName,
      description: current.description,
      avatarBytes: current.localAvatarBytes,
      initialAvatarUrl: current.initialAvatarUrl,
      initialAvatarCid: current.initialAvatarCid,
      removeInitialAvatar: current.removeInitialAvatar,
    );
  }
}
