import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/utils/comment_utils.dart';
import 'package:sparksocial/src/features/feed/data/models/image_post_state.dart';
import 'package:sparksocial/src/features/feed/providers/image_post_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';
import 'package:sparksocial/widgets/video_info/video_info_bar.dart';

class ImagePostItem extends ConsumerStatefulWidget {
  final int index;
  final List<String> imageUrls;
  final List<String> imageAlts;
  final String username;
  final String description;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;
  final String? profileImageUrl;
  final String authorDid;
  final bool isLiked;
  final bool isSprk;
  final String postUri;
  final String postCid;
  final bool isVisible;
  final bool disableBackgroundBlur;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUsernameTap;
  final Function(String)? onHashtagTap;
  final VoidCallback? onPostDeleted;

  const ImagePostItem({
    super.key,
    required this.index,
    required this.imageUrls,
    required this.imageAlts,
    required this.username,
    required this.description,
    required this.hashtags,
    required this.likeCount,
    required this.commentCount,
    this.bookmarkCount = 0,
    required this.shareCount,
    this.profileImageUrl,
    required this.authorDid,
    required this.isLiked,
    required this.isSprk,
    required this.postUri,
    required this.postCid,
    this.isVisible = false,
    this.disableBackgroundBlur = false,
    this.onLikePressed,
    this.onCommentPressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    this.onProfilePressed,
    this.onUsernameTap,
    this.onHashtagTap,
    this.onPostDeleted,
  });

  factory ImagePostItem.fromPost({
    required Post post,
    required int index,
    required List<String> imageUrls,
    required List<String> imageAlts,
    required VoidCallback onLikePressed,
    required VoidCallback onBookmarkPressed,
    required VoidCallback onSharePressed,
    required VoidCallback onUsernameTap,
    Function(String)? onHashtagTap,
    VoidCallback? onCommentPressed,
    VoidCallback? onProfilePressed,
    VoidCallback? onPostDeleted,
  }) {
    final username = post.author.handle;
    final description = post.record['text'] as String? ?? '';
    final hashtags = CommentUtils.extractHashtags(description);

    final likeCount = post.record['likeCount'] as int? ?? 0;
    final commentCount = post.record['replyCount'] as int? ?? 0;
    final shareCount = post.record['repostCount'] as int? ?? 0;

    final profileImageUrl = post.author.avatar;
    final authorDid = post.author.did;
    final isLiked = post.viewer['like'] != null;

    // Assume it's a Spark post if it has certain elements (customize as needed)
    final isSprk = post.record['app']?.toString().contains('spark') ?? false;

    return ImagePostItem(
      index: index,
      imageUrls: imageUrls,
      imageAlts: imageAlts,
      username: username,
      description: description,
      hashtags: hashtags,
      likeCount: likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
      profileImageUrl: profileImageUrl,
      authorDid: authorDid,
      isLiked: isLiked,
      isSprk: isSprk,
      postUri: post.uri,
      postCid: post.cid,
      onLikePressed: onLikePressed,
      onCommentPressed: onCommentPressed,
      onBookmarkPressed: onBookmarkPressed,
      onSharePressed: onSharePressed,
      onProfilePressed: onProfilePressed,
      onUsernameTap: onUsernameTap,
      onHashtagTap: onHashtagTap,
      onPostDeleted: onPostDeleted,
    );
  }

  @override
  ConsumerState<ImagePostItem> createState() => _ImagePostItemState();
}

class _ImagePostItemState extends ConsumerState<ImagePostItem> {
  late final _imagePostProvider = imagePostProvider(
    ImagePostState(
      index: widget.index,
      imageUrls: widget.imageUrls,
      imageAlts: widget.imageAlts,
      username: widget.username,
      description: widget.description,
      hashtags: widget.hashtags,
      likeCount: widget.likeCount,
      commentCount: widget.commentCount,
      bookmarkCount: widget.bookmarkCount,
      shareCount: widget.shareCount,
      profileImageUrl: widget.profileImageUrl,
      authorDid: widget.authorDid,
      isLiked: widget.isLiked,
      isSprk: widget.isSprk,
      postUri: widget.postUri,
      postCid: widget.postCid,
      isVisible: widget.isVisible,
      disableBackgroundBlur: widget.disableBackgroundBlur,
    ),
  );

  @override
  void didUpdateWidget(ImagePostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentCount != widget.commentCount) {
      ref.read(_imagePostProvider.notifier).updateCommentCount(widget.commentCount);
    }
    if (oldWidget.isVisible != widget.isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(_imagePostProvider.notifier).setVisible(widget.isVisible);
        }
      });
    }
  }

  void _handleLikePressed() {
    if (widget.onLikePressed != null) {
      widget.onLikePressed!();
      return;
    }

    final notifier = ref.read(_imagePostProvider.notifier);
    notifier.toggleLike();
  }

  void _toggleComments() {
    if (widget.onCommentPressed != null) {
      widget.onCommentPressed!();
      return;
    }

    final notifier = ref.read(_imagePostProvider.notifier);
    notifier.toggleComments();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_imagePostProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(ignoring: true, child: _PostBackground(state: state, theme: Theme.of(context))),
        Center(
          child: _PostContent(
            state: state,
            onPageChanged: (index) {
              ref.read(_imagePostProvider.notifier).updateCarouselIndex(index);
            },
          ),
        ),
        IgnorePointer(ignoring: true, child: _GradientOverlay(isDescriptionExpanded: state.isDescriptionExpanded)),
        _InfoBar(state: state),
        _SideActionBar(
          state: state,
          onLikePressed: _handleLikePressed,
          onCommentPressed: _toggleComments,
          onSharePressed: widget.onSharePressed,
          onProfilePressed: widget.onProfilePressed,
          onPostDeleted: widget.onPostDeleted,
        ),
      ],
    );
  }
}

class _PostBackground extends StatelessWidget {
  final ImagePostState state;
  final ThemeData theme;

  const _PostBackground({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (state.disableBackgroundBlur || state.imageUrls.isEmpty) {
      return Container(color: theme.colorScheme.surface);
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred first image
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
              child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                  opacity: 0.5,
                  child: Image.network(
                    state.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          // Darkened overlay
          Container(color: theme.colorScheme.surface.withAlpha(120)),
        ],
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final ImagePostState state;
  final Function(int) onPageChanged;

  const _PostContent({required this.state, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return ImageCarousel(
      imageUrls: state.imageUrls,
      imageAlts: state.imageAlts,
      disableBackgroundBlur: state.disableBackgroundBlur,
      onPageChanged: onPageChanged,
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  final bool isDescriptionExpanded;

  const _GradientOverlay({required this.isDescriptionExpanded});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withAlpha(isDescriptionExpanded ? 30 : 10),
            Colors.black.withAlpha(isDescriptionExpanded ? 80 : 40),
            Colors.black.withAlpha(isDescriptionExpanded ? 150 : 80),
            Colors.black.withAlpha(isDescriptionExpanded ? 200 : 160),
          ],
          stops: isDescriptionExpanded ? const [0.0, 0.4, 0.5, 0.6, 0.75, 0.9] : const [0.0, 0.5, 0.65, 0.75, 0.85, 0.95],
        ),
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  final ImagePostState state;

  const _InfoBar({required this.state});

  @override
  Widget build(BuildContext context) {
    String? alt;

    if (state.imageUrls.length > 1) {
      final candidate = state.imageAlts.length > state.currentCarouselIndex ? state.imageAlts[state.currentCarouselIndex] : null;
      if (candidate?.trim().isNotEmpty ?? false) alt = candidate;
    } else {
      final candidate = state.imageAlts.isNotEmpty ? state.imageAlts.first : null;
      if (candidate?.trim().isNotEmpty ?? false) alt = candidate;
    }

    return Positioned(
      bottom: 20,
      left: 10,
      right: 65,
      child: VideoInfoBar(
        username: state.username,
        description: state.description,
        hashtags: state.hashtags,
        isSprk: state.isSprk,
        altText: alt,
      ),
    );
  }
}

class _SideActionBar extends StatelessWidget {
  final ImagePostState state;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onPostDeleted;

  const _SideActionBar({
    required this.state,
    required this.onLikePressed,
    required this.onCommentPressed,
    this.onSharePressed,
    this.onProfilePressed,
    this.onPostDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: SideActionBar(
        likeCount: '${state.likeCount}',
        commentCount: '${state.commentCount}',
        shareCount: '${state.shareCount}',
        profileImageUrl: state.profileImageUrl,
        isLiked: state.isLiked,
        onLikePressed: onLikePressed,
        onCommentPressed: onCommentPressed,
        onSharePressed: onSharePressed ?? () {},
        onProfilePressed: onProfilePressed ?? () {},
        postCid: state.postCid,
        postUri: state.postUri,
        authorDid: state.authorDid,
        onPostDeleted: onPostDeleted ?? () {},
        isImage: true,
      ),
    );
  }
}
