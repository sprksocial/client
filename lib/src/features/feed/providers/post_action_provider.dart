import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';

part 'post_action_provider.g.dart';


@riverpod
Future<LikePostResponse> likePost(Ref ref, String postCid, String postUri) {
  final feedRepository = GetIt.instance<FeedRepository>();

  return feedRepository.likePost(postCid, postUri);
}

@riverpod
Future<void> unlikePost(Ref ref, String likeUri) {
  final feedRepository = GetIt.instance<FeedRepository>();

  return feedRepository.unlikePost(likeUri);
}

@riverpod
Future<void> deletePost(Ref ref, String postUri) {
  final feedRepository = GetIt.instance<FeedRepository>();

  return feedRepository.deletePost(postUri);
}

