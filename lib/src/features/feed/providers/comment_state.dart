import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:video_player/video_player.dart';

part 'comment_state.freezed.dart';

@freezed
class CommentState with _$CommentState {
  const factory CommentState({
    required Comment comment,
    @Default(false) bool showReplies,
    @Default(false) bool isLiked,
    @Default(false) bool isVideoInitialized,
    @Default(false) bool isFirstImagePrecached,
    VideoPlayerController? videoController,
    @Default(0) int originalLikeCount,
  }) = _CommentState;
}
