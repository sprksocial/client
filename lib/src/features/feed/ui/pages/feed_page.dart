import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:auto_route/auto_route.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/data/models/feed_page_state.dart';
import 'package:sparksocial/src/features/feed/providers/feed_page_provider.dart';
import 'package:sparksocial/src/features/feed/providers/preload_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/preloaded_video_item.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_post_item.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_post_item.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/common/warn_builder.dart';

@RoutePage()
class FeedPage extends ConsumerStatefulWidget {
  final int feedType;
  final List<FeedPost>? initialPosts;
  final int? initialIndex;
  final bool showBackButton;
  final bool isParentFeedVisible;

  const FeedPage({
    super.key,
    required this.feedType,
    this.initialPosts,
    this.initialIndex,
    this.showBackButton = false,
    required this.isParentFeedVisible,
  });

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> with AutomaticKeepAliveClientMixin<FeedPage> {
  final PageController _pageController = PageController();
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Jump to the initial index if provided
      if (widget.initialIndex != null && _pageController.hasClients) {
        _pageController.jumpToPage(widget.initialIndex!);
      }
    });
  }
  
  @override
  void didUpdateWidget(FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isParentFeedVisible != widget.isParentFeedVisible) {
      // Handle parent visibility changes
      ref.read(feedPageStateNotifierProvider(
        widget.feedType, 
        initialPosts: widget.initialPosts, 
        initialIndex: widget.initialIndex
      ).notifier).handleParentVisibilityChange(widget.isParentFeedVisible);
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final feedState = ref.watch(feedPageStateNotifierProvider(
      widget.feedType,
      initialPosts: widget.initialPosts,
      initialIndex: widget.initialIndex
    ));
    
    // Optimization: Check if feed posts are available and parent is visible
    // before building the PageView. Reduces build calls when hidden.
    final bool canBuildPageView = feedState.posts.isNotEmpty && 
                                 !feedState.isLoading && 
                                  feedState.errorMessage == null;
    
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          _buildMainContent(context, feedState, canBuildPageView),
          if (widget.showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(FluentIcons.arrow_left_24_regular, color: AppColors.white),
                onPressed: () => context.router.maybePop(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent(BuildContext context, FeedPageState feedState, bool canBuildPageView) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: feedState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedState.errorMessage != null
          ? Center(child: Text('Error: ${feedState.errorMessage}', 
              style: const TextStyle(color: AppColors.white)))
          : feedState.posts.isEmpty
          ? const Center(child: Text('No media available', 
              style: TextStyle(color: AppColors.white)))
          : canBuildPageView
          ? _buildFeedPageView(context, feedState)
          : const SizedBox.shrink(),
    );
  }
  
  Widget _buildFeedPageView(BuildContext context, FeedPageState feedState) {
    // Get feed settings - will need to create a feed settings provider
    final disableBackgroundBlur = false; // Replace with actual setting
    
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: widget.isParentFeedVisible 
          ? const PageScrollPhysics() 
          : const NeverScrollableScrollPhysics(),
      itemCount: feedState.posts.length,
      onPageChanged: (newIndex) {
        ref.read(feedPageStateNotifierProvider(
          widget.feedType,
          initialPosts: widget.initialPosts,
          initialIndex: widget.initialIndex
        ).notifier).updateIndex(newIndex);
      },
      itemBuilder: (context, index) {
        return _buildPostItem(context, feedState.posts[index], index, feedState);
      },
    );
  }
  
  Widget _buildPostItem(BuildContext context, FeedPost post, int index, FeedPageState feedState) {
    // Check if the content should show a warning
    final feedStateNotifier = ref.read(feedPageStateNotifierProvider(
      widget.feedType,
      initialPosts: widget.initialPosts,
      initialIndex: widget.initialIndex
    ).notifier);
    
    final shouldWarn = feedStateNotifier.shouldWarnContent(post);
    
    // Get warning message if needed
    String? warningMessage;
    if (shouldWarn) {
      final warningMessages = feedStateNotifier.getWarningMessages(post);
      if (warningMessages.isNotEmpty) {
        warningMessage = warningMessages.join(", ");
      }
    }
    
    // Check if this item is actually visible
    final isItemActuallyVisible = (index == feedState.currentIndex) && widget.isParentFeedVisible;
    
    // This will need to be implemented with Riverpod
    final disableBackgroundBlur = false; // Replace with actual setting
    
    // Build the appropriate media widget based on the post type
    Widget contentWidget;
    
    if (post.videoUrl != null) {
      final isPreloaded = ref.watch(isVideoPreloadedProvider(index));
      
      if (isPreloaded) {
        contentWidget = PreloadedVideoItem(
          key: ValueKey('video_$index'),
          index: index,
          controller: ref.watch(preloadRepositoryProvider).getPreloadedVideo(index)!.controller,
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
          isLiked: post.likeUri != null,
          isSprk: post.isSprk,
          postUri: post.uri,
          postCid: post.cid,
          disableBackgroundBlur: disableBackgroundBlur,
          videoAlt: post.videoAlt,
          onLikePressed: () => feedStateNotifier.handleLikePress(post),
          onBookmarkPressed: () {},
          onSharePressed: () {},
          onProfilePressed: () {
            // Navigate to profile using AutoRoute
            context.router.pushNamed('/profile/${post.authorDid}');
          },
          onUsernameTap: () {
            // Navigate to profile using AutoRoute
            context.router.pushNamed('/profile/${post.authorDid}');
          },
          onHashtagTap: (String hashtag) {},
          onPostDeleted: () {
            feedStateNotifier.refreshFeed(widget.feedType);
          },
        );
      } else {
        contentWidget = VideoPostItem(
          key: ValueKey('video_$index'),
          index: index,
          videoUrl: post.videoUrl!,
          videoAlt: post.videoAlt,
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
          isLiked: post.likeUri != null,
          isSprk: post.isSprk,
          postUri: post.uri,
          postCid: post.cid,
          disableBackgroundBlur: disableBackgroundBlur,
          onLikePressed: () => feedStateNotifier.handleLikePress(post),
          onBookmarkPressed: () {},
          onSharePressed: () {},
          onProfilePressed: () {
            // Navigate to profile using AutoRoute
            context.router.pushNamed('/profile/${post.authorDid}');
          },
          onUsernameTap: () {
            // Navigate to profile using AutoRoute
            context.router.pushNamed('/profile/${post.authorDid}');
          },
          onHashtagTap: (String hashtag) {},
          onPostDeleted: () {
            feedStateNotifier.refreshFeed(widget.feedType);
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
        isLiked: post.likeUri != null,
        isSprk: post.isSprk,
        postUri: post.uri,
        postCid: post.cid,
        disableBackgroundBlur: disableBackgroundBlur,
        onLikePressed: () => feedStateNotifier.handleLikePress(post),
        onBookmarkPressed: () {},
        onSharePressed: () {},
        onUsernameTap: () {
          // Navigate to profile using AutoRoute
          context.router.pushNamed('/profile/${post.authorDid}');
        },
        onHashtagTap: (String hashtag) {},
      );
    } else {
      contentWidget = const Center(
        child: Text('Unsupported media type', 
          style: TextStyle(color: AppColors.white)));
    }
    
    // If content should show a warning, wrap it in a WarnBuilder
    if (shouldWarn && post.labels.isNotEmpty) {
      // Get the label source and value for the warning
      final labelValue = post.labels.first;
      
      // In a real implementation, get the blur type from label definitions
      final String blurType = 'content'; // Default blur type
      
      return WarnBuilder(
        labelerDid: 'unknown',
        labelValue: labelValue,
        warningMessage: warningMessage,
        blurType: blurType,
        child: contentWidget,
      );
    }
    
    // Otherwise, just return the content widget directly
    return contentWidget;
  }
} 