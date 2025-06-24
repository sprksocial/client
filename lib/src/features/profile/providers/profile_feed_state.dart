import 'dart:collection';

import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

part 'profile_feed_state.freezed.dart';

@freezed
abstract class ProfileFeedState with _$ProfileFeedState {
  const ProfileFeedState._();
  const factory ProfileFeedState({
    required List<AtUri> loadedPosts,
    required bool isEndOfNetwork,
    required String? cursor,
    required LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})> extraInfo,
    // New fields for unified posts and source tracking
    @Default(<AtUri>[]) List<AtUri> allPosts, // All posts (images + videos) from both sources
    @Default(<AtUri, String>{}) Map<AtUri, String> postSources, // Track which posts came from which source ('spark' or 'bluesky')
    @Default(<AtUri, bool>{}) Map<AtUri, bool> postTypes, // Track post types: true = video, false = image
    @Default(null) String? blueskyCursor, // Separate cursor for Bluesky pagination
  }) = _ProfileFeedState;

  int get length => loadedPosts.length;
  int get allPostsLength => allPosts.length;

  // Helper getters for filtering
  List<AtUri> get videoPosts => allPosts.where((uri) => postTypes[uri] == true).toList();
  List<AtUri> get imagePosts => allPosts.where((uri) => postTypes[uri] == false).toList();

  static const int fetchLimit = 16; // number of posts to fetch at a time
  // NO CACHING HAHAHAHAHA https://pbs.twimg.com/media/Gibzch0aYAU4WXZ.jpg:large
}
