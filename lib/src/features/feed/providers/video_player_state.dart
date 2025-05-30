import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_player_state.freezed.dart';

@freezed
abstract class VideoPlayerState with _$VideoPlayerState {
  factory VideoPlayerState({
    VideoPlayerController? controller,

    /// ALL video players will be cached, this is the key in the SQLite database
    /// use it to get the file path
    @AtUriConverter() required AtUri uri,
  }) = _VideoPlayerState;
}
