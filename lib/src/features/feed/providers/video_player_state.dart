import 'dart:io';

import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_player_state.freezed.dart';

@freezed
abstract class VideoPlayerState with _$VideoPlayerState {
  factory VideoPlayerState({
    VideoPlayerController? controller,
    required File file,
    @AtUriConverter() required AtUri uri,
  }) = _VideoPlayerState;
}
