import 'dart:typed_data';

import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_screen_state.freezed.dart';

@freezed
abstract class OnboardingScreenState with _$OnboardingScreenState {
  const factory OnboardingScreenState({
    @Default(true) bool isLoading,
    ActorProfileRecord? bskyProfileRecord,
    String? initialAvatarCid,
    String? initialAvatarUrl,
    Uint8List? localAvatarBytes,
    @Default(false) bool removeInitialAvatar,
    @Default('') String displayName,
    @Default('') String description,
    String? errorMessage,
    String? userDid, // To store the user's DID for avatar URL construction
  }) = _OnboardingScreenState;
}
