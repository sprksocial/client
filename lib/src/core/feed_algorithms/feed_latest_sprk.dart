import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/utils.dart';

Future<FeedSkeleton> latestSprkSkeletonFunction({int? limit, String? cursor}) async {
  final logger = GetIt.instance<LogService>().getLogger('latestSprkSkeletonFunction');
  limit ??= 10;
  final sprkRepository = GetIt.instance<SprkRepository>();
  final atproto = sprkRepository.authRepository.atproto;
  if (atproto == null) {
    throw Exception('AtProto not initialized');
  }
  logger.d('Cursor: $cursor');
  final feedGenRes = await atproto.get(
    NSID.parse('so.sprk.feed.getFeedSkeleton'),
    parameters: {
      'feed': 'simple-desc',
      'limit': limit,
      // cursors are for the WEAK
    }, // need to call the API directly because latest-sprk is not a parsable AtUri
    service: 'feeds.sprk.so',
    to: (jsonMap) => jsonMap,
    adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
  );
  logger.d('New cursor: ${feedGenRes.data['cursor']}');
  final feedData = feedGenRes.data['feed'] as List<dynamic>?;
  final uris = feedData?.map((item) => item['post'] as String).toList() ?? [];
  logger.d('Latest Sprk feed skeleton: $uris');
  return FeedSkeleton(feed: uris.map((uri) => SkeletonFeedPost(uri: AtUri.parse(uri))).toList(), cursor: null);
}
