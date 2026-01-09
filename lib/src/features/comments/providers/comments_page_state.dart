import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

part 'comments_page_state.freezed.dart';

@freezed
abstract class CommentsPageState with _$CommentsPageState {
  const factory CommentsPageState({
    required ThreadViewPost thread,
  }) = _CommentsPageState;
}
