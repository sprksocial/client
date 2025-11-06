import 'package:atproto/core.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';

typedef FeedViewFunction = Future<FeedView> Function({int? limit, String? cursor});
typedef ExtraInfoFunction = Future<Map<AtUri, HardcodedFeedExtraInfo>> Function(List<AtUri> uris);

class HardCodedFeedAlgorithm {
  // Map of feed URIs for feeds that use getFeed()
  static final Map<HardCodedFeedEnum, AtUri> _feedUris = {
    HardCodedFeedEnum.latest: AtUri.parse('at://did:plc:6hbqm2oftpotwuw7gvvrui3i/so.sprk.feed.generator/latest'),
    HardCodedFeedEnum.forYou: AtUri.parse('at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids'),
    // mutuals and shared don't have URIs yet (return empty feeds)
  };

  static FeedViewFunction feedViewFromEnum(HardCodedFeedEnum feed) {
    return ({int? limit, String? cursor}) async {
      limit ??= 10;
      final sprkRepository = GetIt.instance<SprkRepository>();
      final feedRepository = sprkRepository.feed;

      // Timeline is a special case
      if (feed == HardCodedFeedEnum.timeline) {
        return feedRepository.getTimeline(limit: limit, cursor: cursor);
      }

      // Check if this feed has a URI
      final feedUri = _feedUris[feed];
      if (feedUri != null) {
        return feedRepository.getFeedView(feedUri, limit: limit, cursor: cursor);
      }

      // Feeds without URIs return empty feed
      return const FeedView(feed: []);
    };
  }

  static ExtraInfoFunction? extraInfoFromEnum(HardCodedFeedEnum feed) {
    switch (feed) {
      case HardCodedFeedEnum.timeline:
      case HardCodedFeedEnum.forYou:
      case HardCodedFeedEnum.latest:
        return null;
    }
  }
}
