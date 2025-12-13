import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/profile/providers/edit_profile_state.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';

part 'edit_profile_provider.g.dart';

/// Provider for editing profile information
@riverpod
class EditProfile extends _$EditProfile {
  late final AuthRepository _authRepository;
  late final LogService _logService;
  late final SparkLogger logger;
  late final ActorRepository actorRepository;

  @override
  EditProfileState build(ProfileViewDetailed profile) {
    _authRepository = GetIt.instance<AuthRepository>();
    _logService = GetIt.instance<LogService>();
    logger = _logService.getLogger('EditProfileProvider');
    actorRepository = GetIt.instance<ActorRepository>();

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

      final atprotoClient = _authRepository.atproto;
      if (atprotoClient == null) {
        throw Exception('AtProto client not initialized');
      }

      Blob? avatarToSend;

      if (state.localAvatar is Uint8List) {
        // A new avatar image was picked, upload it as a blob.
        final respBlob = await atprotoClient.repo.uploadBlob(bytes: state.localAvatar as Uint8List);
        if (respBlob.status.code != 200) {
          throw Exception('Failed to upload avatar blob');
        }
        avatarToSend = respBlob.data.blob;
      } else if (state.localAvatar == null) {
        // If localAvatar is null, it means the avatar was cleared or never set.
        // Send null to remove any existing avatar from the profile.
        avatarToSend = null;
      } else {
        // If localAvatar is a String (and not null), it implies the avatar was not changed
        // and we need to maintain the existing one by fetching its Blob from the record.
        logger.d('Maintaining existing avatar from record ${state.profile.did}');
        final uri = AtUri.parse('at://${state.profile.did}/so.sprk.actor.profile/self');
        final recRes = await atprotoClient.repo.getRecord(
          collection: uri.collection.toString(),
          repo: uri.hostname,
          rkey: uri.rkey,
        );
        final recordData = recRes.data.value;

        // Ensure the 'avatar' field exists and is a Map before converting to Blob.
        // If it's null, it means the user had no avatar on the record.
        if (recordData['avatar'] is Map<String, dynamic>) {
          avatarToSend = Blob.fromJson(recordData['avatar'] as Map<String, dynamic>);
          logger.d('Blob avatar: $avatarToSend');
        } else {
          // This case handles an inconsistency where localAvatar was a string (URL),
          // but the actual record on the server has no avatar. Set to null gracefully.
          logger.w('Local avatar was string, but record has no avatar. Setting avatarToSend to null.');
          avatarToSend = null;
        }
      }

      await actorRepository.updateProfile(
        displayName: state.displayName.trim(),
        description: state.description.trim(),
        avatar: avatarToSend,
      );

      // save profile in the storage here

      // Invalidate the main profile provider to trigger a refresh
      if (state.profile.did == _authRepository.session?.did) {
        ref.invalidate(profileProvider(did: state.profile.did));
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
