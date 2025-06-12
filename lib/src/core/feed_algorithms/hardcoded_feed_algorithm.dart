import 'package:atproto/core.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/feed_algorithms/feed_following.dart';
import 'package:sparksocial/src/core/feed_algorithms/feed_for_you.dart';
import 'package:sparksocial/src/core/feed_algorithms/feed_mutuals.dart';
import 'package:sparksocial/src/core/feed_algorithms/feed_latest_sprk.dart';
import 'package:sparksocial/src/core/feed_algorithms/feed_shared.dart';

typedef SkeletonFunction = Future<FeedSkeleton> Function({int? limit, String? cursor});
typedef ExtraInfoFunction = Future<Map<AtUri, HardcodedFeedExtraInfo>> Function(List<AtUri> uris);

class HardCodedFeedAlgorithm {
  static SkeletonFunction get following => followingSkeletonFunction;
  static SkeletonFunction get mutuals => mutualsSkeletonFunction;
  static SkeletonFunction get forYou => forYouSkeletonFunction;
  static SkeletonFunction get latestSprk => latestSprkSkeletonFunction;
  static SkeletonFunction get shared => sharedSkeletonFunction;
  static ExtraInfoFunction get sharedExtraInfo => sharedExtraInfoFunction;

  static SkeletonFunction skeletonFromEnum(HardCodedFeedEnum feed) {
    switch (feed) {
      case HardCodedFeedEnum.following:
        return following;
      case HardCodedFeedEnum.mutuals:
        return mutuals;
      case HardCodedFeedEnum.forYou:
        return forYou;
      case HardCodedFeedEnum.latestSprk:
        return latestSprk;
      case HardCodedFeedEnum.shared:
        return shared;
    }
  }

  static ExtraInfoFunction? extraInfoFromEnum(HardCodedFeedEnum feed) {
    switch (feed) {
      case HardCodedFeedEnum.shared:
        return sharedExtraInfo;
      default:
        return null;
    }
  }
}
