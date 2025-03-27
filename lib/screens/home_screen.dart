import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../widgets/video/video_item.dart';
import '../widgets/video/preloaded_video_item.dart';
import '../widgets/image/image_post_item.dart';
import '../widgets/feed/feed_selector.dart';
import '../widgets/feed_settings/feed_settings_sheet.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../services/actions_service.dart';
import '../models/feed_post.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  bool _disableVideoBackgroundBlur = false; // New setting for video background blur

  // Pre-initialized VideoPlayerControllers mapped by index
  final Map<int, PreloadedVideo> _preloadedVideos = {};

  // Track which image URLs have been preloaded
  final Set<String> _preloadedImageUrls = {};

  @override
  void initState() {
    super.initState();
    _fetchFeed();
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

  Future<void> _fetchFeed() async {
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
      final allPosts = feed.data.feed.map((item) => FeedPost.fromBlueskyFeed(item)).toList();

      // Filter posts to only show those with media that aren't replies
      final filteredPosts = allPosts.where((post) => post.hasMedia && !post.isReply).toList();


      setState(() {
        _feedPosts = filteredPosts;
        _isLoading = false;
        _preloadInitialMedia();
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
      final allPosts = feed.data.feed.map((item) => FeedPost.fromBlueskyFeed(item)).toList();

      // Filter posts to only show those with media that aren't replies
      final filteredPosts = allPosts.where((post) => post.hasMedia && !post.isReply).toList();

      setState(() {
        _feedPosts = filteredPosts;
        _isLoading = false;
        _preloadInitialMedia();
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
        // Convert to our unified model and filter
        final allFeedPosts = posts.map((post) {
          // Create a feed item with the post
          final feedItem = {'post': post};
          return FeedPost.fromSparkFeed(feedItem);
        }).toList();

        // Filter posts to only show those with media that aren't replies
        final filteredPosts = allFeedPosts.where((post) => post.hasMedia && !post.isReply).toList();

        setState(() {
          _feedPosts = filteredPosts;
          _isLoading = false;
          _preloadInitialMedia();
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

  void _preloadInitialMedia() {
    // Clear existing preloaded videos
    for (final video in _preloadedVideos.values) {
      video.controller.dispose();
    }
    _preloadedVideos.clear();
    _preloadedImageUrls.clear();

    // Reset current index
    _currentIndex = 0;

    // Preload initial batch of media
    if (_feedPosts != null && _feedPosts!.isNotEmpty) {
      // Start loading in order of priority
      _preloadMedia(0); // Current item first

      // Then preload the others
      for (int i = 1; i <= 5 && i < _feedPosts!.length; i++) {
        _preloadMedia(i);
      }
    }
  }

  void _preloadMedia(int index) {
    if (index < 0 || index >= (_feedPosts?.length ?? 0)) {
      return;
    }

    final post = _feedPosts![index];

    // Preload video if exists
    if (post.videoUrl != null) {
      _preloadVideo(index);
    }
    // Preload images if exist
    else if (post.imageUrls.isNotEmpty) {
      _preloadImages(post.imageUrls);
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (_preloadedVideos.containsKey(index)) {
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

  void _preloadImages(List<String> urls) {
    for (final url in urls) {
      if (!_preloadedImageUrls.contains(url)) {
        _preloadedImageUrls.add(url);
        precacheImage(CachedNetworkImageProvider(url), context);
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

  void _updateLoadedMedia(int newIndex) {
    if (newIndex != _currentIndex) {
      // Handle video playback for the current and previous video
      if (_feedPosts != null && _feedPosts!.isNotEmpty) {
        final currentPost = _feedPosts![_currentIndex];
        final newPost = _feedPosts![newIndex];

        // Handle previous video if it exists
        if (currentPost.videoUrl != null && _preloadedVideos.containsKey(_currentIndex)) {
          // Mute and pause the previously playing video
          _preloadedVideos[_currentIndex]!.controller.setVolume(0.0);
          _preloadedVideos[_currentIndex]!.controller.pause();
        }

        // Handle new video if it exists
        if (newPost.videoUrl != null && _preloadedVideos.containsKey(newIndex)) {
          // Set volume and play the current video
          _preloadedVideos[newIndex]!.controller.setVolume(1.0);
          _preloadedVideos[newIndex]!.controller.play();
        }
      }

      // Use a wider preloading range - 5 before and 5 after
      final toLoad = <int>{};

      // Add 5 previous and 5 next items
      for (int i = newIndex - 5; i <= newIndex + 5; i++) {
        toLoad.add(i);
      }

      // Remove indices that are out of bounds
      final validToLoad = toLoad.where((idx) => idx >= 0 && idx < (_feedPosts?.length ?? 0)).toSet();

      // Find videos to unload (current loaded videos that aren't in the new set)
      final toUnload = _preloadedVideos.keys.toSet().difference(validToLoad);

      // Find items to load (new items that aren't already loaded)
      final newToLoad = validToLoad.difference(_preloadedVideos.keys.toSet());

      // Unload videos no longer needed
      for (final idx in toUnload) {
        _unloadVideo(idx);
      }

      // Load new videos needed - prioritize immediate next/previous first
      final priorityLoad = [newIndex];
      if (newIndex + 1 < (_feedPosts?.length ?? 0)) priorityLoad.add(newIndex + 1);
      if (newIndex - 1 >= 0) priorityLoad.add(newIndex - 1);

      // First load priority items
      for (final idx in priorityLoad) {
        if (newToLoad.contains(idx)) {
          _preloadMedia(idx);
          newToLoad.remove(idx);
        }
      }

      // Then load the rest
      for (final idx in newToLoad) {
        _preloadMedia(idx);
      }

      // Update current index
      _currentIndex = newIndex;
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
                    ? const Center(child: Text('No media available', style: TextStyle(color: Colors.white)))
                    : _buildFeedPageView(),
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
                            _fetchFeed();
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.options_24_regular),
                    color: AppColors.lightLavender,
                    iconSize: 30,
                    onPressed: () {
                      _showFeedSettingsSheet(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedPageView() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _feedPosts?.length ?? 0,
      onPageChanged: _updateLoadedMedia,
      itemBuilder: (context, index) {
        final post = _feedPosts![index];
        final isLiked = post.isLiked;

        // For video posts
        if (post.videoUrl != null) {
          final isPreloaded = _preloadedVideos.containsKey(index) && _preloadedVideos[index]!.isInitialized;

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
              videoUri: post.uri,
              disableBackgroundBlur: _disableVideoBackgroundBlur,
              onLikePressed: () => _handleLikePress(post),
              onBookmarkPressed: () {},
              onSharePressed: () {},
              onProfilePressed: () {},
              onUsernameTap: () {},
              onHashtagTap: (String hashtag) {},
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
              videoUri: post.uri,
              disableBackgroundBlur: _disableVideoBackgroundBlur,
              onLikePressed: () => _handleLikePress(post),
              onBookmarkPressed: () {},
              onSharePressed: () {},
              onProfilePressed: () {},
              onUsernameTap: () {},
              onHashtagTap: (String hashtag) {},
            );
          }
        }
        // For image posts
        else if (post.imageUrls.isNotEmpty) {
          return ImagePostItem(
            key: ValueKey('image_$index'),
            index: index,
            imageUrls: post.imageUrls,
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
            postUri: post.uri,
            isVisible: index == _currentIndex,
            disableBackgroundBlur: _disableVideoBackgroundBlur,
            onLikePressed: () => _handleLikePress(post),
            onBookmarkPressed: () {},
            onSharePressed: () {},
            onProfilePressed: () {},
            onUsernameTap: () {},
            onHashtagTap: (String hashtag) {},
          );
        }
        // Fallback for any other post type
        else {
          return Center(
            child: Text(
              'Unsupported media type',
              style: const TextStyle(color: Colors.white),
            ),
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
              hasMedia: post.hasMedia,
              isReply: post.isReply,
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

  void _showFeedSettingsSheet(BuildContext context) {
    final feedSettings = [
      FeedSetting(
        feedName: 'Following',
        settingType: 'following_feed',
        isEnabled: true,
      ),
      FeedSetting(
        feedName: 'For You',
        settingType: 'for_you_feed',
        isEnabled: true,
      ),
      FeedSetting(
        feedName: 'Latest',
        settingType: 'latest_feed',
        isEnabled: true,
      ),
      FeedSetting(
        feedName: 'Disable Background Blur',
        settingType: 'disable_background_blur',
        description: 'Turn off the background blur effect on media',
        isEnabled: _disableVideoBackgroundBlur,
      ),
    ];

    // Use modal bottom sheet with proper configuration
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: Navigator.of(context),
      ),
      builder: (context) => GestureDetector(
        // This is needed to prevent taps from dismissing the modal
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: FeedSettingsSheet(
          feedSettings: feedSettings,
          onToggleChanged: (settingType, isEnabled) {
            // Handle feed toggle changes
            if (settingType == 'disable_background_blur') {
              setState(() {
                _disableVideoBackgroundBlur = isEnabled;
              });
              return;
            }
            
            final feedName = _getFeedNameFromSettingType(settingType);
            if (!isEnabled && _getSelectedFeedNameFromIndex() == feedName) {
              // Don't allow disabling the currently selected feed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cannot disable active feed')),
              );
              return;
            }

            // Here you would typically persist the settings
            // Don't automatically close on toggle
          },
        ),
      ),
    );
  }

  String _getFeedNameFromSettingType(String settingType) {
    switch (settingType) {
      case 'following_feed':
        return 'Following';
      case 'for_you_feed':
        return 'For You';
      case 'latest_feed':
        return 'Latest';
      default:
        return '';
    }
  }

  String _getSelectedFeedNameFromIndex() {
    switch (_selectedFeedType) {
      case 0:
        return 'Following';
      case 1:
        return 'For You';
      case 2:
        return 'Latest';
      default:
        return 'For You';
    }
  }
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}
