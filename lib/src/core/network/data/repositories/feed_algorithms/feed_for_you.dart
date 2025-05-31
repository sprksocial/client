import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

Future<FeedSkeleton> forYouSkeletonFunction({int? limit, String? cursor}) async {
  limit ??= 10;
  return FeedSkeleton(feed: feed); // TODO: implement
}
