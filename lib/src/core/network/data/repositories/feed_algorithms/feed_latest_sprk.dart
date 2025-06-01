import 'package:atproto_core/atproto_core.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';

Future<FeedSkeleton> latestSprkSkeletonFunction({int? limit, String? cursor}) async {
  final feedRepository = GetIt.I<FeedRepository>();
  limit ??= 10;
  return await feedRepository.getFeedSkeleton(
    Feed.custom(name: 'latest-sprk', uri: AtUri.parse('simple-desc')),
    limit: 30,
  ); // TODO: implement
}
