import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/profile/providers/edit_profile_state.dart';
import 'package:sparksocial/src/features/profile/data/repositories/profile_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/features/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';

part 'edit_profile_provider.g.dart';

/// Provider for editing profile information
@riverpod
class EditProfile extends _$EditProfile {
  late final ProfileRepository _profileRepository;
  late final AuthRepository _authRepository;
  late final LogService _logService;
  late final SparkLogger logger;

  @override
  EditProfileState build(Profile profile) {
    _profileRepository = GetIt.instance<ProfileRepository>();
    _authRepository = GetIt.instance<AuthRepository>();
    _logService = GetIt.instance<LogService>();
    logger = _logService.getLogger('EditProfileProvider');

    return EditProfileState.fromProfile(profile);
  }

  /// Update display name
  void updateDisplayName(String value) {
    state = state.copyWith(displayName: value);
  }

  /// Update description
  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  /// Pick avatar from gallery
  Future<void> pickAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      state = state.copyWith(localAvatar: bytes);
    } catch (e) {
      logger.e('Error picking avatar', error: e);
    }
  }

  /// Revert to original avatar
  void revertAvatar() {
    state = state.copyWith(localAvatar: state.initialAvatar);
  }

  /// Save profile changes
  Future<bool> saveProfile() async {
    try {
      if (!_authRepository.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      state = state.copyWith(isSaving: true);

      dynamic avatarToSend;
      if (state.localAvatar is Uint8List) {
        // Upload new avatar blob
        final client = _authRepository.atproto!;
        final respBlob = await client.repo.uploadBlob(state.localAvatar as Uint8List);
        if (respBlob.status.code != 200) {
          throw Exception('Failed to upload avatar blob');
        }
        avatarToSend = respBlob.data.blob.toJson();
      } else if (state.localAvatar is String && state.localAvatar != state.initialAvatar) {
        // A string URL was passed that's different from initial - fetch existing record
        final uri = AtUri.parse('at://${state.profile.did}/so.sprk.actor.profile/self');
        final recRes = await _authRepository.atproto!.repo.getRecord(uri: uri);
        final recordData = recRes.data.value;
        avatarToSend = recordData['avatar'];
      } else if (state.initialAvatar != null) {
        // No change but avatar exists - maintain it
        final uri = AtUri.parse('at://${state.profile.did}/so.sprk.actor.profile/self');
        final recRes = await _authRepository.atproto!.repo.getRecord(uri: uri);
        final recordData = recRes.data.value;
        avatarToSend = recordData['avatar'];
      }

      await _profileRepository.updateProfile(
        displayName: state.displayName.trim(),
        description: state.description.trim(),
        avatar: avatarToSend,
      );

      // save profile in the storage here

      // Invalidate the main profile provider to trigger a refresh
      if (state.profile.did == _authRepository.session?.did) {
        ref.invalidate(profileNotifierProvider(did: state.profile.did));
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      logger.e('Error saving profile', error: e);
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}
