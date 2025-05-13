import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_action_state.freezed.dart';

/// State class for video action management
@freezed
class VideoActionState with _$VideoActionState {
  const factory VideoActionState({
    @Default(false) bool isLoading,
    String? error,
  }) = _VideoActionState;
} 