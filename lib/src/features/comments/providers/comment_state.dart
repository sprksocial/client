import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:video_player/video_player.dart';

part 'comment_state.freezed.dart';

@freezed
class CommentState with _$CommentState {
  const CommentState._();
  
  const factory CommentState({
    required ThreadViewPost thread,
    @Default(false) bool isVideoInitialized,
    @Default(false) bool isFirstImagePrecached,
    VideoPlayerController? videoController,
  }) = _CommentState;
  
  // Derive isLiked from the viewer state
  bool get isLiked => thread.post.viewer?.like != null;
  
  // Get the actual like count, potentially adjusted for optimistic UI updates
  int get likeCount => thread.post.likeCount ?? 0;
}
