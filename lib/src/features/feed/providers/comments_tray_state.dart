import 'package:freezed_annotation/freezed_annotation.dart';

part 'comments_tray_state.freezed.dart';

@freezed
class CommentsTrayState with _$CommentsTrayState {
  const factory CommentsTrayState({
    String? replyingToUsername,
    String? replyingToId,
    String? replyingToUri,
    String? replyingToCid,
    @Default([]) List<Comment> comments,
    @Default(0) int commentCount,
    required String postUri,
    required String postCid,
    required bool isSprk,
  }) = _CommentsTrayState;
}
