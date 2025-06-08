import 'dart:collection';

import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'profile_feed_state.freezed.dart';

@freezed
abstract class ProfileFeedState with _$ProfileFeedState {
  const ProfileFeedState._();
  const factory ProfileFeedState({
    required List<AtUri> loadedPosts,
    required bool isEndOfNetwork,
    required String? cursor,
    required LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})> extraInfo,
  }) = _ProfileFeedState;

  int get length => loadedPosts.length;

  static const int fetchLimit = 16; // number of posts to fetch at a time
  // NO CACHING HAHAHAHAHA https://pbs.twimg.com/media/Gibzch0aYAU4WXZ.jpg:large
}
