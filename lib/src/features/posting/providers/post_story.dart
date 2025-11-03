import 'package:atproto/atproto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';

part 'post_story.g.dart';

@riverpod
FutureOr<StrongRef?> postStory(Ref ref, Media media, {List<SelfLabel>? selfLabels, List<String>? tags}) async {
  final storyRepository = GetIt.I<StoryRepository>();
  return await storyRepository.postStory(media, selfLabels: selfLabels, tags: tags);
}
