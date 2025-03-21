import 'dart:ui'; // For ImageFilter
import 'package:atproto/core.dart';
import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../widgets/video/video_item.dart';
import '../widgets/video/preloaded_video_item.dart';
import '../widgets/video_controls/video_controller_overlay.dart';
import '../widgets/video_info/video_info_bar.dart';
import '../widgets/video_side_action_bar.dart';
import '../widgets/comments_tray.dart';
import '../utils/app_theme.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  List<dynamic>? _feedItems;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

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

      setState(() {
        _feedItems = feed.data.feed;
        _isLoading = false;

        // Preload initial batch of videos
        if (_feedItems != null && _feedItems!.isNotEmpty) {
          final initialLoad = <int>{0};

          // Add up to 5 more videos to preload
          for (int i = 1; i <= 5 && i < _feedItems!.length; i++) {
            initialLoad.add(i);
          }

          // Start loading in order of priority
          _preloadVideo(0); // Current video first

          // Then preload the others
          for (int i = 1; i <= 5 && i < _feedItems!.length; i++) {
            _preloadVideo(i);
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (index < 0 || index >= (_feedItems?.length ?? 0) || _preloadedVideos.containsKey(index)) {
      return;
    }

    final feedItem = _feedItems![index];
    final post = feedItem.post;

    String? videoUrl;
    if (post.embed?.data is EmbedVideoView) {
      videoUrl = (post.embed?.data as EmbedVideoView).playlist;
    }

    if (videoUrl != null) {
      // Create a new controller
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      try {
        // Register it as non-initialized first
        _preloadedVideos[index] = PreloadedVideo(
          controller: controller,
          isInitialized: false,
          videoUrl: videoUrl,
        );

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
            _preloadedVideos[index] = PreloadedVideo(
              controller: controller,
              isInitialized: true,
              videoUrl: videoUrl,
            );
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
      if (_preloadedVideos.containsKey(_currentIndex) &&
          _preloadedVideos[_currentIndex]!.isInitialized) {
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
      final validToLoad = toLoad.where(
        (idx) => idx >= 0 && idx < (_feedItems?.length ?? 0)
      ).toSet();

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
      if (newIndex + 1 < (_feedItems?.length ?? 0)) priorityLoad.add(newIndex + 1);
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
      if (_preloadedVideos.containsKey(newIndex) &&
          _preloadedVideos[newIndex]!.isInitialized) {
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
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                ? Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.white)))
                : _feedItems == null || _feedItems!.isEmpty
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
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(value: 0, label: Text('Following')),
                          ButtonSegment<int>(value: 1, label: Text('For You')),
                        ],
                        onSelectionChanged: (Set<int> value) {},
                        selected: const {1}, // Default to "For You"
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (states) =>
                                states.contains(WidgetState.selected)
                                    ? AppColors.white
                                    : isDarkMode
                                    ? Colors.black
                                    : AppColors.darkBackground,
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                            (states) => states.contains(WidgetState.selected) ? AppColors.black : AppTheme.getTextColor(context),
                          ),
                          side: WidgetStateProperty.all(BorderSide(color: isDarkMode ? Colors.grey : AppColors.divider)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.search_24_regular),
                    color: AppTheme.getTextColor(context),
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
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _feedItems?.length ?? 0,
      onPageChanged: _updateLoadedVideos,
      itemBuilder: (context, index) {
        final feedItem = _feedItems![index];
        final post = feedItem.post;

        final username = post.author.handle;
        final description = post.record.text;
        final hashtags = ['spark', 'sample', 'video${index + 1}'];
        final likeCount = post.likeCount ?? 0;
        final commentCount = post.replyCount ?? 0;
        final bookmarkCount = 0;
        final shareCount = post.repostCount ?? 0;

        // Extract profile image URL
        String? profileImageUrl;
        if (post.author.avatar != null) {
          profileImageUrl = post.author.avatar;
        }

        final isPreloaded = _preloadedVideos.containsKey(index) &&
                           _preloadedVideos[index]!.isInitialized;

        if (isPreloaded) {
          return PreloadedVideoItem(
            key: ValueKey('video_$index'),
            index: index,
            controller: _preloadedVideos[index]!.controller,
            username: username,
            description: description,
            hashtags: hashtags,
            likeCount: likeCount,
            commentCount: commentCount,
            bookmarkCount: bookmarkCount,
            shareCount: shareCount,
            profileImageUrl: profileImageUrl,
            authorDid: post.author.did,
            isVisible: index == _currentIndex,
            onLikePressed: () {},
            onBookmarkPressed: () {},
            onSharePressed: () {},
            onProfilePressed: () {},
            onUsernameTap: () {},
            onHashtagTap: () {},
          );
        } else {
          // For videos not yet preloaded
          String? videoUrl;
          if (post.embed?.data is EmbedVideoView) {
            videoUrl = (post.embed?.data as EmbedVideoView).playlist;
          }

          return VideoItem(
            key: ValueKey('placeholder_$index'),
            index: index,
            videoUrl: videoUrl,
            username: username,
            description: description,
            hashtags: hashtags,
            likeCount: likeCount,
            commentCount: commentCount,
            bookmarkCount: bookmarkCount,
            shareCount: shareCount,
            profileImageUrl: profileImageUrl,
            authorDid: post.author.did,
            onLikePressed: () {},
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
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({
    required this.controller,
    required this.isInitialized,
    required this.videoUrl,
  });
}

class PreloadedVideoItem extends StatefulWidget {
  final int index;
  final VideoPlayerController controller;
  final String username;
  final String description;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;
  final String? profileImageUrl;
  final bool isVisible;
  final VoidCallback? onLikePressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onHashtagTap;
  final String? authorDid;

  const PreloadedVideoItem({
    super.key,
    required this.index,
    required this.controller,
    this.username = '',
    this.description = '',
    this.hashtags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
    this.profileImageUrl,
    required this.isVisible,
    this.onLikePressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    this.onProfilePressed,
    this.onUsernameTap,
    this.onHashtagTap,
    this.authorDid,
  });

  @override
  State<PreloadedVideoItem> createState() => _PreloadedVideoItemState();
}

class _PreloadedVideoItemState extends State<PreloadedVideoItem> {
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _updatePlayState();
  }

  @override
  void didUpdateWidget(PreloadedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isVisible != widget.isVisible) {
      _updatePlayState();
    }
  }

  void _updatePlayState() {
    if (widget.isVisible && !_showComments) {
      widget.controller.play();
    } else {
      widget.controller.pause();
    }
  }

  void _toggleComments() {
    widget.controller.pause();

    setState(() {
      _showComments = true;
    });

    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    showCommentsTray(
      context: context,
      videoId: 'video_${widget.index + 1}',
      commentCount: widget.commentCount,
      onClose: () {
        setState(() {
          _showComments = false;
          if (widget.isVisible) {
            widget.controller.play();
          }
        });
      },
      isDarkMode: isDarkMode,
    );
  }

  void _navigateToProfile() {
    if (widget.authorDid != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
            ProfileScreen(did: widget.authorDid),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }

    // Still call the original callback if provided
    if (widget.onProfilePressed != null) {
      widget.onProfilePressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBlurredBackground(isDarkMode),

          Center(child: _buildVideoContent()),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withAlpha(10),
                    Colors.black.withAlpha(40),
                    Colors.black.withAlpha(80),
                    Colors.black.withAlpha(160),
                  ],
                  stops: const [0.0, 0.5, 0.65, 0.75, 0.85, 0.95],
                ),
              ),
            ),
          ),

          VideoControllerOverlay(controller: widget.controller, onTap: () {}),

          Positioned(
            bottom: 20,
            left: 10,
            right: 70, // Give space for the side action bar
            child: VideoInfoBar(
              username: widget.username,
              description: widget.description,
              hashtags: widget.hashtags,
              onUsernameTap: widget.onUsernameTap,
              onHashtagTap: widget.onHashtagTap,
            ),
          ),

          Positioned(
            right: 10,
            bottom: 100,
            child: VideoSideActionBar(
              likeCount: '${widget.likeCount}K',
              commentCount: '${widget.commentCount}K',
              bookmarkCount: '${widget.bookmarkCount}K',
              shareCount: '${widget.shareCount}K',
              profileImageUrl: widget.profileImageUrl,
              onLikePressed: widget.onLikePressed ?? () {},
              onCommentPressed: _toggleComments,
              onBookmarkPressed: widget.onBookmarkPressed ?? () {},
              onSharePressed: widget.onSharePressed ?? () {},
              onProfilePressed: _navigateToProfile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: widget.controller.value.size.width,
            height: widget.controller.value.size.height,
            child: VideoPlayer(widget.controller),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(color: isDarkMode ? Colors.black.withAlpha(128) : AppColors.darkBackground.withAlpha(128)),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    final videoSize = widget.controller.value.size;
    double aspectRatio = videoSize.width / videoSize.height;

    if (aspectRatio > 1) {
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(widget.controller)
        ),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: VideoPlayer(widget.controller)
    );
  }
}
