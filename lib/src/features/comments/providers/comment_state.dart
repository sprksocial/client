import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

part 'comment_state.freezed.dart';

@freezed
abstract class CommentState with _$CommentState {
  const factory CommentState({
    required ThreadViewPost thread,
    @Default(false) bool isVideoInitialized,
    @Default(false) bool isFirstImagePrecached,
    String? videoUrl,
  }) = _CommentState;
  const CommentState._();

  // Derive isLiked from the viewer state
  bool get isLiked => thread.post.viewer?.like != null;

  // Get the actual like count, potentially adjusted for optimistic UI updates
  int get likeCount => thread.post.likeCount ?? 0;
}
