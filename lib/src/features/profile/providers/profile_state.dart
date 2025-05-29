import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart'; // Assuming Profile model path

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    ProfileViewDetailed? profile,
    @Default(false) bool isEarlySupporter,
    @Default(false) bool showAuthPrompt,
    String? currentViewDid, // To store the DID being viewed or null for current user's own profile
  }) = _ProfileState;
} 