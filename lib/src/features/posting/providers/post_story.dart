import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';

part 'post_story.g.dart';

@riverpod
FutureOr<RepoStrongRef?> postStory(
  Ref ref,
  Media media, {
  List<SelfLabel>? selfLabels,
  List<String>? tags,
}) async {
  final storyRepository = GetIt.I<StoryRepository>();
  return await storyRepository.postStory(
    media,
    selfLabels: selfLabels,
    tags: tags,
  );
}
