import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_providers.g.dart';

/// Provider for the simple splash screen state
@riverpod
class SplashNotifier extends _$SplashNotifier {
  @override
  bool build() {
    return false; // isImageLoaded initial state
  }

  /// Set the image loaded state
  void setImageLoaded(bool isLoaded) {
    state = isLoaded;
  }
}
