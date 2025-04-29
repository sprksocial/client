import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/feed_post.dart';
import '../screens/profile_screen.dart';
import '../services/actions_service.dart';
import '../services/auth_service.dart';
import '../services/feed_manager.dart';
import '../services/feed_settings_service.dart';
import '../services/media_manager.dart';
import '../widgets/snap_scroller/snap_scroller.dart';
import '../widgets/image/image_post_item.dart';
import '../widgets/video/video_item.dart';

enum ScrollDirection { FORWARD, BACKWARDS }

class FeedScreen extends StatefulWidget {
  final int feedType;
  final List<FeedPost>? initialPosts;
  final int? initialIndex;
  final bool showBackButton;

  const FeedScreen({super.key, required this.feedType, this.initialPosts, this.initialIndex, this.showBackButton = false});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final Controller _scrollController = Controller();
  final FeedManager _feedManager = FeedManager();
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
    if (widget.initialPosts != null) {
      setState(() {
        _feedPosts = widget.initialPosts;
        _isLoading = false;
        _currentIndex = widget.initialIndex ?? 0;
      });
      _preloadInitialMedia();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpToPosition(_currentIndex);
      });
    } else {
      await _fetchFeed();
    }
  }

  @override
  void dispose() {
    _mediaManager.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchFeed() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentIndex = 0;
      });

      _mediaManager.clearAllMedia();

      final authService = context.read<AuthService>();
      final posts = await _feedManager.fetchFeed(widget.feedType, authService);

      if (!mounted) return;

      final uniquePosts = _removeDuplicatePosts(posts);

      setState(() {
        _feedPosts = uniquePosts;
        _isLoading = false;
        _resetPageController();
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

  List<FeedPost> _removeDuplicatePosts(List<FeedPost> posts) {
    if (posts.isEmpty) return [];

    final uniquePosts = <FeedPost>[];

    for (final post in posts) {
      final isDuplicate = uniquePosts.any((uniquePost) => uniquePost.isDuplicateOf(post));
      if (!isDuplicate) {
        uniquePosts.add(post);
      }
    }

    return uniquePosts;
  }

  void _resetPageController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpToPosition(0);
    });
  }

  Future<void> _preloadMedia(int index) async {
    if (index < 0 || index >= (_feedPosts?.length ?? 0)) return;

    final post = _feedPosts![index];
    if (post.videoUrl != null) {
      // Force preload for the first video
      if (index == 0) {
        await _mediaManager.preloadMedia(index, post.videoUrl, post.imageUrls, context);
        if (mounted) {
          setState(() {}); // Trigger rebuild to show preloaded video
        }
      } else {
        _mediaManager.preloadMedia(index, post.videoUrl, post.imageUrls, context);
      }
    } else if (post.imageUrls.isNotEmpty) {
      _mediaManager.preloadMedia(index, null, post.imageUrls, context);
    }
  }

  Future<void> _preloadInitialMedia() async {
    if (_feedPosts == null || _feedPosts!.isEmpty) return;

    // Preload the first video immediately
    await _preloadMedia(0);

    // Preload next videos in the background
    for (int i = 1; i <= 5 && i < _feedPosts!.length; i++) {
      _preloadMedia(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          _buildMainContent(),
          if (widget.showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(FluentIcons.arrow_left_24_regular, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
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

  Widget _buildFeedPageView() {
    final feedSettings = Provider.of<FeedSettingsService>(context);
    final disableBackgroundBlur = feedSettings.disableVideoBackgroundBlur;

    return SnapScroller(
      contentSize: _feedPosts?.length ?? 0,
      controller: _scrollController,
      swipePositionThreshold: 0.12,
      swipeVelocityThreshold: 1000,
      animationDuration: const Duration(milliseconds: 150),
      animationCurve: Curves.easeOutCubic,
      builder: (context, index) {
        final post = _feedPosts![index];
        final isLiked = post.isLiked;

        if (post.videoUrl != null) {
          final isPreloaded = _mediaManager.isVideoPreloaded(index);
          final preloadedVideo = _mediaManager.getPreloadedVideo(index);

          return VideoItem(
            key: ValueKey('video_$index'),
            index: index,
            videoUrl: post.videoUrl,
            videoAlt: post.videoAlt,
            preloadedController: isPreloaded ? preloadedVideo?.controller : null,
            localVideoPath: isPreloaded ? _mediaManager.getLocalVideoPath(index) : null,
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
            disableBackgroundBlur: disableBackgroundBlur,
            onLikePressed: () => _handleLikePress(post),
            onBookmarkPressed: () {},
            onSharePressed: () {},
            onProfilePressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(did: post.authorDid))).catchError((error) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Could not load profile: ${error.toString()}')));
                return null;
              });
            },
            onUsernameTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(did: post.authorDid))).catchError((error) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Could not load profile: ${error.toString()}')));
                return null;
              });
            },
            onHashtagTap: (String hashtag) {},
            onPostDeleted: () {
              _fetchFeed();
            },
          );
        } else if (post.imageUrls.isNotEmpty) {
          return ImagePostItem(
            key: ValueKey('image_$index'),
            index: index,
            imageUrls: post.imageUrls,
            imageAlts: post.imageAlts,
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
            disableBackgroundBlur: disableBackgroundBlur,
            onLikePressed: () => _handleLikePress(post),
            onBookmarkPressed: () {},
            onSharePressed: () {},
            onUsernameTap: () {},
            onHashtagTap: (String hashtag) {},
          );
        } else {
          return const SizedBox.shrink();
        }
      },
      onIndexChanged: (newIndex) {
        if (_currentIndex != newIndex) {
          final scrollDirection = newIndex > _currentIndex ? ScrollDirection.FORWARD : ScrollDirection.BACKWARDS;

          setState(() {
            // Update media manager first to handle audio transitions
            _mediaManager.updateLoadedMedia(newIndex, _currentIndex, _feedPosts?.length ?? 0);
            _currentIndex = newIndex;
          });

          final totalPosts = _feedPosts?.length ?? 0;

          // Unload videos that are more than 10 positions away
          for (int i = 0; i < totalPosts; i++) {
            if (i < newIndex - 10 || i > newIndex + 10) {
              _mediaManager.unloadVideo(i);
            }
          }

          // Preload videos based on scroll direction
          if (scrollDirection == ScrollDirection.FORWARD) {
            // Preload more videos ahead when scrolling forward
            for (int i = newIndex + 1; i <= newIndex + 5; i++) {
              if (i < totalPosts) {
                _preloadMedia(i);
              }
            }
            // Preload fewer videos behind
            for (int i = newIndex - 1; i >= newIndex - 3; i--) {
              if (i >= 0) {
                _preloadMedia(i);
              }
            }
          } else {
            // Preload more videos behind when scrolling backward
            for (int i = newIndex - 1; i >= newIndex - 5; i--) {
              if (i >= 0) {
                _preloadMedia(i);
              }
            }
            // Preload fewer videos ahead
            for (int i = newIndex + 1; i <= newIndex + 3; i++) {
              if (i < totalPosts) {
                _preloadMedia(i);
              }
            }
          }
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
            videoAlt: post.videoAlt,
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
            imageAlts: post.imageAlts,
            isSprk: post.isSprk,
            likeUri: newLikeUri,
            hasMedia: post.hasMedia,
            isReply: post.isReply,
            imageUrls: post.imageUrls,
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
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}

class CustomPageViewPhysics extends ScrollPhysics {
  const CustomPageViewPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomPageViewPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    return null;
  }
}
