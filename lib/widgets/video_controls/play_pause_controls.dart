import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:video_player/video_player.dart';

class PlayPauseControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onRewind;
  final VoidCallback onPlayPause;
  final VoidCallback onFastForward;

  const PlayPauseControls({
    Key? key,
    required this.controller,
    required this.onRewind,
    required this.onPlayPause,
    required this.onFastForward,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rewind 5 seconds
        IconButton(
          icon: const Icon(Ionicons.play_back_outline, color: CupertinoColors.white, size: 36),
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
            decoration: BoxDecoration(
              color: CupertinoColors.white.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                controller.value.isPlaying
                    ? Ionicons.pause
                    : Ionicons.play,
                color: CupertinoColors.white,
                size: 46,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        
        // Fast forward 5 seconds
        IconButton(
          icon: const Icon(Ionicons.play_forward_outline, color: CupertinoColors.white, size: 36),
          onPressed: onFastForward,
          padding: const EdgeInsets.all(16),
        ),
      ],
    );
  }
} 