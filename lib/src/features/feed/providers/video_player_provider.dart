import 'dart:io';

import 'package:atproto_core/atproto_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache.dart';
import 'package:sparksocial/src/features/feed/providers/video_controllers_provider.dart';
import 'package:sparksocial/src/features/feed/providers/video_player_state.dart';
import 'package:video_player/video_player.dart' as player;

part 'video_player_provider.g.dart';

@riverpod
class VideoPlayer extends _$VideoPlayer {

  Future<File> get file async =>File.fromRawPath( (await SQLCache().getPost(state.uri.toString()))?.cachedEmbedFile);
  @override
  VideoPlayerState build(AtUri uri) {
    ref.onDispose(dispose);
    return VideoPlayerState(uri: uri);
  }

  void setController(player.VideoPlayerController controller) {
    ref.read(videoControllersProvider.notifier).setController(state.uri, controller);
    state = state.copyWith(controller: controller);
  }

  void dispose() {
    state.controller?.dispose();
    ref.read(videoControllersProvider.notifier).setController(uri, null);
  }
}
