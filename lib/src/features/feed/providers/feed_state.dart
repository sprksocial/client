import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_state.freezed.dart';

@freezed
abstract class FeedState with _$FeedState {
  factory FeedState({
    required bool active,
    required List<AtUri> uris,
    required int index,
    required int remainingCachedPosts,
    required bool isCaching,
    required bool isEndOfFeed,
    required bool isEndOfNetworkFeed,
  }) = _FeedState;

  static const int n = 10; // number of posts to fetch at a time
  static const int m = 10; // number of posts to load from the database at a time
  static const int f = 10; // number of posts to load in the first load
}
