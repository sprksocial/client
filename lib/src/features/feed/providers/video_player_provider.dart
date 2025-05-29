import 'dart:io';

import 'package:atproto_core/atproto_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/feed/providers/video_controllers_provider.dart';
import 'package:sparksocial/src/features/feed/providers/video_player_state.dart';
import 'package:video_player/video_player.dart' as player;

part 'video_player_provider.g.dart';

@riverpod
class VideoPlayer extends _$VideoPlayer {
  @override
  VideoPlayerState build(File file, AtUri uri) {
    ref.onDispose(dispose);
    return VideoPlayerState(file: file, uri: uri);
  }

  void setController(player.VideoPlayerController controller) {
    ref.read(videoControllersProvider.notifier).setController(state.file, controller);
    state = state.copyWith(controller: controller);
  }

  void dispose() {
    state.controller?.dispose();
    ref.read(videoControllersProvider.notifier).setController(uri, null);
  }
}
