import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:video_player/video_player.dart';

class PlayPauseControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onRewind;
  final VoidCallback onPlayPause;
  final VoidCallback onFastForward;

  const PlayPauseControls({
    super.key,
    required this.controller,
    required this.onRewind,
    required this.onPlayPause,
    required this.onFastForward,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rewind 5 seconds
        IconButton(
          icon: const Icon(FluentIcons.previous_24_regular, color: Colors.white, size: 36),
          onPressed: onRewind,
          padding: const EdgeInsets.all(16),
        ),
        const SizedBox(width: 24),

        // Play/Pause
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: Colors.white.withAlpha(77), shape: BoxShape.circle),
            child: Center(
              child: Icon(
                controller.value.isPlaying ? FluentIcons.pause_24_filled : FluentIcons.play_24_filled,
                color: Colors.white,
                size: 46,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Fast forward 5 seconds
        IconButton(
          icon: const Icon(FluentIcons.next_24_regular, color: Colors.white, size: 36),
          onPressed: onFastForward,
          padding: const EdgeInsets.all(16),
        ),
      ],
    );
  }
}
