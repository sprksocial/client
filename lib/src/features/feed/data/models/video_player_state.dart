import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_player_state.freezed.dart';

/// Frozen state for video playback
@freezed
class VideoPlayerState with _$VideoPlayerState {
  const factory VideoPlayerState({
    required bool isInitialized,
    required bool isPlaying,
    required bool isVisible,
    required bool isDescriptionExpanded,
    required bool showComments,
    required int commentCount,
    VideoPlayerController? controller,
    String? error,
  }) = _VideoPlayerState;

  factory VideoPlayerState.initial() => const VideoPlayerState(
        isInitialized: false,
        isPlaying: false,
        isVisible: false,
        isDescriptionExpanded: false,
        showComments: false,
        commentCount: 0,
        controller: null,
        error: null,
      );
}
