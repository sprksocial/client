import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

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

/// Provider that monitors if the app is ready (active feed has finished loading)
@riverpod
bool appReady(Ref ref) {
  // Watch settings to get the active feed
  final settings = ref.watch(settingsProvider);
  final activeFeed = settings.activeFeed;

  // Watch the active feed state
  final feedState = ref.watch(feedNotifierProvider(activeFeed));

  // App is ready when:
  // 1. Feed has at least some content loaded OR has reached end of network feed
  final isReady = feedState.length > 0 || feedState.isEndOfNetworkFeed;

  return isReady;
}
