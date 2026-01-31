import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_feed_index_provider.g.dart';

/// Tracks the currently visible post index in a standalone profile feed.
/// Keyed by profile URI string to support multiple profiles.
///
/// Returns -1 when not yet initialized. This prevents videos at index 0 from
/// incorrectly auto-playing before the actual initial index is set.
@riverpod
class ProfileFeedIndex extends _$ProfileFeedIndex {
  @override
  int build(String profileUri) {
    return -1; // Not initialized
  }

  void setIndex(int index) {
    state = index;
  }
}
