import 'dart:io';

import 'package:atproto_core/atproto_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/feed/providers/video_controllers_state.dart';
import 'package:video_player/video_player.dart';

part 'video_controllers_provider.g.dart';

@Riverpod(keepAlive: true)
class VideoControllers extends _$VideoControllers {
  @override
  VideoControllersState build() {
    ref.onDispose(dispose);
    return VideoControllersState({}, 0);
  }

  void dispose() {
    for (var controller in state.controllers.values) {
      controller.dispose();
    }
  }

  void setController(File file, VideoPlayerController? controller) {
    if (controller == null) {
      // remove controller
      state = state.copyWith(controllers: {...state.controllers}..remove(file), count: state.count - 1);
    } else {
      if (state.controllers[file] != null) {
        // replace controller
        state.controllers[file]!.dispose();
        state = state.copyWith(controllers: {...state.controllers, file: controller}, count: state.count);
      } else {
        // add controller
        state = state.copyWith(controllers: {...state.controllers, file: controller}, count: state.count + 1);
      }
    }
  }
}
