import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_controllers_state.freezed.dart';

/// Map of all video controllers that are currently active app-wide
@freezed
abstract class VideoControllersState with _$VideoControllersState {
  factory VideoControllersState(
    Map<File, VideoPlayerController> controllers,
    int count,
  ) = _VideoControllersState;
}
