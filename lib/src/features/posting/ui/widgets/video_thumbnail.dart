import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoThumbnail({super.key, required this.controller});

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

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.grey[600],
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      onLongPress: () {
        widget.controller.pause();
        context.router.push(VideoPlaybackRoute(controller: widget.controller));
      },
      child: AspectRatio(
        aspectRatio: widget.controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
              child: VideoPlayer(widget.controller),
            ),
            if (!_isPlaying)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.black.withAlpha(100), shape: BoxShape.circle),
                child: const Icon(FluentIcons.play_24_filled, color: Colors.white, size: 32),
              ),
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(color: Colors.black.withAlpha(100), borderRadius: BorderRadius.circular(4)),
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
