import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

Future<FeedSkeleton> mutualsSkeletonFunction({int? limit, String? cursor}) async {
  limit ??= 10;
  return const FeedSkeleton(
    feed: [],
  ); // TODO: implement
}
