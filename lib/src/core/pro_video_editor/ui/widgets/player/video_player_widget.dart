import 'dart:io' as io show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:video_player/video_player.dart';

/// Reusable video player surface used inside the editor and filters preview.
class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({
    required this.controller,
    required this.isLoadingListenable,
    this.useCoverFit = false,
    super.key,
  });

  final VideoPlayerController controller;
  final ValueListenable<bool?> isLoadingListenable;
  final bool useCoverFit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: isLoadingListenable,
      builder: (_, isLoading, _) {
        final size = controller.value.size;
        final width = size.width > 0 ? size.width : 1280.0;
        final height = size.height > 0 ? size.height : 720.0;

        return Center(
          child: isLoading ?? false
              ? const CircularProgressIndicator.adaptive()
              : useCoverFit
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    if (!constraints.hasBoundedWidth ||
                        !constraints.hasBoundedHeight) {
                      return AspectRatio(
                        aspectRatio: width / height,
                        child: VideoPlayer(controller),
                      );
                    }

                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    );
                  },
                )
              : AspectRatio(
                  aspectRatio: width / height,
                  child: VideoPlayer(controller),
                ),
        );
      },
    );
  }
}

/// Utility to create a VideoPlayerController from any supported [EditorVideo].
Future<VideoPlayerController> createVideoPlayerControllerFromEditorVideo(
  EditorVideo video,
) async {
  if (video.assetPath != null && video.assetPath!.isNotEmpty) {
    return VideoPlayerController.asset(video.assetPath!);
  }
  if (video.networkUrl != null && video.networkUrl!.isNotEmpty) {
    return VideoPlayerController.networkUrl(Uri.parse(video.networkUrl!));
  }
  if (video.file != null) {
    final dynamic f = video.file;
    // If it's a dart:io File, use the native file controller.
    if (f is io.File) {
      return VideoPlayerController.file(f);
    }
    // Otherwise, try to use a file:// URI if a path is exposed.
    try {
      final path = f.path as String?;
      if (path != null && path.isNotEmpty) {
        return VideoPlayerController.networkUrl(Uri.file(path));
      }
    } catch (_) {
      // File doesn't expose path, will fall back to network URL
    }
  }
  // Fallback controller (should not happen when a valid video is provided)
  return VideoPlayerController.networkUrl(Uri.parse('about:blank'));
}
