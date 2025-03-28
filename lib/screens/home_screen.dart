import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/feed_post.dart';
import '../services/actions_service.dart';
import '../services/auth_service.dart';
import '../services/feed_manager.dart';
import '../services/feed_settings_service.dart';
import '../services/media_manager.dart';
import '../utils/app_colors.dart';
import '../widgets/feed/feed_selector.dart';
import '../widgets/feed_settings/feed_settings_sheet.dart';
import '../widgets/image/image_post_item.dart';
import '../widgets/video/preloaded_video_item.dart';
import '../widgets/video/video_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final FeedManager _feedManager = FeedManager();
  final FeedSettingsService _feedSettings = FeedSettingsService();
  final MediaManager _mediaManager = MediaManager();

  List<FeedPost>? _feedPosts;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _feedSettings.loadPreferences();
    await _fetchFeed();
  }

  @override
  void dispose() {
    _mediaManager.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchFeed() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentIndex = 0; // Reset current index when changing feeds
      });

      // Clear all preloaded media to avoid mixing videos between feeds
      _mediaManager.clearAllMedia();

      // Get new feed content
      final authService = context.read<AuthService>();
      final posts = await _feedManager.fetchFeed(_feedSettings.selectedFeedType, authService);

      if (!mounted) return;

      setState(() {
        _feedPosts = posts;
        _isLoading = false;

        // Reset page controller safely after new content is loaded
        _resetPageController();

        // Preload media for the current feed
        _preloadInitialMedia();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _resetPageController() {
    // Schedule this for the next frame when the PageView will be built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  void _preloadInitialMedia() {
    if (_feedPosts == null || _feedPosts!.isEmpty) return;

    // Start with current item
    _preloadMedia(0);

    // Then preload the next few items
    for (int i = 1; i <= 5 && i < _feedPosts!.length; i++) {
      _preloadMedia(i);
    }
  }

  void _preloadMedia(int index) {
    if (index < 0 || index >= (_feedPosts?.length ?? 0)) return;

    final post = _feedPosts![index];
    _mediaManager.preloadMedia(index, post.videoUrl, post.imageUrls, context);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Get available feed options based on enabled status
    final List<FeedOption> feedOptions = _buildFeedOptions();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [_buildMainContent(), _buildTopBar(topPadding, isDarkMode, feedOptions)]),
    );
  }

  List<FeedOption> _buildFeedOptions() {
    final options = <FeedOption>[];

    if (_feedSettings.followingFeedEnabled) {
      options.add(const FeedOption(label: 'Following', value: 0));
    }

    if (_feedSettings.forYouFeedEnabled) {
      options.add(const FeedOption(label: 'For You', value: 1));
    }

    if (_feedSettings.latestFeedEnabled) {
      options.add(const FeedOption(label: 'Latest', value: 2));
    }

    return options;
  }

  Widget _buildMainContent() {
    return SizedBox(
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
    );
  }

  Widget _buildTopBar(double topPadding, bool isDarkMode, List<FeedOption> feedOptions) {
    return Positioned(
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
                  decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
                  child:
                      feedOptions.isNotEmpty
                          ? FeedSelector(
                            options: feedOptions,
                            selectedValue: _feedSettings.selectedFeedType,
                            onOptionSelected: _onFeedSelected,
                          )
                          : const SizedBox(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(FluentIcons.options_24_regular),
              color: AppColors.lightLavender,
              iconSize: 30,
              onPressed: () => _showFeedSettingsSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onFeedSelected(int value) async {
    // Only jump to page if controller is attached
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    await _feedSettings.setSelectedFeedType(value);
    if (mounted) {
      _fetchFeed();
    }
  }

  Widget _buildFeedPageView() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _feedPosts?.length ?? 0,
      onPageChanged: (newIndex) {
        if (_currentIndex != newIndex) {
          setState(() {
            _mediaManager.updateLoadedMedia(newIndex, _currentIndex, _feedPosts?.length ?? 0);
            _currentIndex = newIndex;
          });

          // Preload a few more items ahead if we're getting close to the end
          if (newIndex + 3 >= (_feedPosts?.length ?? 0)) {
            for (int i = newIndex + 1; i < (_feedPosts?.length ?? 0); i++) {
              _preloadMedia(i);
            }
          }
        }
      },
      itemBuilder: (context, index) {
        final post = _feedPosts![index];
        final isLiked = post.isLiked;

        // For video posts
        if (post.videoUrl != null) {
          final isPreloaded = _mediaManager.isVideoPreloaded(index);
          final preloadedVideo = _mediaManager.getPreloadedVideo(index);

          if (isPreloaded && preloadedVideo != null) {
            return PreloadedVideoItem(
              key: ValueKey('video_$index'),
              index: index,
              controller: preloadedVideo.controller,
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
              postUri: post.uri,
              postCid: post.cid,
              disableBackgroundBlur: _feedSettings.disableVideoBackgroundBlur,
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
              postUri: post.uri,
              postCid: post.cid,
              disableBackgroundBlur: _feedSettings.disableVideoBackgroundBlur,
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
            postCid: post.cid,
            isVisible: index == _currentIndex,
            disableBackgroundBlur: _feedSettings.disableVideoBackgroundBlur,
            onLikePressed: () => _handleLikePress(post),
            onBookmarkPressed: () {},
            onSharePressed: () {},
            onUsernameTap: () {},
            onHashtagTap: (String hashtag) {},
          );
        }
        // Fallback for any other post type
        else {
          return const Center(child: Text('Unsupported media type', style: TextStyle(color: Colors.white)));
        }
      },
    );
  }

  Future<void> _handleLikePress(FeedPost post) async {
    final actionsService = Provider.of<ActionsService>(context, listen: false);

    try {
      final newLikeUri = await actionsService.toggleLike(post);

      if (!mounted) return;

      setState(() {
        final index = _feedPosts?.indexWhere((p) => p.uri == post.uri) ?? -1;
        if (index >= 0 && _feedPosts != null) {
          _feedPosts![index] = FeedPost(
            username: post.username,
            authorDid: post.authorDid,
            profileImageUrl: post.profileImageUrl,
            description: post.description,
            videoUrl: post.videoUrl,
            likeCount:
                post.likeCount +
                (newLikeUri != null
                    ? 1
                    : post.isLiked
                    ? -1
                    : 0),
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error liking post: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  void _showFeedSettingsSheet(BuildContext context) {
    final feedSettings = [
      FeedSetting(feedName: 'Following', settingType: 'following_feed', isEnabled: _feedSettings.followingFeedEnabled),
      FeedSetting(feedName: 'For You', settingType: 'for_you_feed', isEnabled: _feedSettings.forYouFeedEnabled),
      FeedSetting(feedName: 'Latest', settingType: 'latest_feed', isEnabled: _feedSettings.latestFeedEnabled),
      FeedSetting(
        feedName: 'Disable Background Blur',
        settingType: 'disable_background_blur',
        description: 'Turn off the background blur effect on media',
        isEnabled: _feedSettings.disableVideoBackgroundBlur,
      ),
    ];

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
      builder:
          (context) => GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: FeedSettingsSheet(feedSettings: feedSettings, onToggleChanged: _handleSettingToggle),
          ),
    );
  }

  Future<void> _handleSettingToggle(String settingType, bool isEnabled) async {
    if (settingType == 'disable_background_blur') {
      await _feedSettings.setBackgroundBlur(isEnabled);
      setState(() {});
      return;
    }

    if (!isEnabled && !_feedSettings.canDisableFeed(settingType)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot disable this feed')));
      return;
    }

    await _feedSettings.toggleFeed(settingType, isEnabled);

    if (mounted) {
      setState(() {});

      // If the current feed was disabled, fetch the new feed
      if (!isEnabled && _feedSettings.getFeedTypeFromSetting(settingType) == _feedSettings.selectedFeedType) {
        _fetchFeed();
      }
    }
  }
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}
