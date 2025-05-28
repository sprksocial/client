import 'package:atproto/atproto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/features/feed/providers/comment_state.dart';
import 'package:video_player/video_player.dart';

part 'comment_provider.g.dart';

@riverpod
class CommentNotifier extends _$CommentNotifier {
  @override
  CommentState build(Comment comment) {
    _feedRepository = GetIt.instance<FeedRepository>();
    ref.onDispose(() {
        state.videoController?.dispose();
    });
    return CommentState(comment: comment);
  }

  late final FeedRepository _feedRepository;

  Future<void> toggleLike() async {
    if (state.comment.likeUri != null) {
      await _feedRepository.unlikePost(state.comment.likeUri!);
      state = state.copyWith(comment: state.comment.copyWith(likeUri: null));
    } else {
      final response = await _feedRepository.likePost(state.comment.cid, state.comment.uri);
      state = state.copyWith(comment: state.comment.copyWith(likeUri: response.uri));
    }
  }

  void initializeVideoPlayer() {
    if (state.comment.mediaUrl != null) {
      final videoController = VideoPlayerController.networkUrl(Uri.parse(state.comment.mediaUrl!));
      state = state.copyWith(
        videoController: videoController,
        isVideoInitialized: true,
      );
    }
  }

  void preloadFirstImage(BuildContext context) {
    if (state.comment.imageUrls.isNotEmpty) {
      precacheImage(CachedNetworkImageProvider(state.comment.imageUrls.first), context);
    }
  }

  void toggleReplies() {
    state = state.copyWith(showReplies: !state.showReplies);
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
  return await feedRepository.postComment(text, parentCid, parentUri, rootCid: rootCid, rootUri: rootUri, imageFiles: imageFiles, altTexts: altTexts);
}
