import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';

part 'edit_profile_state.freezed.dart';

@freezed
abstract class EditProfileState with _$EditProfileState {
  const factory EditProfileState({
    required ProfileViewDetailed profile,
    required String displayName,
    required String description,
    dynamic initialAvatar,
    dynamic localAvatar,
    @Default(false) bool isSaving,
  }) = _EditProfileState;

  factory EditProfileState.fromProfile(ProfileViewDetailed profile) => EditProfileState(
    profile: profile,
    displayName: profile.displayName ?? '',
    description: profile.description ?? '',
    initialAvatar: profile.avatar,
    localAvatar: profile.avatar,
  );
}
