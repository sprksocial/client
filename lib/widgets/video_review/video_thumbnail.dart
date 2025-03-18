import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../screens/video_playback_screen.dart';

class VideoThumbnail extends StatelessWidget {
  final VideoPlayerController controller;
  final double width;
  final double height;

  const VideoThumbnail({
    super.key,
    required this.controller,
    this.width = 160,
    this.height = 250,
  });

  void _openFullscreenPlayback(BuildContext context) {
    // Pause the preview before opening fullscreen
    controller.pause();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlaybackScreen(controller: controller),
      ),
    ).then((_) {
      // Resume the preview when returning from fullscreen
      controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          color: Colors.grey[600],
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openFullscreenPlayback(context),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video frame
            Container(
              width: width,
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            
            // Play button overlay
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FluentIcons.play_24_filled,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 