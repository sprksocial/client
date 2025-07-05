import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';

Future<FeedSkeleton> followingSkeletonFunction({int? limit, String? cursor}) async {
  limit ??= 10;
  final sprkRepository = GetIt.instance<SprkRepository>();
  final session = sprkRepository.authRepository.session;
  if (session == null) {
    throw Exception('Not authenticated');
  }
  final bluesky = bsky.Bluesky.fromSession(session);
  final timelineRes = await bluesky.feed.getTimeline(limit: limit, cursor: cursor);
  final uris = timelineRes.data.feed.map((item) => AtUri.parse(item.post.uri.toString())).toList();

  return FeedSkeleton(
    feed: uris.map((uri) => SkeletonFeedPost(uri: uri)).toList(),
    cursor: timelineRes.data.cursor,
  );
}
