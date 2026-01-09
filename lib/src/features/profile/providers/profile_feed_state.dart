import 'dart:collection';

import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

part 'profile_feed_state.freezed.dart';

@freezed
abstract class ProfileFeedState with _$ProfileFeedState {
  const factory ProfileFeedState({
    required List<AtUri> loadedPosts,
    required bool isEndOfNetwork,
    required String? cursor,
    required LinkedHashMap<
      AtUri,
      ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})
    >
    extraInfo,
    @Default(<AtUri>[]) List<AtUri> allPosts,
    @Default(<AtUri, String>{}) Map<AtUri, String> postSources,
    @Default(<AtUri, bool>{}) Map<AtUri, bool> postTypes,
    @Default(<AtUri, PostView>{}) Map<AtUri, PostView> postViews,
    @Default(null) String? blueskyCursor,
  }) = _ProfileFeedState;
  const ProfileFeedState._();

  int get length => loadedPosts.length;
  int get allPostsLength => allPosts.length;

  List<AtUri> get videoPosts =>
      allPosts.where((uri) => postTypes[uri] ?? true).toList();
  List<AtUri> get imagePosts =>
      allPosts.where((uri) => postTypes[uri] == false).toList();

  static const int fetchLimit = 16; // number of posts to fetch at a time
  // NO CACHING HAHAHAHAHA https://pbs.twimg.com/media/Gibzch0aYAU4WXZ.jpg:large
}
