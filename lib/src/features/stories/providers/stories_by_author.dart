import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';

part 'stories_by_author.g.dart';

@riverpod
FutureOr<({Map<ProfileViewBasic, List<StoryView>> storiesByAuthor, String? cursor})> storiesByAuthor(
  Ref ref, {
  int limit = 30,
  String? cursor,
}) async {
  final feedRepository = GetIt.instance<SprkRepository>().feed;
  final result = await feedRepository.getStoriesTimeline(limit: limit, cursor: cursor);
  return result;
}
