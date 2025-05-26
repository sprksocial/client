import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_option_state.freezed.dart';

@freezed
class FeedOptionState with _$FeedOptionState {
  const factory FeedOptionState({
    @Default(false) bool isSelected
  }) = _FeedOptionState;

  
}
