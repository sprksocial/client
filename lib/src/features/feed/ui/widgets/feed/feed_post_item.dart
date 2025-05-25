import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/feed/data/models/feed_page_state.dart';
import 'package:sparksocial/src/features/feed/providers/feed_page_provider.dart';
import 'package:sparksocial/src/features/feed/providers/preload_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/preloaded_video_item.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_post_item.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_post_item.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/common/warn_builder.dart';
import 'package:sparksocial/src/features/settings/providers/labeler_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedPostItem extends StatelessWidget {
  final FeedPost post;
  final int index;
  final FeedPageState feedState;
  final bool isParentFeedVisible;
  final int feedType;
  final List<FeedPost>? initialPosts;
  final int? initialIndex;
  final WidgetRef ref;

  // Get a logger for the FeedPostItem widget
  static final _logger = GetIt.instance<LogService>().getLogger('FeedPostItem');

  const FeedPostItem({
    super.key,
    required this.post,
    required this.index,
    required this.feedState,
    required this.isParentFeedVisible,
    required this.feedType,
    this.initialPosts,
    this.initialIndex,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    // Get the feed state notifier for actions like liking posts
    final feedStateNotifier = ref.read(
      feedPageStateNotifierProvider(feedType, initialPosts: initialPosts, initialIndex: initialIndex).notifier,
    );

    // Check if this item is actually visible
    final isItemActuallyVisible = (index == feedState.currentIndex) && isParentFeedVisible;

    // Get the background blur setting from settings
    final disableBackgroundBlur = !ref.watch(settingsProvider).feedBlurEnabled;

    // Common navigation actions used in multiple places
    navigateToProfile() => context.router.push(ProfileRoute(did: post.authorDid));
    onPostDeleted() => feedStateNotifier.refreshFeed(feedType);

    // Build the appropriate media widget based on the post type using pattern matching
    final contentWidget = switch (post) {
      // Video post with preloaded video
      FeedPost(videoUrl: String? url, :String authorDid) when url != null && ref.watch(isVideoPreloadedProvider(index)) =>
        PreloadedVideoItem(
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
          authorDid: authorDid,
          isLiked: post.likeUri != null,
          isSprk: post.isSprk,
          postUri: post.uri,
          postCid: post.cid,
          disableBackgroundBlur: disableBackgroundBlur,
          videoAlt: post.videoAlt,
          onLikePressed: () => feedStateNotifier.handleLikePress(post),
          onBookmarkPressed: () {},
          onSharePressed: () {},
          onProfilePressed: navigateToProfile,
          onUsernameTap: navigateToProfile,
          onHashtagTap: (String hashtag) {},
          onPostDeleted: onPostDeleted,
        ),

      // Video post without preloaded video
      FeedPost(videoUrl: String? url, :String authorDid) when url != null => VideoPostItem(
        key: ValueKey('video_$index'),
        index: index,
        videoUrl: url,
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
        authorDid: authorDid,
        isLiked: post.likeUri != null,
        isSprk: post.isSprk,
        postUri: post.uri,
        postCid: post.cid,
        disableBackgroundBlur: disableBackgroundBlur,
        onLikePressed: () => feedStateNotifier.handleLikePress(post),
        onBookmarkPressed: () {},
        onSharePressed: () {},
        onProfilePressed: navigateToProfile,
        onUsernameTap: navigateToProfile,
        onHashtagTap: (String hashtag) {},
        onPostDeleted: onPostDeleted,
        onCommentPressed: () {},
      ),

      // Image post
      FeedPost(imageUrls: List<String> urls, :String authorDid) when urls.isNotEmpty => ImagePostItem(
        key: ValueKey('image_$index'),
        index: index,
        imageUrls: urls,
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
        authorDid: authorDid,
        isLiked: post.likeUri != null,
        isSprk: post.isSprk,
        postUri: post.uri,
        postCid: post.cid,
        disableBackgroundBlur: disableBackgroundBlur,
        onLikePressed: () => feedStateNotifier.handleLikePress(post),
        onBookmarkPressed: () {},
        onSharePressed: () {},
        onUsernameTap: navigateToProfile,
        onHashtagTap: (String hashtag) {},
      ),

      // Fallback for unsupported media type
      _ => const Center(child: Text('Unsupported media type', style: TextStyle(color: AppColors.white))),
    };

    final shouldWarnAsync = ref.watch(shouldWarnContentProvider(post.labels));

    // Pattern matching for async state handling
    switch (shouldWarnAsync) {
      case AsyncLoading():
        return contentWidget;
      case AsyncError(:final error):
        _logger.e('Error checking content warning', error: error);
        return contentWidget;
      case AsyncData(value: false) || AsyncData() when post.labels.isEmpty:
        return contentWidget;
      case AsyncData():
        break; // Continue with warning logic
    }

    // Warning messages
    final warningMessagesAsync = ref.watch(warningMessagesProvider(post.labels));

    final String warningMessage = switch (warningMessagesAsync) {
      AsyncData(value: List<String>? messages) when messages.isNotEmpty => messages.join(", "),
      _ => 'This content may require a content warning',
    };

    // Labeler handling
    final followedLabelersAsync = ref.watch(followedLabelersProvider);

    final String labelerDid = switch (followedLabelersAsync) {
      AsyncData(value: List<String>? labelers) when labelers.isNotEmpty => labelers.first,
      _ => ref.read(defaultLabelerDidProvider),
    };

    final labelValue = post.labels.isNotEmpty ? post.labels.first : '!warn';

    // Blur type determination
    String blurType = 'content';

    final labelerDetailsAsync = ref.watch(labelerDetailsProvider(labelerDid));
    if (labelerDetailsAsync case AsyncData(value: var details) when details.labelDefinitions[labelValue] != null) {
      blurType = details.labelDefinitions[labelValue]!.blurs;
    }

    return WarnBuilder(
      labelerDid: labelerDid,
      labelValue: labelValue,
      warningMessage: warningMessage,
      blurType: blurType,
      child: contentWidget,
    );
  }
}
