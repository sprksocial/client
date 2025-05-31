import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_algorithms/feed_following.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_algorithms/feed_for_you.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_algorithms/feed_mutuals.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_algorithms/feed_latest_sprk.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_algorithms/feed_shared.dart';

typedef SkeletonFunction = Future<FeedSkeleton> Function({int? limit, String? cursor});

class HardCodedFeedAlgorithm {
  static SkeletonFunction get following => followingSkeletonFunction;
  static SkeletonFunction get mutuals => mutualsSkeletonFunction;
  static SkeletonFunction get forYou => forYouSkeletonFunction;
  static SkeletonFunction get latestSprk => latestSprkSkeletonFunction;
  static SkeletonFunction get shared => sharedSkeletonFunction;

  static SkeletonFunction fromEnum(HardCodedFeed feed) {
    switch (feed) {
      case HardCodedFeed.following:
        return following;
      case HardCodedFeed.mutuals:
        return mutuals;
      case HardCodedFeed.forYou:
        return forYou;
      case HardCodedFeed.latestSprk:
        return latestSprk;
      case HardCodedFeed.shared:
        return shared;
    }
  }
}
