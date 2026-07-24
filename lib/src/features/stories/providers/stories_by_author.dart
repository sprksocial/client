import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/stories/providers/story_provider_dependencies.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

part 'stories_by_author.g.dart';

@riverpod
FutureOr<
  ({Map<ProfileViewBasic, List<StoryView>> storiesByAuthor, String? cursor})
>
storiesByAuthor(Ref ref, {int limit = 30, String? cursor}) async {
  final dependencies = ref.read(storyProviderDependenciesProvider);
  final result = await dependencies.storyRepository.getStoriesTimeline(
    limit: limit,
    cursor: cursor,
  );
  return result;
}
