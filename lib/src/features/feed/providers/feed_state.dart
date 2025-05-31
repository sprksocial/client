import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'feed_state.freezed.dart';

@freezed
abstract class FeedState with _$FeedState {
  const FeedState._();
  const factory FeedState({
    required bool active,
    required List<AtUri> loadedUris,
    required int index,
    required int freshPostCount,
    required bool isCaching,
    required bool isEndOfNetworkFeed,
    required String? cursor,
    Map<AtUri, HardcodedFeedExtraInfo>? extraInfo,
  }) = _FeedState;

  int get length => loadedUris.length;

  static const int fetchLimit = 10; // number of posts to fetch at a time
  static const int loadLimit = 10; // number of posts to load from the database at a time
  static const int firstLoadLimit = 10; // number of posts to load in the first load
  static const int poolSize = fetchLimit + (fetchLimit >> 1); // number of post embeds to cache at a time
}
