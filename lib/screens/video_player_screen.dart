import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../services/feed_service.dart';
import '../widgets/video/preloaded_video_item.dart';
import '../widgets/video/video_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem initialVideoItem;
  final List<dynamic>? allVideos;
  final int initialIndex;

  const VideoPlayerScreen({super.key, required this.initialVideoItem, this.allVideos, this.initialIndex = 0});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, PreloadedVideo> _preloadedVideos = {};
  final Set<String> _preloadedImageUrls = {};
  List<VideoItem> _videoItems = [];
  // Optimized video options
  static final _videoPlayerOptions = VideoPlayerOptions(mixWithOthers: false, allowBackgroundPlayback: false);
  // Add FeedService instance variable
  late FeedService _feedService;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    // Get FeedService instance
    _feedService = context.read<FeedService>();

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
      final videoData = widget.allVideos![i];
      // Skip null or invalid video data
      if (videoData == null || videoData is! Map<String, dynamic>) continue;

      // Safely extract data using null-aware operators and default values
      final post = videoData['post'] as Map<String, dynamic>?;
      final embed = post?['embed'] as Map<String, dynamic>?;
      final author = post?['author'] as Map<String, dynamic>?;
      final record = post?['record'] as Map<String, dynamic>?;

      final videoUrl = embed?['playlist'] as String? ?? '';
      // Crucially, skip if there's no video URL
      if (videoUrl.isEmpty) continue;

      final thumbnailUrl = embed?['thumbnail'] as String? ?? '';
      final username = author?['handle'] as String? ?? 'username';

      String description = record?['text'] as String? ?? post?['text'] as String? ?? '';

      final likeCount = post?['likeCount'] as int? ?? 0;
      final commentCount = post?['replyCount'] as int? ?? 0;
      final shareCount = post?['repostCount'] as int? ?? 0;
      final authorDid = author?['did'] as String? ?? '';
      final videoUri = post?['uri'] as String? ?? '';
      final videoCid = post?['cid'] as String? ?? '';
      final profileImageUrl = author?['avatar'] as String? ?? '';
      final isSprk = videoUrl.contains('sprk.so');

      // Extract hashtags (consider moving this to a utility function)
      final List<String> hashtags = [];
      final words = description.split(' ');
      for (final word in words) {
        if (word.startsWith('#') && word.length > 1) {
          hashtags.add(word.substring(1));
        }
      }

      final videoItem = VideoItem(
        // Use a more robust key
        key: ValueKey('video_item_${videoUri}_${videoCid}_$i'),
        index: i, // This index needs careful management if list changes
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
        isLiked: false, // State should be managed elsewhere
        isSprk: isSprk,
        postUri: videoUri,
        postCid: videoCid,
        disableBackgroundBlur: false,
        // --- Pass actual callbacks or use Provider for actions ---
        onLikePressed: () {
          print("Like pressed on item $i");
        },
        onBookmarkPressed: () {
          print("Bookmark pressed on item $i");
        },
        onSharePressed: () {
          print("Share pressed on item $i");
        },
        onProfilePressed: () {
          print("Profile pressed on item $i");
        },
        onUsernameTap: () {
          print("Username tapped on item $i");
        },
        onHashtagTap: (String hashtag) {
          print("Hashtag '$hashtag' tapped on item $i");
        },
        // -----------------------------------------------------------
      );

      _videoItems.add(videoItem);
    }
    // Update initial index if filtering removed preceding items
    final initialUri = widget.initialVideoItem.postUri;
    final newInitialIndex = _videoItems.indexWhere((item) => item.postUri == initialUri);
    if (newInitialIndex != -1) {
      _currentIndex = newInitialIndex;
      _pageController = PageController(initialPage: _currentIndex); // Recreate page controller
    }
  }

  void _preloadInitialMedia() {
    // Reset and clear preloaded videos
    for (final video in _preloadedVideos.values) {
      video.controller.dispose();
    }
    _preloadedVideos.clear();
    _preloadedImageUrls.clear();

    // Preload initial batch using the updated logic
    if (_videoItems.isNotEmpty) {
      _updateLoadedMedia(_currentIndex, isInitialLoad: true);
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (index < 0 || index >= _videoItems.length) return;
    // Don't preload if already loaded or loading
    if (_preloadedVideos.containsKey(index)) return;

    final videoItem = _videoItems[index];
    final videoUrl = videoItem.videoUrl;
    // Should not happen due to filtering in _prepareVideoItems, but double-check
    if (videoUrl == null || videoUrl.isEmpty) return;

    // --- Check for FeedService pre-initialized controller first ---
    VideoPlayerController? controller = _feedService.getPreloadedController(videoUrl);
    bool wasPreInitialized = controller != null;

    if (controller == null) {
      // If not pre-initialized by FeedService, create a new one
      controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl), videoPlayerOptions: _videoPlayerOptions);
      print("VideoPlayerScreen: Creating NEW controller for index $index (URL: $videoUrl)");
    } else {
      print("VideoPlayerScreen: Using PRE-INITIALIZED controller for index $index (URL: $videoUrl)");
    }
    // --- End check ---

    try {
      // Store in map immediately
      _preloadedVideos[index] = PreloadedVideo(controller: controller, isInitialized: wasPreInitialized, videoUrl: videoUrl);

      // Apply settings only if we created it or it wasn't initialized
      if (!wasPreInitialized || !controller.value.isInitialized) {
        controller.setLooping(true);
        await controller.setVolume(index == _currentIndex ? 1.0 : 0.0);

        // Start initialization if not already started/completed
        if (!controller.value.isInitialized) {
          controller
              .initialize()
              .then((_) {
                if (mounted && index == _currentIndex && !controller!.value.isPlaying && controller.value.isInitialized) {
                  controller.play();
                }
              })
              .catchError((error) {
                debugPrint("Error initializing video controller for index $index: $error");
                if (mounted) {
                  setState(() {});
                }
              });
        }
      }

      // Attempt to play immediately if it's the current video
      if (index == _currentIndex) {
        // Play regardless of wasPreInitialized, controller handles state
        controller.play();
      }
    } catch (e) {
      debugPrint('Error during video controller setup for index $index: $e');
      _preloadedVideos.remove(index)?.controller.dispose(); // Clean up on error
    }
  }

  void _unloadVideo(int index) {
    if (_preloadedVideos.containsKey(index)) {
      final video = _preloadedVideos.remove(index)!;
      // Don't pause, just dispose
      video.controller.dispose();
      debugPrint("Unloaded video $index");
    }
  }

  // Add isInitialLoad parameter to prevent unnecessary state updates during init
  void _updateLoadedMedia(int newIndex, {bool isInitialLoad = false}) {
    if (!isInitialLoad && newIndex == _currentIndex) return;

    final oldIndex = _currentIndex;

    // --- Volume/Playback Control ---
    // Mute/Pause the old video if it exists and was the current one
    if (_preloadedVideos.containsKey(oldIndex)) {
      final oldController = _preloadedVideos[oldIndex]!.controller;
      if (oldController.value.isInitialized) {
        // Check if initialized before accessing value
        oldController.setVolume(0.0);
        oldController.pause();
      }
    }

    // Set volume and attempt to play the new video if it exists
    if (_preloadedVideos.containsKey(newIndex)) {
      final newController = _preloadedVideos[newIndex]!.controller;
      // Set volume immediately
      newController.setVolume(1.0);
      // Play optimistically - controller will play when ready
      // Check initialized state just before playing as a safeguard
      if (newController.value.isInitialized && !newController.value.isPlaying) {
        newController.play();
      } else if (!newController.value.isInitialized) {
        // If not initialized yet, play will be called later by initialize().then()
        // or by the PreloadedVideoItem listener/state update
        newController.play(); // Still try to play, might start sooner
      }
    } else {
      // If the target video isn't even loading yet, preload it now.
      _preloadVideo(newIndex);
    }
    // --- End Volume/Playback Control ---

    // --- Preloading Window Update ---
    const preloadAhead = 5; // Load 5 videos ahead
    const preloadBehind = 2; // Keep 2 videos behind for back navigation

    final Set<int> desiredLoadWindow = {};
    // Always include current index
    desiredLoadWindow.add(newIndex);

    // Add indices ahead of current position (prioritized)
    for (int i = 1; i <= preloadAhead; i++) {
      int nextIdx = newIndex + i;
      if (nextIdx < _videoItems.length) {
        desiredLoadWindow.add(nextIdx);
      }
    }

    // Add a few indices behind current position (for back navigation)
    for (int i = 1; i <= preloadBehind; i++) {
      int prevIdx = newIndex - i;
      if (prevIdx >= 0) {
        desiredLoadWindow.add(prevIdx);
      }
    }

    final currentLoaded = _preloadedVideos.keys.toSet();
    final toUnload = currentLoaded.difference(desiredLoadWindow);
    final newToLoad = desiredLoadWindow.difference(currentLoaded);

    for (final idx in toUnload) {
      _unloadVideo(idx);
    }

    // Prioritize loading with focus on next videos first
    final List<int> loadOrder = [];

    // First priority: current video
    if (newToLoad.contains(newIndex)) {
      loadOrder.add(newIndex);
    }

    // Second priority: next 5 videos in order
    for (int i = 1; i <= preloadAhead; i++) {
      int nextIdx = newIndex + i;
      if (newToLoad.contains(nextIdx)) {
        loadOrder.add(nextIdx);
      }
    }

    // Third priority: previous videos
    for (int i = 1; i <= preloadBehind; i++) {
      int prevIdx = newIndex - i;
      if (newToLoad.contains(prevIdx)) {
        loadOrder.add(prevIdx);
      }
    }

    // Load videos in prioritized order
    for (final idx in loadOrder) {
      _preloadVideo(idx);
    }
    // --- End Preloading Window Update ---

    // Update current index - use setState only if not initial load to avoid build errors
    if (mounted && !isInitialLoad) {
      setState(() {
        _currentIndex = newIndex;
      });
    } else {
      _currentIndex = newIndex;
    }

    debugPrint("Updated media focus to index: $newIndex. Preloading window: $desiredLoadWindow");
  }

  @override
  Widget build(BuildContext context) {
    // Ensure FeedService is available if accessed during build (though primarily used in methods)
    // _feedService = context.watch<FeedService>(); // Use watch if build depends on it

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videoItems.length,
        // Use a key based on the number of items if it can change
        key: ValueKey('video_page_view_${_videoItems.length}'),
        onPageChanged: _updateLoadedMedia,
        itemBuilder: (context, index) {
          if (index >= _videoItems.length) {
            return Container(
              color: Colors.red,
              child: Center(child: Text("Error: Index out of bounds $index >= ${_videoItems.length}")),
            );
          }
          final videoItem = _videoItems[index];
          final videoUrl = videoItem.videoUrl;

          // --- Determine which controller to use --- //
          VideoPlayerController? controllerToUse;
          // Check our internal map first (most common case after initial load)
          PreloadedVideo? preloadedVideoData = _preloadedVideos[index];

          if (preloadedVideoData != null) {
            // Use the controller already managed by VideoPlayerScreen
            controllerToUse = preloadedVideoData.controller;
          } else if (videoUrl != null && videoUrl.isNotEmpty) {
            // If not in map, check FeedService (relevant for first load of index 0 usually)
            controllerToUse = _feedService.getPreloadedController(videoUrl);
            if (controllerToUse != null) {
              // If found in FeedService, add it to our map
              print("VideoPlayerScreen itemBuilder: Using controller pre-initialized by FeedService for index $index");
              _preloadedVideos[index] = PreloadedVideo(
                controller: controllerToUse,
                isInitialized: controllerToUse.value.isInitialized,
                videoUrl: videoUrl,
              );
              // Trigger play if it's the current index and ready
              // Also ensure volume is set correctly for the pre-initialized controller
              if (index == _currentIndex) {
                controllerToUse.setVolume(1.0); // Ensure volume is 1 for current
                if (controllerToUse.value.isInitialized && !controllerToUse.value.isPlaying) {
                  controllerToUse.play();
                } else if (!controllerToUse.value.isInitialized) {
                  // If controller from FeedService isn't ready yet, play will be called
                  // when its initialize() future completes in _preloadVideo
                  // or by the PreloadedVideoItem widget itself.
                  // We can still call play() optimistically here.
                  controllerToUse.play();
                }
              } else {
                controllerToUse.setVolume(0.0); // Ensure volume is 0 if not current
              }
            } else {
              // If not found in FeedService either, trigger normal preload
              // This happens when scrolling to videos beyond the initial one
              print("VideoPlayerScreen itemBuilder: No controller found for index $index, triggering preload.");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Avoid calling setState during build
                if (mounted) {
                  _preloadVideo(index);
                }
              });
            }
          }
          // --- Controller determined --- //

          if (controllerToUse != null) {
            // We have a controller (either from _preloadedVideos or FeedService)
            return PreloadedVideoItem(
              key: ValueKey('preloaded_video_${videoItem.postUri}_$index'),
              index: index,
              controller: controllerToUse,
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
              disableBackgroundBlur: videoItem.disableBackgroundBlur,
              onLikePressed: videoItem.onLikePressed,
              onBookmarkPressed: videoItem.onBookmarkPressed,
              onSharePressed: videoItem.onSharePressed,
              onProfilePressed: videoItem.onProfilePressed,
              onUsernameTap: videoItem.onUsernameTap,
              onHashtagTap: videoItem.onHashtagTap,
            );
          } else {
            // Fallback if no controller is ready AND preload hasn't been triggered yet
            // This state should be temporary until _preloadVideo runs.
            debugPrint("Warning: No controller available for index $index in itemBuilder, rendering fallback.");
            return videoItem; // Render the original item (likely without player)
          }
        },
      ),
    );
  }
}

class PreloadedVideo {
  final VideoPlayerController controller;
  // isInitialized here tracks if WE have called initialize(), not if it has completed.
  // Completion state is checked via controller.value.isInitialized.
  final bool isInitialized; // Consider renaming to isInitializing or similar
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}
