import 'dart:typed_data';

import 'package:bluesky/bluesky.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_screen_state.freezed.dart';

@freezed
class OnboardingScreenState with _$OnboardingScreenState {
  const factory OnboardingScreenState({
    @Default(true) bool isLoading,
    ProfileRecord? bskyProfileRecord,
    String? initialAvatarCid,
    String? initialAvatarUrl,
    Uint8List? localAvatarBytes,
    @Default('') String displayName,
    @Default('') String description,
    String? errorMessage,
    String? userDid, // To store the user's DID for avatar URL construction
  }) = _OnboardingScreenState;
}
