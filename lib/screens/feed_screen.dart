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
import '../services/labeler_manager.dart';
import '../widgets/censorship/warn_builder.dart';
import '../widgets/image/image_post_item.dart';
import '../widgets/video/preloaded_video_item.dart';
import '../widgets/video/video_item.dart';

class FeedScreen extends StatefulWidget {
  final int feedType;
  final List<FeedPost>? initialPosts;
  final int? initialIndex;
  final bool showBackButton;
  final bool isParentFeedVisible;

  const FeedScreen({
    super.key,
    required this.feedType,
    this.initialPosts,
    this.initialIndex,
    this.showBackButton = false,
    required this.isParentFeedVisible,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin<FeedScreen> {
  final PageController _pageController = PageController();
  final FeedManager _feedManager = FeedManager();
  final MediaManager _mediaManager = MediaManager();

  List<FeedPost>? _feedPosts;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _wasPlayingBeforePause = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void didUpdateWidget(FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isParentFeedVisible != widget.isParentFeedVisible) {
      if (!widget.isParentFeedVisible) {
        final controller = _mediaManager.getPreloadedVideo(_currentIndex)?.controller;
        _wasPlayingBeforePause = controller?.value.isPlaying ?? false;
        _mediaManager.pauseVideo(_currentIndex);
      } else {
        if (_wasPlayingBeforePause) {
          _mediaManager.resumeVideo(_currentIndex);
        }
        _wasPlayingBeforePause = false;
      }
    }
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
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentIndex);
        }
      });
    } else {
      await _fetchFeed();
    }
  }

  @override
  void dispose() {
    _mediaManager.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchFeed() async {
    if (!mounted) return;

    _mediaManager.pauseVideo(_currentIndex);

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentIndex = 0;
      });

      final authService = context.read<AuthService>();
      final labelerManager = context.read<LabelerManager>();
      _feedManager.setLabelerManager(labelerManager);
      
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
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  Future<void> _preloadMedia(int index) async {
    if (index < 0 || index >= (_feedPosts?.length ?? 0)) return;

    final post = _feedPosts![index];
    if (post.videoUrl != null) {
      if (index == 0) {
        await _mediaManager.preloadMedia(index, post.videoUrl, post.imageUrls, context);
        if (mounted) {
          setState(() {});
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

    await _preloadMedia(0);

    for (int i = 1; i <= 3 && i < _feedPosts!.length; i++) {
      _preloadMedia(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Optimization: Check if feed posts are available and parent is visible
    // before building the PageView. Reduces build calls when hidden.
    bool canBuildPageView = _feedPosts != null && _feedPosts!.isNotEmpty && !_isLoading && _errorMessage == null;

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          _buildMainContent(canBuildPageView),
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

  Widget _buildMainContent(bool canBuildPageView) {
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
              : canBuildPageView
              ? _buildFeedPageView()
              : const SizedBox.shrink(),
    );
  }

  Widget _buildFeedPageView() {
    final feedSettings = Provider.of<FeedSettingsService>(context);
    final disableBackgroundBlur = feedSettings.disableVideoBackgroundBlur;

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: widget.isParentFeedVisible ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
      itemCount: _feedPosts?.length ?? 0,
      onPageChanged: (newIndex) {
        if (_currentIndex != newIndex) {
          _mediaManager.pauseVideo(_currentIndex);

          setState(() {
            _mediaManager.updateLoadedMedia(newIndex, _currentIndex, _feedPosts?.length ?? 0);
            _currentIndex = newIndex;
          });

          final totalPosts = _feedPosts?.length ?? 0;

          // Unload videos that are more than 6 positions away (reduced)
          for (int i = 0; i < totalPosts; i++) {
            if (i < newIndex - 6 || i > newIndex + 6) {
              _mediaManager.unloadVideo(i);
            }
          }

          // Preload videos within 3 positions (reduced)
          for (int i = newIndex - 3; i <= newIndex + 3; i++) {
            if (i >= 0 && i < totalPosts) {
              _preloadMedia(i);
            }
          }
        }
      },
      itemBuilder: (context, index) {
        final post = _feedPosts![index];
        final isLiked = post.isLiked;

        final bool isItemActuallyVisible = (index == _currentIndex) && widget.isParentFeedVisible;

        // Check if the content should show a warning
        final bool shouldWarn = _feedManager.shouldWarnContent(post);
        
        // Get warning message if needed
        String? warningMessage;
        if (shouldWarn) {
          final warningMessages = _feedManager.getWarningMessages(post);
          if (warningMessages.isNotEmpty) {
            warningMessage = warningMessages.join(", ");
          }
        }

        // Build the appropriate media widget based on the post type
        Widget contentWidget;
        
        if (post.videoUrl != null) {
          final isPreloaded = _mediaManager.isVideoPreloaded(index);
          final preloadedVideo = _mediaManager.getPreloadedVideo(index);

          if (isPreloaded && preloadedVideo != null) {
            contentWidget = PreloadedVideoItem(
              key: ValueKey('video_$index'),
              index: index,
              controller: preloadedVideo.controller,
              isVisible: isItemActuallyVisible,
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
              disableBackgroundBlur: disableBackgroundBlur,
              videoAlt: post.videoAlt,
              onLikePressed: () => _handleLikePress(post),
              onBookmarkPressed: () {},
              onSharePressed: () {},
              onRefresh: index == 0 ? _fetchFeed : null,
              onProfilePressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(did: post.authorDid))).catchError((
                  error,
                ) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Could not load profile: ${error.toString()}')));
                  return null;
                });
              },
              onUsernameTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(did: post.authorDid))).catchError((
                  error,
                ) {
                  if (!context.mounted) return;
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
          } else {
            contentWidget = VideoItem(
              key: ValueKey('video_$index'),
              index: index,
              videoUrl: post.videoUrl,
              videoAlt: post.videoAlt,
              preloadedController: isPreloaded ? preloadedVideo?.controller : null,
              localVideoPath: isPreloaded ? _mediaManager.getLocalVideoPath(index) : null,
              isVisible: isItemActuallyVisible,
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
              disableBackgroundBlur: disableBackgroundBlur,
              onLikePressed: () => _handleLikePress(post),
              onBookmarkPressed: () {},
              onSharePressed: () {},
              onRefresh: index == 0 ? _fetchFeed : null,
              onProfilePressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(did: post.authorDid))).catchError((
                  error,
                ) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Could not load profile: ${error.toString()}')));
                  return null;
                });
              },
              onUsernameTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(did: post.authorDid))).catchError((
                  error,
                ) {
                  if (!context.mounted) return;
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
          }
        } else if (post.imageUrls.isNotEmpty) {
          contentWidget = ImagePostItem(
            key: ValueKey('image_$index'),
            index: index,
            imageUrls: post.imageUrls,
            imageAlts: post.imageAlts,
            isVisible: isItemActuallyVisible,
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
            disableBackgroundBlur: disableBackgroundBlur,
            onLikePressed: () => _handleLikePress(post),
            onBookmarkPressed: () {},
            onSharePressed: () {},
            onUsernameTap: () {},
            onHashtagTap: (String hashtag) {},
          );
        } else {
          contentWidget = const Center(child: Text('Unsupported media type', style: TextStyle(color: Colors.white)));
        }

        // If content should show a warning, wrap it in a WarnBuilder
        if (shouldWarn && post.labels.isNotEmpty) {
          // Get the first label source (labelerDid) - in a more complete implementation,
          // we might want to show warnings from multiple labelers
          final labelerDid = Provider.of<LabelerManager>(context, listen: false).followedLabelers.firstOrNull ?? 'unknown';
          
          // Get the first label value - same comment as above about multiple labels
          final labelValue = post.labels.first;
          
          // Get the blurType from the label definition
          final labelDefinitions = Provider.of<LabelerManager>(context, listen: false)
              .getLabelDefinitions(labelerDid);
          final labelDefinition = labelDefinitions[labelValue];
          final String blurType = labelDefinition?['blurs'] as String? ?? 'content';
          
          debugPrint("Content warning: $labelerDid, $labelValue, $warningMessage, blur: $blurType");
          return WarnBuilder(
            labelerDid: labelerDid,
            labelValue: labelValue,
            warningMessage: warningMessage,
            blurType: blurType,
            child: contentWidget,
          );
        }

        // Otherwise, just return the content widget directly
        return contentWidget;
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
