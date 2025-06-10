import 'package:atproto/atproto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto.dart';

part 'post_story.g.dart';

@riverpod
FutureOr<void> postStory(Ref ref, Embed embed, {List<SelfLabel>? selfLabels, List<String>? tags}) async {
  final feedRepository = GetIt.I<SprkRepository>().feed;
  await feedRepository.postStory(embed, selfLabels: selfLabels, tags: tags);
}
