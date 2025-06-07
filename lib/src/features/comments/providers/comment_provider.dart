import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/features/comments/providers/comment_state.dart';
import 'package:video_player/video_player.dart';

part 'comment_provider.g.dart';

@riverpod
class CommentNotifier extends _$CommentNotifier {
  @override
  CommentState build(Thread thread) {
    _feedRepository = GetIt.instance<FeedRepository>();
    ref.onDispose(() {
      state.videoController?.dispose();
    });
    switch (thread) {
      case ThreadViewPost():
        return CommentState(thread: thread);
      case NotFoundPost():
        throw Exception('Post not found');
      case BlockedPost():
        throw Exception('Post is blocked');
      default:
        throw Exception('Unknown thread type');
    }
  }

  late final FeedRepository _feedRepository;

  Future<void> toggleLike() async {
    if (state.thread.post.viewer?.like != null) {
      await _feedRepository.unlikePost(state.thread.post.viewer!.like!);
      state = state.copyWith(
        thread: state.thread.copyWith(post: state.thread.post.copyWith(viewer: state.thread.post.viewer!.copyWith(like: null))),
      );
    } else {
      final response = await _feedRepository.likePost(state.thread.post.cid, state.thread.post.uri);
      state = state.copyWith(
        thread: state.thread.copyWith(
          post: state.thread.post.copyWith(viewer: state.thread.post.viewer!.copyWith(like: response.uri)),
        ),
      );
    }
  }

  void initializeVideoPlayer() {
    final videoUrl = state.thread.post.videoUrl;
    if (videoUrl != '') {
      final videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      state = state.copyWith(videoController: videoController, isVideoInitialized: true);
    }
  }

  void preloadFirstImage(BuildContext context) {
    final imageUrls = state.thread.post.imageUrls;
    if (imageUrls.isNotEmpty) {
      precacheImage(CachedNetworkImageProvider(imageUrls.first), context);
    }
  }

  void toggleVideoPlayback() {
    if (state.videoController != null && state.isVideoInitialized) {
      state.videoController!.value.isPlaying ? state.videoController!.pause() : state.videoController!.play();
    }
  }
}

Future<StrongRef> postComment(
  String text,
  String parentCid,
  String parentUri, {
  String? rootCid,
  String? rootUri,
  List<XFile>? imageFiles,
  Map<String, String>? altTexts,
}) async {
  final feedRepository = GetIt.instance<FeedRepository>();
  return await feedRepository.postComment(
    text,
    parentCid,
    AtUri.parse(parentUri),
    rootCid: rootCid,
    rootUri: rootUri != null ? AtUri.parse(rootUri) : null,
    imageFiles: imageFiles,
    altTexts: altTexts,
  );
}
