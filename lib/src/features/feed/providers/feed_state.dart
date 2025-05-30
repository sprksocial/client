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
    required bool isFetching,
    required bool isEndOfFeed,
  }) = _FeedState;
}
