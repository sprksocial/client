import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onPlayPause;
  final VoidCallback? onFullscreen;

  const VideoThumbnail({
    super.key,
    required this.controller,
    this.onPlayPause,
    this.onFullscreen,
  });

  bool get _isPlaying => controller.value.isPlaying;

  void _handleTap() {
    if (_isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    onPlayPause?.call();
  }

  void _handleLongPress(BuildContext context) {
    controller.pause();
    onFullscreen?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: _handleTap,
          onLongPress: () => _handleLongPress(context),
          child: AspectRatio(
            aspectRatio: value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _VideoDisplay(controller: controller),
                if (!_isPlaying) _PlayButton(),
                _InstructionsOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VideoDisplay extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoDisplay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: VideoPlayer(controller),
    );
  }
}

class _PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        FluentIcons.play_24_filled,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}

class _InstructionsOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(153),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Tap to play • Hold for fullscreen',
          style: TextStyle(color: Colors.white, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 