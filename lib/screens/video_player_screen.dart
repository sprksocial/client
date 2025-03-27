import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/video/video_item.dart';
import '../widgets/video/preloaded_video_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem initialVideoItem;
  final List<dynamic>? allVideos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.initialVideoItem,
    this.allVideos,
    this.initialIndex = 0,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, PreloadedVideo> _preloadedVideos = {};
  final Set<String> _preloadedImageUrls = {};
  List<VideoItem> _videoItems = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    if (widget.allVideos != null && widget.allVideos!.isNotEmpty) {
      _prepareVideoItems();
    } else {
      _videoItems = [widget.initialVideoItem];
    }

    _preloadInitialMedia();
  }

  @override
  void dispose() {
    // Dispose all video controllers
    for (final video in _preloadedVideos.values) {
      video.controller.dispose();
    }
    _preloadedVideos.clear();
    _pageController.dispose();
    super.dispose();
  }

  void _prepareVideoItems() {
    _videoItems = [];
    for (int i = 0; i < widget.allVideos!.length; i++) {
      final video = widget.allVideos![i];
      if (video == null) continue;

      final thumbnailUrl = video['post']['embed']['thumbnail'] as String? ?? '';
      final videoUrl = video['post']['embed']['playlist'] as String? ?? '';
      if (videoUrl.isEmpty) continue;

      final username = video['post']['author']['handle'] as String? ?? 'username';

      // Get description from record text first, then post text, finally fallback to default
      String? description;
      if (video['post']['record'] != null && video['post']['record']['text'] != null) {
        description = video['post']['record']['text'] as String?;
      }
      if (description == null || description.isEmpty) {
        description = video['post']['text'] as String?;
      }
      if (description == null || description.isEmpty) {
        description = '';
      }

      final likeCount = video['post']['likeCount'] as int? ?? 0;
      final commentCount = video['post']['replyCount'] as int? ?? 0;
      final shareCount = video['post']['repostCount'] as int? ?? 0;
      final authorDid = video['post']['author']['did'] as String? ?? '';
      final videoUri = video['post']['uri'] as String? ?? '';
      final videoCid = video['post']['cid'] as String? ?? '';
      final profileImageUrl = video['post']['author']['avatar'] as String? ?? '';
      final isSprk = videoUrl.contains('sprk.so');

      // Extract hashtags
      final List<String> hashtags = [];
      final words = description.split(' ');
      for (final word in words) {
        if (word.startsWith('#')) {
          hashtags.add(word.substring(1));
        }
      }

      final videoItem = VideoItem(
        key: ValueKey('video_item_$i'),
        index: i,
        videoUrl: videoUrl,
        username: username,
        description: description,
        hashtags: hashtags,
        likeCount: likeCount,
        commentCount: commentCount,
        bookmarkCount: 0,
        shareCount: shareCount,
        profileImageUrl: profileImageUrl,
        authorDid: authorDid,
        isLiked: false,
        isSprk: isSprk,
        postUri: videoUri,
        postCid: videoCid,
        disableBackgroundBlur: false,
        onLikePressed: () {},
        onBookmarkPressed: () {},
        onSharePressed: () {},
        onProfilePressed: () {},
        onUsernameTap: () {},
        onHashtagTap: (String hashtag) {},
      );

      _videoItems.add(videoItem);
    }
  }

  void _preloadInitialMedia() {
    // Reset and clear preloaded videos
    for (final video in _preloadedVideos.values) {
      video.controller.dispose();
    }
    _preloadedVideos.clear();
    _preloadedImageUrls.clear();

    // Preload initial batch of videos (current + 2 neighbors)
    if (_videoItems.isNotEmpty) {
      // Load current video first
      _preloadVideo(_currentIndex);

      // Then preload neighbors
      if (_currentIndex > 0) _preloadVideo(_currentIndex - 1);
      if (_currentIndex < _videoItems.length - 1) _preloadVideo(_currentIndex + 1);
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (index < 0 || index >= _videoItems.length) return;
    if (_preloadedVideos.containsKey(index)) return;

    final videoItem = _videoItems[index];
    final videoUrl = videoItem.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) return;

    // Create a new controller
    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      // Register it as non-initialized first
      _preloadedVideos[index] = PreloadedVideo(controller: controller, isInitialized: false, videoUrl: videoUrl);

      // Set video to loop automatically
      controller.setLooping(true);

      // Set volume to zero initially
      await controller.setVolume(0.0);

      // Try to initialize
      await controller.initialize();

      // Only proceed if still mounted and video is still needed
      if (mounted && _preloadedVideos.containsKey(index)) {
        // Set volume on only for current video
        final isCurrent = index == _currentIndex;
        await controller.setVolume(isCurrent ? 1.0 : 0.0);

        if (mounted) {
          setState(() {
            _preloadedVideos[index] = PreloadedVideo(controller: controller, isInitialized: true, videoUrl: videoUrl);
          });
        }

        // Set playback speed to normal
        await controller.setPlaybackSpeed(1.0);

        // Start playing if this is current video
        if (index == _currentIndex) {
          controller.play();
        }
      }
    } catch (e) {
      // Clean up on error
      if (_preloadedVideos.containsKey(index)) {
        _preloadedVideos[index]!.controller.dispose();
        _preloadedVideos.remove(index);
      }

      // Try again for network errors after a delay
      if (mounted && e.toString().contains('network')) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_preloadedVideos.containsKey(index)) {
            _preloadVideo(index);
          }
        });
      }
    }
  }

  void _unloadVideo(int index) {
    if (_preloadedVideos.containsKey(index)) {
      _preloadedVideos[index]!.controller.pause();
      _preloadedVideos[index]!.controller.dispose();
      _preloadedVideos.remove(index);
    }
  }

  void _updateLoadedMedia(int newIndex) {
    if (newIndex != _currentIndex) {
      // Handle video playback for current and previous video
      if (_videoItems.isNotEmpty) {
        // Mute and pause previous video
        if (_preloadedVideos.containsKey(_currentIndex)) {
          _preloadedVideos[_currentIndex]!.controller.setVolume(0.0);
          _preloadedVideos[_currentIndex]!.controller.pause();
        }

        // Set volume and play new video
        if (_preloadedVideos.containsKey(newIndex)) {
          _preloadedVideos[newIndex]!.controller.setVolume(1.0);
          _preloadedVideos[newIndex]!.controller.play();
        }
      }

      // Videos to preload (current, prev, next, prev-prev, next-next)
      final toLoad = <int>{
        newIndex,
        newIndex - 1,
        newIndex + 1,
        newIndex - 2,
        newIndex + 2,
      };

      // Filter out-of-bounds indices
      final validToLoad = toLoad.where((idx) => idx >= 0 && idx < _videoItems.length).toSet();

      // Find videos to unload
      final toUnload = _preloadedVideos.keys.toSet().difference(validToLoad);

      // Find new videos to load
      final newToLoad = validToLoad.difference(_preloadedVideos.keys.toSet());

      // Unload videos no longer needed
      for (final idx in toUnload) {
        _unloadVideo(idx);
      }

      // Load priority videos first (current, next, prev)
      final priorityLoad = [newIndex];
      if (newIndex + 1 < _videoItems.length) priorityLoad.add(newIndex + 1);
      if (newIndex - 1 >= 0) priorityLoad.add(newIndex - 1);

      for (final idx in priorityLoad) {
        if (newToLoad.contains(idx)) {
          _preloadVideo(idx);
          newToLoad.remove(idx);
        }
      }

      // Then load the rest
      for (final idx in newToLoad) {
        _preloadVideo(idx);
      }

      // Update current index
      _currentIndex = newIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videoItems.length,
        onPageChanged: _updateLoadedMedia,
        itemBuilder: (context, index) {
          final videoItem = _videoItems[index];

          // For preloaded video items
          final isPreloaded = _preloadedVideos.containsKey(index) && _preloadedVideos[index]!.isInitialized;

          if (isPreloaded) {
            return PreloadedVideoItem(
              key: ValueKey('preloaded_video_$index'),
              index: index,
              controller: _preloadedVideos[index]!.controller,
              username: videoItem.username,
              description: videoItem.description,
              hashtags: videoItem.hashtags,
              likeCount: videoItem.likeCount,
              commentCount: videoItem.commentCount,
              bookmarkCount: videoItem.bookmarkCount,
              shareCount: videoItem.shareCount,
              profileImageUrl: videoItem.profileImageUrl,
              authorDid: videoItem.authorDid,
              isVisible: index == _currentIndex,
              isLiked: videoItem.isLiked,
              isSprk: videoItem.isSprk,
              postUri: videoItem.postUri,
              postCid: videoItem.postCid,
              disableBackgroundBlur: false,
              onLikePressed: videoItem.onLikePressed,
              onBookmarkPressed: videoItem.onBookmarkPressed,
              onSharePressed: videoItem.onSharePressed,
              onProfilePressed: videoItem.onProfilePressed,
              onUsernameTap: videoItem.onUsernameTap,
              onHashtagTap: videoItem.onHashtagTap,
            );
          } else {
            // Return original video item as fallback
            return videoItem;
          }
        },
      ),
    );
  }
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}