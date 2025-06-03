import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/features/feed/providers/is_current_post.dart';
import 'package:sparksocial/utils/app_colors.dart';
import 'package:video_player/video_player.dart';

class PostVideoPlayer extends ConsumerStatefulWidget {
  const PostVideoPlayer({super.key, required this.videoUrl, required this.feed, required this.index});

  final String videoUrl;
  final Feed feed;
  final int index;

  @override
  ConsumerState<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends ConsumerState<PostVideoPlayer> {
  bool isPlaying = false;
  late VideoPlayerController videoController;
  bool isInitialized = false;
  bool _userInteracted = false; // Track if user manually played/paused

  @override
  void initState() {
    super.initState();
    initVideoPlayer();
  }

  @override
  void dispose() {
    if (isInitialized) {
      videoController.removeListener(_videoListener);
      videoController.dispose();
    }
    super.dispose();
  }

  void _videoListener() {
    if (mounted && videoController.value.isInitialized) {
      final nowPlaying = videoController.value.isPlaying;
      if (nowPlaying != isPlaying) {
        setState(() {
          isPlaying = nowPlaying;
        });
      }
    }
  }

  Future<void> initVideoPlayer() async {
    final cacheManager = GetIt.I<CacheManagerInterface>();
    final file = await cacheManager.getCachedFile(widget.videoUrl);
    if (!mounted) return;
    videoController = VideoPlayerController.file(file!); 
    await videoController.initialize();
    videoController.setLooping(true);
    videoController.addListener(_videoListener);
    if (!mounted) return;
    setState(() {
      isInitialized = true;
      isPlaying = videoController.value.isPlaying;
    });
  }

  void _handleAutoPlayPause(bool shouldPlay) {
    if (!isInitialized || _userInteracted) return;
    
    if (shouldPlay && !videoController.value.isPlaying) {
      videoController.play();
    } else if (!shouldPlay && videoController.value.isPlaying) {
      videoController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Watch if this post is currently visible/active
    final isCurrentPost = ref.watch(isCurrentPostProvider(widget.feed, widget.index));
    
    // Auto-play/pause based on visibility (only if user hasn't manually interacted)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAutoPlayPause(isCurrentPost);
    });

    return GestureDetector(
      onTap: () {
        _userInteracted = true; // User manually interacted
        if (videoController.value.isPlaying) {
          videoController.pause();
        } else {
          videoController.play();
        }
      },
      child: Stack(
        children: [
          VideoPlayer(videoController),
          Center(
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 50,
              color: isPlaying ? Colors.transparent : AppColors.white,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              videoController,
              padding: const EdgeInsets.only(top: 5),
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColors.primary,
                bufferedColor: AppColors.primary.withAlpha(128),
                backgroundColor: AppColors.white.withAlpha(128),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
