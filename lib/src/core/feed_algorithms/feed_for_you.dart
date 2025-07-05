import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';

Future<FeedSkeleton> forYouSkeletonFunction({int? limit, String? cursor}) async {
  limit ??= 10;
  final sprkRepository = GetIt.instance<SprkRepository>();
  final session = sprkRepository.authRepository.session;
  if (session == null) {
    throw Exception('Not authenticated');
  }
  final bluesky = bsky.Bluesky.fromSession(session);
  final generatorUri = AtUri.parse('at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids');
  final feedRes = await bluesky.feed.getFeed(generatorUri: generatorUri, limit: limit, cursor: cursor);

  final uris = feedRes.data.feed.map((item) => AtUri.parse(item.post.uri.toString())).toList();

  return FeedSkeleton(
    feed: uris.map((uri) => SkeletonFeedPost(uri: uri)).toList(),
    cursor: feedRes.data.cursor,
  );
}
