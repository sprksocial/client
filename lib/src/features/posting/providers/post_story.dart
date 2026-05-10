import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
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
  RepoStrongRef? soundRef,
  List<StoryEmbed>? embeds,
}) async {
  final storyRepository = GetIt.I<StoryRepository>();
  return await storyRepository.postStory(
    media,
    selfLabels: selfLabels,
    tags: tags,
    soundRef: soundRef,
    embeds: embeds,
  );
}
