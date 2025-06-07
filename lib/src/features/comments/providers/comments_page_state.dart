import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'comments_page_state.freezed.dart';

@freezed
class CommentsPageState with _$CommentsPageState {
  const factory CommentsPageState({
    String? replyingToUsername,
    String? replyingToId,
    String? replyingToUri,
    String? replyingToCid,
    required ThreadViewPost thread,
  }) = _CommentsPageState;
}
