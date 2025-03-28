import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../screens/video_playback_screen.dart';

class VideoThumbnail extends StatefulWidget {
  final VideoPlayerController controller;
  final double width;
  final double height;

  const VideoThumbnail({super.key, required this.controller, this.width = 160, this.height = 250});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  bool get _isPlaying => widget.controller.value.isPlaying;

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
    });
  }

  void _openFullscreenPlayback(BuildContext context) {
    // Pause the preview before opening fullscreen
    widget.controller.pause();

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlaybackScreen(controller: widget.controller))).then((
      _,
    ) {
      // Don't auto resume when returning from fullscreen
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Container(color: Colors.grey[600], child: const Center(child: CircularProgressIndicator(color: Colors.white))),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      onLongPress: () => _openFullscreenPlayback(context),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video frame
            Container(
              width: widget.width,
              height: widget.height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
              child: AspectRatio(aspectRatio: widget.controller.value.aspectRatio, child: VideoPlayer(widget.controller)),
            ),

            // Play/Pause button overlay
            if (!_isPlaying)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                child: const Icon(FluentIcons.play_24_filled, color: Colors.white, size: 32),
              ),

            // Interaction hint
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  'Tap to play • Hold for fullscreen',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
