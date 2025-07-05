import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_state.freezed.dart';

/// Splash screen state
@freezed
class SplashState with _$SplashState {
  /// Default constructor for splash screen state
  const factory SplashState({
    /// Whether the image is loaded
    @Default(false) bool isImageLoaded,
  }) = _SplashState;
}
