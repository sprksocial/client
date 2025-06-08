import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';

Future<FeedSkeleton> latestSprkSkeletonFunction({int? limit, String? cursor}) async {
  limit ??= 10;
  final sprkRepository = GetIt.instance<SprkRepository>();
  final atproto = sprkRepository.authRepository.atproto;
  if (atproto == null) {
    throw Exception('AtProto not initialized');
  }
  final feedGenRes = await atproto.get(
    NSID.parse('so.sprk.feed.getFeedSkeleton'),
    parameters: {
      'feed': 'simple-desc',
      'limit': limit,
      'cursor': cursor,
    }, // need to call the API directly because latest-sprk is not a parsable AtUri
    service: 'feeds.sprk.so',
    to: (jsonMap) => jsonMap,
    adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
  );
  final feedData = feedGenRes.data['feed'] as List<dynamic>?;
  final uris = feedData?.map((item) => item['post'] as String).toList() ?? [];
  return FeedSkeleton(
    feed: uris.map((uri) => SkeletonFeedPost(uri: AtUri.parse(uri))).toList(),
    cursor: feedGenRes.data['cursor'] as String?,
  );
}
