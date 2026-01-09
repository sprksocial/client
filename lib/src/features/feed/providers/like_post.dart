import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';

part 'like_post.g.dart';

@riverpod
Future<RepoStrongRef> likePost(Ref ref, String postCid, AtUri postUri) async {
  try {
    // like post
    return await GetIt.I<SprkRepository>().feed.likePost(postCid, postUri);
  } catch (e) {
    throw Exception('Failed to like post: $e');
  }
}

@riverpod
Future<void> unlikePost(Ref ref, AtUri likeUri) async {
  try {
    // unlike post
    await GetIt.I<SprkRepository>().feed.unlikePost(likeUri);
  } catch (e) {
    throw Exception('Failed to unlike post: $e');
  }
}
