import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/features/comments/providers/comments_page_state.dart';

part 'comments_page_provider.g.dart';

@riverpod
class CommentsPage extends _$CommentsPage {
  late final FeedRepository feedRepository;
  @override
  Future<CommentsPageState> build({required AtUri postUri}) async {
    feedRepository = GetIt.instance<FeedRepository>();
    // try to get from cache, if not found, fetch from network
    final sqlCache = GetIt.instance<SQLCacheInterface>();
    try {
      final cachedPost = await sqlCache.getPost(postUri.toString());
      final thread = await feedRepository.getThread(postUri, bluesky: !cachedPost.isSprk, depth: 1);
      switch (thread) {
        case ThreadViewPost():
          return CommentsPageState(
            thread: thread,
          );
        case NotFoundPost():
          throw Exception('Post not found');
        case BlockedPost():
          throw Exception('Post is blocked');
      }
      throw Exception('Post not found');
    } catch (e) {
      List<PostView> networkPost;
      try {
        networkPost = await feedRepository.getPosts([postUri], bluesky: false);
      } catch (e) {
        networkPost = await feedRepository.getPosts([postUri], bluesky: true);
      }
      final thread = await feedRepository.getThread(postUri, bluesky: !networkPost.first.isSprk, depth: 1);
      switch (thread) {
        case ThreadViewPost():
          return CommentsPageState(
            thread: thread,
          );
        case NotFoundPost():
          throw Exception('Post not found');
        case BlockedPost():
          throw Exception('Post is blocked');
      }
      throw Exception('Post not found');
    }
  }

  Future<void> postComment(
    String text,
    String parentCid,
    String parentUri, {
    String? rootCid,
    String? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
  }) async {
    final feedRepository = GetIt.instance<FeedRepository>();
    final response = await feedRepository.postComment(
      text,
      parentCid,
      AtUri.parse(parentUri),
      rootCid: rootCid,
      rootUri: rootUri != null ? AtUri.parse(rootUri) : null,
      imageFiles: imageFiles,
      altTexts: altTexts,
    );
    final thread = await feedRepository.getThread(response.uri, bluesky: !state.value!.thread.post.isSprk, depth: 1);
    switch (thread) {
      case ThreadViewPost(:final post):
        // add the new comment to the thread and increase the reply count
        final currentThread = state.value!.thread;
        final currentReplies = currentThread.replies ?? <Thread>[];
        final newReply = ThreadViewPost(
          post: post,
          parent: currentThread,
          replies: null,
        );
        final updatedReplies = [...currentReplies, newReply];
        final updatedPost = currentThread.post.copyWith(
          replyCount: (currentThread.post.replyCount ?? 0) + 1,
        );
        final updatedThread = currentThread.copyWith(
          post: updatedPost,
          replies: updatedReplies,
        );
        state = AsyncValue.data(
          state.value!.copyWith(thread: updatedThread),
        );
      case NotFoundPost():
        throw Exception('Post not found');
      case BlockedPost():
        throw Exception('Post is blocked');
    }
  }

  Future<void> deleteComment(String commentUri) async {
    final currentThread = state.value!.thread;
    final newComments =
        currentThread.replies?.where((comment) {
          if (comment is ThreadViewPost) {
            return comment.post.uri != AtUri.parse(commentUri);
          }
          return false;
        }).toList();
    // remove the comment from the thread and decrease the reply count
    final updatedPost = currentThread.post.copyWith(
      replyCount: (currentThread.post.replyCount ?? 0) - 1,
    );
    final updatedThread = currentThread.copyWith(
      post: updatedPost,
      replies: newComments,
    );
    state = AsyncValue.data(
      state.value!.copyWith(thread: updatedThread),
    );
    await feedRepository.deletePost(AtUri.parse(commentUri));
  }

  void replyToComment(String userId, String username, {String? parentUri, String? parentCid}) {
    state = AsyncValue.data(
      state.value!.copyWith(
        replyingToUsername: username,
        replyingToId: userId,
        replyingToUri: parentUri,
        replyingToCid: parentCid,
      ),
    );
  }

  void cancelReply() {
    state = AsyncValue.data(
      state.value!.copyWith(replyingToUsername: null, replyingToId: null, replyingToUri: null, replyingToCid: null),
    );
  }
}
