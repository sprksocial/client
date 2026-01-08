import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_feed_index_provider.g.dart';

/// Tracks the currently visible post index in a standalone profile feed.
/// Keyed by profile URI string to support multiple profiles.
@riverpod
class ProfileFeedIndex extends _$ProfileFeedIndex {
  @override
  int build(String profileUri) {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}
