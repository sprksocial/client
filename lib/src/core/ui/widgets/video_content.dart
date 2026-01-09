import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:video_player/video_player.dart';

class VideoContent extends StatefulWidget {
  const VideoContent({
    required this.borderRadius,
    required this.videoUrl,
    super.key,
  });
  final BorderRadius borderRadius;
  final String videoUrl;

  @override
  State<VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends State<VideoContent> {
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (videoController != null && videoController!.value.isInitialized) {
          videoController!.value.isPlaying
              ? videoController!.pause()
              : videoController!.play();
        }
      },

      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 0.5,
          ),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (videoController != null && videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
              ),

            if (!videoController!.value.isInitialized)
              const CircularProgressIndicator(color: AppColors.white),

            if (videoController!.value.isInitialized &&
                !videoController!.value.isPlaying)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 128),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FluentIcons.play_24_filled,
                  size: 24,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
