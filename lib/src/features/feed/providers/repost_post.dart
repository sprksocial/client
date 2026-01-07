import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';

part 'repost_post.g.dart';

@riverpod
Future<RepoStrongRef> repostPost(Ref ref, String postCid, AtUri postUri) async {
  try {
    return await GetIt.I<SprkRepository>().feed.repostPost(postCid, postUri);
  } catch (e) {
    throw Exception('Failed to repost post: $e');
  }
}

@riverpod
Future<void> unrepostPost(Ref ref, AtUri repostUri) async {
  try {
    await GetIt.I<SprkRepository>().feed.unrepostPost(repostUri);
  } catch (e) {
    throw Exception('Failed to unrepost post: $e');
  }
}
