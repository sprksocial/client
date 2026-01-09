import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart'; // Assuming Profile model path

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    ProfileViewDetailed? profile,
    @Default(false) bool isEarlySupporter,
    @Default(false) bool showAuthPrompt,
    String?
    currentViewDid, // DID being viewed or null for current user's profile
  }) = _ProfileState;
}
