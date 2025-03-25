import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../widgets/video/video_item.dart';
import '../widgets/video/preloaded_video_item.dart';
import '../widgets/feed/feed_selector.dart';
import '../utils/app_theme.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../services/actions_service.dart';
import '../models/feed_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  List<FeedPost>? _feedPosts;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedFeedType = 1; // 0: Following, 1: For You, 2: Spark new

  // Pre-initialized VideoPlayerControllers mapped by index
  final Map<int, PreloadedVideo> _preloadedVideos = {};

  @override
  void initState() {
    super.initState();
    _fetchVideos();
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

  Future<void> _fetchVideos() async {
    if (_selectedFeedType == 0) {
      await _fetchFollowingFeed();
    } else if (_selectedFeedType == 1) {
      await _fetchForYouFeed();
    } else {
      await _fetchSparkNewFeed();
    }
  }

  Future<void> _fetchFollowingFeed() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = context.read<AuthService>();
      final bsky = Bluesky.fromSession(authService.session!);

      final feed = await bsky.feed.getTimeline(limit: 100);

      // Convert feed items to our unified model
      final posts = feed.data.feed.map((item) => FeedPost.fromBlueskyFeed(item)).toList();

      setState(() {
        _feedPosts = posts;
        _isLoading = false;
        _preloadInitialVideos();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchForYouFeed() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = context.read<AuthService>();
      final bsky = Bluesky.fromSession(authService.session!);

      final feed = await bsky.feed.getFeed(
        generatorUri: AtUri.parse('at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids'),
        limit: 100,
      );

      // Convert feed items to our unified model
      final posts = feed.data.feed.map((item) => FeedPost.fromBlueskyFeed(item)).toList();

      setState(() {
        _feedPosts = posts;
        _isLoading = false;
        _preloadInitialVideos();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchSparkNewFeed() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = context.read<AuthService>();

      // Get feed skeleton with simple-desc feed
      final feedGenRes = await authService.atproto!.get(
        NSID.parse('so.sprk.feed.getFeedSkeleton'),
        parameters: {'feed': 'simple-desc', 'limit': 30},
        service: 'feeds.sprk.so',
        to: (json) => json,
      );

      // Extract post URIs from the feed data
      final feedData = feedGenRes.data['feed'] as List<dynamic>?;
      final uris = feedData?.map((item) => item['post'] as String).toList() ?? [];

      if (uris.isEmpty) {
        setState(() {
          _isLoading = false;
          _feedPosts = [];
        });
        return;
      }

      // Get the actual posts using the URIs
      final feedItems = await authService.atproto!.get(
        NSID.parse('so.sprk.feed.getPosts'),
        parameters: {'uris': uris},
        headers: {
          'atproto-proxy': 'did:web:api.sprk.so#sprk_appview'
        },
        to: (json) => json,
      );


      // Process the posts data
      final posts = feedItems.data['posts'] as List<dynamic>?;

      if (posts != null) {
        // Convert to our unified model
        final feedPosts = posts.map((post) {
          // Create a feed item with the post
          final feedItem = {'post': post};
          return FeedPost.fromSparkFeed(feedItem);
        }).toList();

        setState(() {
          _feedPosts = feedPosts;
          _isLoading = false;
          _preloadInitialVideos();
        });
      } else {
        setState(() {
          _isLoading = false;
          _feedPosts = [];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _preloadInitialVideos() {
    // Clear existing preloaded videos
    for (final video in _preloadedVideos.values) {
      video.controller.dispose();
    }
    _preloadedVideos.clear();

    // Reset current index
    _currentIndex = 0;

    // Preload initial batch of videos
    if (_feedPosts != null && _feedPosts!.isNotEmpty) {
      // Start loading in order of priority
      _preloadVideo(0); // Current video first

      // Then preload the others
      for (int i = 1; i <= 5 && i < _feedPosts!.length; i++) {
        _preloadVideo(i);
      }
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (index < 0 || index >= (_feedPosts?.length ?? 0) || _preloadedVideos.containsKey(index)) {
      return;
    }

    final post = _feedPosts![index];
    final videoUrl = post.videoUrl;

    if (videoUrl != null) {
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
          // Only set volume on for the current video
          final isCurrent = index == _currentIndex;
          await controller.setVolume(isCurrent ? 1.0 : 0.0);

          // Update the preloaded status
          setState(() {
            _preloadedVideos[index] = PreloadedVideo(controller: controller, isInitialized: true, videoUrl: videoUrl);
          });

          // Set playback speed to 1.0 (normal)
          await controller.setPlaybackSpeed(1.0);

          // Start playing if this is the current video
          if (index == _currentIndex) {
            controller.play();
          }
        }
      } catch (e) {
        // Handle initialization error by cleaning up
        if (_preloadedVideos.containsKey(index)) {
          _preloadedVideos[index]!.controller.dispose();
          _preloadedVideos.remove(index);
        }

        // Try again after a short delay for some error types
        if (mounted && e.toString().contains('network')) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && !_preloadedVideos.containsKey(index)) {
              _preloadVideo(index);
            }
          });
        }
      }
    }
  }

  void _unloadVideo(int index) {
    if (_preloadedVideos.containsKey(index)) {
      // Stop and dispose the controller
      _preloadedVideos[index]!.controller.pause();
      _preloadedVideos[index]!.controller.dispose();
      _preloadedVideos.remove(index);
    }
  }

  void _updateLoadedVideos(int newIndex) {
    if (newIndex != _currentIndex) {
      // First mute the previously playing video
      if (_preloadedVideos.containsKey(_currentIndex) && _preloadedVideos[_currentIndex]!.isInitialized) {
        _preloadedVideos[_currentIndex]!.controller.setVolume(0.0);
        // Pause the previous video
        _preloadedVideos[_currentIndex]!.controller.pause();
      }

      // Use a wider preloading range - 5 before and 5 after
      final toLoad = <int>{};

      // Add 5 previous and 5 next videos
      for (int i = newIndex - 5; i <= newIndex + 5; i++) {
        toLoad.add(i);
      }

      // Remove indices that are out of bounds
      final validToLoad = toLoad.where((idx) => idx >= 0 && idx < (_feedPosts?.length ?? 0)).toSet();

      // Find videos to unload (current loaded videos that aren't in the new set)
      final toUnload = _preloadedVideos.keys.toSet().difference(validToLoad);

      // Find videos to load (new videos that aren't already loaded)
      final newToLoad = validToLoad.difference(_preloadedVideos.keys.toSet());

      // Unload videos no longer needed
      for (final idx in toUnload) {
        _unloadVideo(idx);
      }

      // Load new videos needed - prioritize immediate next/previous first
      final priorityLoad = [newIndex];
      if (newIndex + 1 < (_feedPosts?.length ?? 0)) priorityLoad.add(newIndex + 1);
      if (newIndex - 1 >= 0) priorityLoad.add(newIndex - 1);

      // First load priority videos
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

      // Set volume and play the current video
      if (_preloadedVideos.containsKey(newIndex) && _preloadedVideos[newIndex]!.isInitialized) {
        // Set volume for current video
        _preloadedVideos[newIndex]!.controller.setVolume(1.0);
        // Play the current video
        _preloadedVideos[newIndex]!.controller.play();
      }

      // Make sure all other videos are muted
      for (final entry in _preloadedVideos.entries) {
        if (entry.key != newIndex && entry.value.isInitialized) {
          entry.value.controller.setVolume(0.0);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.white)))
                    : _feedPosts == null || _feedPosts!.isEmpty
                    ? const Center(child: Text('No videos available', style: TextStyle(color: Colors.white)))
                    : _buildVideoPageView(),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 10, left: 16.0, right: 16.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 30), // For balance
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.transparent : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: FeedSelector(
                          options: const [
                            FeedOption(label: 'Following', value: 0),
                            FeedOption(label: 'For You', value: 1),
                            FeedOption(label: 'Latest', value: 2),
                          ],
                          selectedValue: _selectedFeedType,
                          onOptionSelected: (value) {
                            setState(() {
                              _selectedFeedType = value;
                            });
                            _fetchVideos();
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.options_24_regular),
                    color: AppColors.lightLavender,
                    iconSize: 30,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPageView() {
    final actionsService = Provider.of<ActionsService>(context, listen: false);

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _feedPosts?.length ?? 0,
      onPageChanged: _updateLoadedVideos,
      itemBuilder: (context, index) {
        final post = _feedPosts![index];
        final isPreloaded = _preloadedVideos.containsKey(index) && _preloadedVideos[index]!.isInitialized;
        final isLiked = post.isLiked;

        if (isPreloaded) {
          return PreloadedVideoItem(
            key: ValueKey('video_$index'),
            index: index,
            controller: _preloadedVideos[index]!.controller,
            username: post.username,
            description: post.description,
            hashtags: post.hashtags,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            bookmarkCount: 0,
            shareCount: post.shareCount,
            profileImageUrl: post.profileImageUrl,
            authorDid: post.authorDid,
            isVisible: index == _currentIndex,
            isLiked: isLiked,
            isSprk: post.isSprk,
            onLikePressed: () => _handleLikePress(post),
            onBookmarkPressed: () {},
            onSharePressed: () {},
            onProfilePressed: () {},
            onUsernameTap: () {},
            onHashtagTap: () {},
          );
        } else {
          return VideoItem(
            key: ValueKey('placeholder_$index'),
            index: index,
            videoUrl: post.videoUrl,
            username: post.username,
            description: post.description,
            hashtags: post.hashtags,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            bookmarkCount: 0,
            shareCount: post.shareCount,
            profileImageUrl: post.profileImageUrl,
            authorDid: post.authorDid,
            isLiked: isLiked,
            isSprk: post.isSprk,
            onLikePressed: () => _handleLikePress(post),
            onBookmarkPressed: () {},
            onSharePressed: () {},
            onProfilePressed: () {},
            onUsernameTap: () {},
            onHashtagTap: () {},
          );
        }
      },
    );
  }

  Future<void> _handleLikePress(FeedPost post) async {
    final actionsService = Provider.of<ActionsService>(context, listen: false);

    try {
      // Toggle the like and get the new likeUri
      final newLikeUri = await actionsService.toggleLike(post);

      if (mounted) {
        setState(() {
          // Find the post in the list
          final index = _feedPosts?.indexWhere((p) => p.uri == post.uri) ?? -1;
          if (index >= 0 && _feedPosts != null) {
            // Create a new post with updated likeUri
            _feedPosts![index] = FeedPost(
              username: post.username,
              authorDid: post.authorDid,
              profileImageUrl: post.profileImageUrl,
              description: post.description,
              videoUrl: post.videoUrl,
              likeCount: post.likeCount + (newLikeUri != null ? 1 : post.isLiked ? -1 : 0),
              commentCount: post.commentCount,
              shareCount: post.shareCount,
              hashtags: post.hashtags,
              uri: post.uri,
              cid: post.cid,
              isSprk: post.isSprk,
              likeUri: newLikeUri,
            );
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error liking post: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}
