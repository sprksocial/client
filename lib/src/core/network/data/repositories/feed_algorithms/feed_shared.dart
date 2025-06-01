import 'package:atproto/core.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

Future<FeedSkeleton> sharedSkeletonFunction({int? limit, String? cursor}) async {
  limit ??= 10;
  return FeedSkeleton(feed: []); // TODO: implement
}

Future<Map<AtUri, HardcodedFeedExtraInfoShared>> sharedExtraInfoFunction(List<AtUri> uris) async {
  return {}; // TODO: implement
}
