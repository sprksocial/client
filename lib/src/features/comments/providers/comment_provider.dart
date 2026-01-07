import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/com_atproto_repo_strongref.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/features/comments/providers/comment_state.dart';
import 'package:sparksocial/src/features/feed/providers/post_updates.dart';

part 'comment_provider.g.dart';

@Riverpod(keepAlive: true)
class CommentNotifier extends _$CommentNotifier {
  @override
  CommentState build(Thread thread) {
    _feedRepository = GetIt.instance<SprkRepository>().feed;
    switch (thread) {
      case ThreadViewPost():
        return CommentState(thread: thread);
      case NotFoundPost():
        throw Exception('Post not found');
      case BlockedPost():
        throw Exception('Post is blocked');
    }
  }

  late final FeedRepository _feedRepository;

  Future<void> toggleLike() async {
    final wasLiked = state.isLiked;
    final currentLikeCount = state.thread.post.likeCount ?? 0;
    final postUri = state.thread.post.uri.toString();
    final originalState = state;

    try {
      if (wasLiked) {
        final likeUri = state.thread.post.viewer!.like!;

        final updatedPost = switch (state.thread.post) {
          ThreadPostView(:final post) => ThreadPostView(
            post: post.copyWith(
              viewer: post.viewer?.copyWith(like: null),
              likeCount: currentLikeCount - 1,
            ),
          ),
          ThreadReplyView(:final reply) => ThreadReplyView(
            reply: reply.copyWith(
              viewer: reply.viewer?.copyWith(like: null),
              likeCount: currentLikeCount - 1,
            ),
          ),
        };
        state = state.copyWith(
          thread: state.thread.copyWith(post: updatedPost),
        );

        await _feedRepository.unlikePost(likeUri);
        ref.read(postUpdateProvider(postUri).notifier).state++;
      } else {
        final response = await _feedRepository.likePost(state.thread.post.cid, state.thread.post.uri);

        final updatedPost = switch (state.thread.post) {
          ThreadPostView(:final post) => ThreadPostView(
            post: post.copyWith(
              viewer: post.viewer?.copyWith(like: response.uri) ?? ViewerState(like: response.uri),
              likeCount: currentLikeCount + 1,
            ),
          ),
          ThreadReplyView(:final reply) => ThreadReplyView(
            reply: reply.copyWith(
              viewer: reply.viewer?.copyWith(like: response.uri) ?? ReplyViewerState(like: response.uri),
              likeCount: currentLikeCount + 1,
            ),
          ),
        };
        state = state.copyWith(
          thread: state.thread.copyWith(post: updatedPost),
        );

        ref.read(postUpdateProvider(postUri).notifier).state++;
      }
    } catch (e) {
      state = originalState;
      rethrow;
    }
  }

  void preloadFirstImage(BuildContext context) {
    final imageUrls = state.thread.post.imageUrls;
    if (imageUrls.isNotEmpty) {
      precacheImage(CachedNetworkImageProvider(imageUrls.first), context);
    }
  }
}

Future<RepoStrongRef> postComment(
  String text,
  String parentCid,
  String parentUri, {
  String? rootCid,
  String? rootUri,
  List<XFile>? imageFiles,
  Map<String, String>? altTexts,
}) async {
  final feedRepository = GetIt.instance<SprkRepository>().feed;
  return feedRepository.postComment(
    text,
    parentCid,
    AtUri.parse(parentUri),
    rootCid: rootCid,
    rootUri: rootUri != null ? AtUri.parse(rootUri) : null,
    imageFiles: imageFiles,
    altTexts: altTexts,
  );
}
