import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';

part 'stories_by_author.g.dart';

@riverpod
FutureOr<
  ({Map<ProfileViewBasic, List<StoryView>> storiesByAuthor, String? cursor})
>
storiesByAuthor(Ref ref, {int limit = 30, String? cursor}) async {
  final storyRepository = GetIt.instance<StoryRepository>();
  final result = await storyRepository.getStoriesTimeline(
    limit: limit,
    cursor: cursor,
  );
  return result;
}
