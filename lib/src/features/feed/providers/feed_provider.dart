import 'package:atproto/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';

part 'feed_provider.g.dart';

@Riverpod(keepAlive: true)
class FeedNotifier extends _$FeedNotifier {
  @override
  Future<FeedState> build(AtUri atUri) async {
    final sqlCache = SQLCache();
    final remainingCachedPosts = await sqlCache.getPostCountForFeed(atUri.toString());
    return FeedState(active: true, uris: [], index: 0, remainingCachedPosts: remainingCachedPosts, isFetching: false, isEndOfFeed: false);
  }
}
