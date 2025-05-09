import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

part 'preloaded_video.freezed.dart';

@freezed
class PreloadedVideo with _$PreloadedVideo {
  const factory PreloadedVideo({
    required VideoPlayerController controller,
    required bool isInitialized,
    required String? videoUrl,
    String? localPath,
  }) = _PreloadedVideo;
} 