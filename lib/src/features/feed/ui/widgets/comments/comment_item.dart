import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/comments/like_button.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/comments/comment_reply_item.dart';
import 'package:sparksocial/widgets/common/user_avatar.dart';
import 'package:video_player/video_player.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

class CommentItem extends StatefulWidget {
  final String id;
  final String userId;
  final String username;
  final String text;
  final String timeAgo;
  final int likeCount;
  final bool hasMedia;
  final String? mediaType;
  final String? mediaUrl;
  final List<String> imageUrls;
  final int replyCount;
  final Function(String, String) onReply;
  final List<Comment> replies;
  final String uri;
  final String cid;
  final String? profileImageUrl;
  final String authorDid;
  final bool isLiked;
  final VoidCallback? onLikePressed;
  final VoidCallback? onDeleted;
  final Function() onReportPressed;
  final Function() onDeletePressed;

  const CommentItem({
    super.key,
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.timeAgo,
    required this.likeCount,
    required this.hasMedia,
    this.mediaType,
    this.mediaUrl,
    this.imageUrls = const [],
    required this.replyCount,
    required this.onReply,
    this.replies = const [],
    required this.uri,
    required this.cid,
    this.profileImageUrl,
    required this.authorDid,
    this.isLiked = false,
    this.onLikePressed,
    this.onDeleted,
    required this.onReportPressed,
    required this.onDeletePressed,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isLiked = false;
  bool _showReplies = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isFirstImagePrecached = false;
  bool _isLikeLoading = false;
  final _logger = GetIt.instance<LogService>().getLogger('CommentItem');

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;

    if (widget.hasMedia && widget.mediaType == 'video' && widget.mediaUrl != null) {
      _initializeVideoPlayer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.imageUrls.isNotEmpty && !_isFirstImagePrecached) {
      _preloadFirstImage();
      _isFirstImagePrecached = true;
    }
  }

  @override
  void didUpdateWidget(CommentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isLikeLoading && oldWidget.isLiked != widget.isLiked) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _preloadFirstImage() {
    if (!mounted || widget.imageUrls.isEmpty) return;
    precacheImage(CachedNetworkImageProvider(widget.imageUrls.first), context);
    _logger.d('Precached first image for comment: ${widget.id}');
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl!))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _logger.d('Video initialized for comment: ${widget.id}');
        }
      });
  }

  void _toggleLike() {
    if (_isLikeLoading) return;

    _logger.d('Like toggled for comment: ${widget.id}');

    setState(() {
      _isLikeLoading = true;
      _isLiked = !_isLiked;
    });

    if (widget.onLikePressed != null) {
      widget.onLikePressed!();
    }

    // Reset loading state after a short delay to ensure smooth animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    });
  }

  void _toggleReplies() {
    _logger.d('Replies toggled for comment: ${widget.id}, showing: $_showReplies');
    setState(() {
      _showReplies = !_showReplies;
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _logger.d('Video paused for comment: ${widget.id}');
        } else {
          _videoController!.play();
          _logger.d('Video playing for comment: ${widget.id}');
        }
      });
    }
  }

  void _showImageCarousel() {
    if (widget.imageUrls.isEmpty) return;
    _logger.d('Showing image carousel for comment: ${widget.id}');

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(217),
      builder: (BuildContext context) {
        return _ImageCarouselDialog(imageUrls: widget.imageUrls);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurface.withAlpha(179);
    final dividerColor = colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(imageUrl: widget.profileImageUrl, username: widget.username, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: _CommentContent(
                  username: widget.username,
                  timeAgo: widget.timeAgo,
                  text: widget.text,
                  hasMedia: widget.hasMedia,
                  mediaType: widget.mediaType,
                  imageUrls: widget.imageUrls,
                  videoController: _videoController,
                  isVideoInitialized: _isVideoInitialized,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  isLiked: _isLiked,
                  isLikeLoading: _isLikeLoading,
                  replyCount: widget.replyCount,
                  showReplies: _showReplies,
                  likeCount: widget.likeCount,
                  onLikePressed: _toggleLike,
                  onReplyPressed: () => widget.onReply(widget.userId, widget.username),
                  onToggleReplies: _toggleReplies,
                  onShowImageCarousel: _showImageCarousel,
                  onToggleVideoPlayback: _toggleVideoPlayback,
                  onReportPressed: widget.onReportPressed,
                  onDeletePressed: widget.onDeletePressed,
                  authorDid: widget.authorDid,
                ),
              ),
            ],
          ),
        ),

        if (_showReplies && widget.replyCount > 0)
          _RepliesSection(
            replies: widget.replies,
            dividerColor: dividerColor,
            onReply: widget.onReply,
          ),

        Container(height: 0.5, color: dividerColor),
      ],
    );
  }
}

class _CommentContent extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String text;
  final bool hasMedia;
  final String? mediaType;
  final List<String> imageUrls;
  final VideoPlayerController? videoController;
  final bool isVideoInitialized;
  final Color textColor;
  final Color secondaryTextColor;
  final bool isLiked;
  final bool isLikeLoading;
  final int likeCount;
  final int replyCount;
  final bool showReplies;
  final VoidCallback onLikePressed;
  final VoidCallback onReplyPressed;
  final VoidCallback onToggleReplies;
  final VoidCallback onShowImageCarousel;
  final VoidCallback onToggleVideoPlayback;
  final VoidCallback onReportPressed;
  final VoidCallback onDeletePressed;
  final String authorDid;

  const _CommentContent({
    required this.username,
    required this.timeAgo,
    required this.text,
    required this.hasMedia,
    required this.mediaType,
    required this.imageUrls,
    required this.videoController,
    required this.isVideoInitialized,
    required this.textColor,
    required this.secondaryTextColor,
    required this.isLiked,
    required this.isLikeLoading,
    required this.likeCount,
    required this.replyCount,
    required this.showReplies,
    required this.onLikePressed,
    required this.onReplyPressed,
    required this.onToggleReplies,
    required this.onShowImageCarousel,
    required this.onToggleVideoPlayback,
    required this.onReportPressed,
    required this.onDeletePressed,
    required this.authorDid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(username, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(width: 8),
                  Text(timeAgo, style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                ],
              ),
            ),
            _CommentMenuButton(onReportPressed: onReportPressed, onDeletePressed: onDeletePressed),
          ],
        ),
        const SizedBox(height: 4),

        Text(text, style: TextStyle(color: textColor)),

        if (hasMedia) ...[
          const SizedBox(height: 8),
          _MediaContent(
            hasMedia: hasMedia,
            mediaType: mediaType,
            imageUrls: imageUrls,
            videoController: videoController,
            isVideoInitialized: isVideoInitialized,
            onShowImageCarousel: onShowImageCarousel,
            onToggleVideoPlayback: onToggleVideoPlayback,
          ),
        ],

        const SizedBox(height: 8),
        _ActionButtons(
          isLiked: isLiked,
          isLikeLoading: isLikeLoading,
          likeCount: likeCount,
          onLikePressed: onLikePressed,
          onReplyPressed: onReplyPressed,
          replyCount: replyCount,
          showReplies: showReplies,
          onToggleReplies: onToggleReplies,
          secondaryTextColor: secondaryTextColor,
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isLiked;
  final bool isLikeLoading;
  final int likeCount;
  final VoidCallback onLikePressed;
  final VoidCallback onReplyPressed;
  final int replyCount;
  final bool showReplies;
  final VoidCallback onToggleReplies;
  final Color secondaryTextColor;

  const _ActionButtons({
    required this.isLiked,
    required this.isLikeLoading,
    required this.likeCount,
    required this.onLikePressed,
    required this.onReplyPressed,
    required this.replyCount,
    required this.showReplies,
    required this.onToggleReplies,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LikeButton(
          isLiked: isLiked,
          isLoading: isLikeLoading,
          likeCount: likeCount,
          onPressed: onLikePressed,
          textColor: secondaryTextColor,
        ),
        const SizedBox(width: 16),

        _ReplyButton(onPressed: onReplyPressed, textColor: secondaryTextColor),

        if (replyCount > 0) ...[
          const SizedBox(width: 16),
          _ToggleRepliesButton(
            replyCount: replyCount,
            showReplies: showReplies,
            onPressed: onToggleReplies,
            textColor: secondaryTextColor,
          ),
        ],
      ],
    );
  }
}

class _MediaContent extends StatelessWidget {
  final bool hasMedia;
  final String? mediaType;
  final List<String> imageUrls;
  final VideoPlayerController? videoController;
  final bool isVideoInitialized;
  final VoidCallback onShowImageCarousel;
  final VoidCallback onToggleVideoPlayback;

  const _MediaContent({
    required this.hasMedia,
    required this.mediaType,
    required this.imageUrls,
    required this.videoController,
    required this.isVideoInitialized,
    required this.onShowImageCarousel,
    required this.onToggleVideoPlayback,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMedia) {
      return const SizedBox.shrink();
    }

    final borderRadius = BorderRadius.circular(8);
    final bool hasImages = mediaType == 'image' && imageUrls.isNotEmpty;
    final bool hasVideo = mediaType == 'video' && videoController != null;

    if (hasImages) {
      return _ImageThumbnail(
        imageUrl: imageUrls.first,
        imageCount: imageUrls.length,
        onTap: onShowImageCarousel,
        borderRadius: borderRadius,
      );
    } else if (hasVideo) {
      return _VideoThumbnail(
        videoController: videoController!,
        isInitialized: isVideoInitialized,
        onTap: onToggleVideoPlayback,
        borderRadius: borderRadius,
      );
    }

    return const SizedBox.shrink();
  }
}

class _CommentMenuButton extends StatelessWidget {
  final VoidCallback onReportPressed;
  final VoidCallback onDeletePressed;

  const _CommentMenuButton({required this.onReportPressed, required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surfaceContainerLow.withAlpha(51);

    return IconButton(
      icon: const Icon(FluentIcons.more_horizontal_24_regular, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(backgroundColor: backgroundColor, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder:
              (context) => Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(FluentIcons.flag_24_regular),
                        title: const Text('Report Comment'),
                        onTap: () {
                          context.router.maybePop();
                          onReportPressed();
                        },
                      ),
                      ListTile(
                        leading: const Icon(FluentIcons.delete_24_regular, color: AppColors.red),
                        title: const Text('Delete Comment', style: TextStyle(color: AppColors.red)),
                        onTap: () {
                          context.router.maybePop();
                          onDeletePressed();
                        },
                      ),
                      ListTile(
                        leading: const Icon(FluentIcons.dismiss_24_regular),
                        title: const Text('Cancel'),
                        onTap: () => context.router.maybePop(),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }
}

class _ReplyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color textColor;

  const _ReplyButton({required this.onPressed, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text('Reply', style: TextStyle(fontSize: 12, color: textColor)),
    );
  }
}

class _ToggleRepliesButton extends StatelessWidget {
  final int replyCount;
  final bool showReplies;
  final VoidCallback onPressed;
  final Color textColor;

  const _ToggleRepliesButton({
    required this.replyCount,
    required this.showReplies,
    required this.onPressed,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(showReplies ? FluentIcons.chevron_up_24_regular : FluentIcons.chevron_down_24_regular, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text('$replyCount ${replyCount == 1 ? 'reply' : 'replies'}', style: TextStyle(fontSize: 12, color: AppColors.blue)),
        ],
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String imageUrl;
  final int imageCount;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _ImageThumbnail({
    required this.imageUrl,
    required this.imageCount,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: colorScheme.primary, width: 0.5),
          color: colorScheme.primary.withAlpha(50),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[850]?.withAlpha(128),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: AppColors.darkPurple.withAlpha(26),
                    child: const Center(child: Icon(FluentIcons.image_off_24_regular, size: 24, color: Colors.white70)),
                  ),
            ),

            if (imageCount > 1)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withAlpha(179), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    '+${imageCount - 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final VideoPlayerController videoController;
  final bool isInitialized;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _VideoThumbnail({
    required this.videoController,
    required this.isInitialized,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: colorScheme.primary, width: 0.5),
          color: colorScheme.primary.withAlpha(50),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isInitialized) AspectRatio(aspectRatio: videoController.value.aspectRatio, child: VideoPlayer(videoController)),

            if (!isInitialized) const CircularProgressIndicator(color: AppColors.white),

            if (isInitialized && !videoController.value.isPlaying)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Colors.black.withAlpha(128), shape: BoxShape.circle),
                child: const Icon(FluentIcons.play_24_filled, size: 24, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class _RepliesSection extends StatelessWidget {
  final List<Comment> replies;
  final Color dividerColor;
  final Function(String, String) onReply;

  const _RepliesSection({required this.replies, required this.dividerColor, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 64),
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: dividerColor, width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          ...replies.map(
            (reply) => CommentReplyItem(
              id: reply.id,
              userId: reply.authorDid,
              username: reply.username,
              text: reply.text,
              timeAgo: reply.createdAt,
              likeCount: reply.likeCount,
              onReply: onReply,
              profileImageUrl: reply.profileImageUrl,
              isLiked: Comment.isLiked(reply),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarouselDialog extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageCarouselDialog({required this.imageUrls});

  @override
  State<_ImageCarouselDialog> createState() => _ImageCarouselDialogState();
}

class _ImageCarouselDialogState extends State<_ImageCarouselDialog> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => context.router.maybePop(),
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: InteractiveViewer(
                      maxScale: 5.0,
                      minScale: 0.5,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.white)),
                        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: AppColors.white)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(FluentIcons.dismiss_24_filled, color: AppColors.white, size: 30),
              onPressed: () => context.router.maybePop(),
              style: IconButton.styleFrom(backgroundColor: AppColors.black.withAlpha(77)),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex ? AppColors.white : AppColors.white.withAlpha(128),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
