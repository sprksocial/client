import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';

Future<FeedSkeleton> followingSkeletonFunction({int? limit, String? cursor}) async {
  limit ??= 10;
  final sprkRepository = GetIt.instance<SprkRepository>();

  return sprkRepository.executeWithRetry(() async {
    if (!sprkRepository.authRepository.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final atproto = sprkRepository.authRepository.atproto;
    if (atproto == null) {
      throw Exception('AtProto not initialized');
    }

    final response = await atproto.get(
      NSID.parse('so.sprk.feed.getTimeline'),
      parameters: {'limit': limit, 'cursor': cursor},
      headers: {'atproto-proxy': sprkRepository.sprkDid},
      to: (jsonMap) {
        if (!jsonMap.containsKey('feed')) {
          return const FeedSkeleton(feed: []);
        }

        final feedData = jsonMap['feed'];
        if (feedData == null || feedData is! List) {
          return const FeedSkeleton(feed: []);
        }

        final feed = feedData
            .map((item) {
              final itemMap = item as Map<String, dynamic>;

              // The response has a 'post' object containing the 'uri'
              final postMap = itemMap['post'] as Map<String, dynamic>?;
              if (postMap == null) {
                return null;
              }

              final uriString = postMap['uri'] as String?;
              if (uriString == null) {
                return null;
              }

              final uri = AtUri.parse(uriString);
              return SkeletonFeedPost(uri: uri);
            })
            .whereType<SkeletonFeedPost>()
            .toList();

        return FeedSkeleton(
          feed: feed,
          cursor: jsonMap['cursor'] as String?,
        );
      },
    );

    return response.data;
  });
}
