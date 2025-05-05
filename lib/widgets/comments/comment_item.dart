import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/widgets/common/user_avatar.dart';
import 'package:sparksocial/widgets/dialogs/report_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sparksocial/services/mod_service.dart';
import 'package:sparksocial/services/auth_service.dart';
import 'package:video_player/video_player.dart';
import 'package:sparksocial/services/actions_service.dart';

import '../../models/comment.dart';
import '../../utils/app_colors.dart';
import '../image/image_carousel.dart';
import 'comment_reply_item.dart';
import '../action_buttons/menu_action_button.dart';

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
  final bool isDarkMode;
  final Function(String, String) onReply;
  final List<Comment> replies;
  final String uri;
  final String cid;
  final String? profileImageUrl;
  final String authorDid;
  final bool isLiked;
  final VoidCallback? onLikePressed;
  final VoidCallback? onDeleted;

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
    required this.isDarkMode,
    required this.onReply,
    this.replies = const [],
    required this.uri,
    required this.cid,
    this.profileImageUrl,
    required this.authorDid,
    this.isLiked = false,
    this.onLikePressed,
    this.onDeleted,
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
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = widget.likeCount;
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
    if (oldWidget.isLiked != widget.isLiked) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
    if (oldWidget.likeCount != widget.likeCount) {
      setState(() {
        _likeCount = widget.likeCount;
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
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl!))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    if (widget.onLikePressed != null) {
      widget.onLikePressed!();
    }
  }

  void _toggleReplies() {
    setState(() {
      _showReplies = !_showReplies;
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  void _showImageCarousel() {
    if (widget.imageUrls.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 217),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              ImageCarousel(imageUrls: widget.imageUrls, autoPreload: true, disableBackgroundBlur: false),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(FluentIcons.dismiss_24_filled, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 77)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleReportComment() {
    final modService = ModService(Provider.of<AuthService>(context, listen: false));
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder:
          (context) => ReportDialog(
            postUri: widget.uri,
            postCid: widget.cid,
            onSubmit: (subject, reasonType, reason, service) async {
              try {
                final result = await modService.createReport(
                  subject: subject,
                  reasonType: reasonType,
                  reason: reason,
                  service: service,
                );

                if (result) {
                  scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
                }
              } catch (e) {
                scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
              }
            },
          ),
    );
  }

  void _handleDeleteComment() {
    final actionsService = Provider.of<ActionsService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Confirm deletion
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Comment'),
            content: const Text('Are you sure you want to delete this comment? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    final result = await actionsService.deletePost(widget.uri);
                    if (result && mounted) {
                      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Comment deleted successfully')));
                      widget.onDeleted?.call();
                    }
                  } catch (e) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Failed to delete comment: $e')));
                    }
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final secondaryTextColor = widget.isDarkMode ? AppColors.textLight.withValues(alpha: 179) : AppColors.textSecondary;
    final dividerColor = widget.isDarkMode ? AppColors.deepPurple.withValues(alpha: 128) : AppColors.lightLavender;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildCommentContent(textColor, secondaryTextColor)),
            ],
          ),
        ),

        if (_showReplies && widget.replyCount > 0) _buildRepliesSection(dividerColor),

        Container(height: 0.5, color: dividerColor),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: UserAvatar(imageUrl: widget.profileImageUrl, username: widget.username, size: 36, borderWidth: 0),
    );
  }

  Widget _buildCommentContent(Color textColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(widget.username, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(width: 8),
                  Text(widget.timeAgo, style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                ],
              ),
            ),
            MenuActionButton(
              onPressed: () {
                _handleReportComment();
              },
              onDeletePressed: () {
                _handleDeleteComment();
              },
              isCompact: true,
              backgroundColor: widget.isDarkMode ? Colors.black.withValues(alpha: 51) : Colors.grey.withValues(alpha: 26),
              isProfile: false,
              authorDid: widget.authorDid,
            ),
          ],
        ),
        const SizedBox(height: 4),

        Text(widget.text, style: TextStyle(color: textColor)),

        if (widget.hasMedia) ...[const SizedBox(height: 8), _buildMediaContent()],

        const SizedBox(height: 8),
        _buildActionButtons(secondaryTextColor),
      ],
    );
  }

  Widget _buildActionButtons(Color secondaryTextColor) {
    return Row(
      children: [
        _buildLikeButton(secondaryTextColor),
        const SizedBox(width: 16),

        _buildReplyButton(secondaryTextColor),

        if (widget.replyCount > 0) ...[const SizedBox(width: 16), _buildToggleRepliesButton(secondaryTextColor)],
      ],
    );
  }

  Widget _buildLikeButton(Color secondaryTextColor) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: _toggleLike,
      child: Row(
        children: [
          Icon(
            _isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
            size: 16,
            color: _isLiked ? AppColors.red : secondaryTextColor,
          ),
          const SizedBox(width: 4),
          Text(_likeCount.toString(), style: TextStyle(fontSize: 12, color: secondaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildReplyButton(Color secondaryTextColor) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => widget.onReply(widget.userId, widget.username),
      child: Text('Reply', style: TextStyle(fontSize: 12, color: secondaryTextColor)),
    );
  }

  Widget _buildToggleRepliesButton(Color secondaryTextColor) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: _toggleReplies,
      child: Row(
        children: [
          Icon(
            _showReplies ? FluentIcons.chevron_up_24_regular : FluentIcons.chevron_down_24_regular,
            size: 16,
            color: secondaryTextColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.replyCount} ${widget.replyCount == 1 ? 'reply' : 'replies'}',
            style: TextStyle(fontSize: 12, color: AppColors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesSection(Color dividerColor) {
    return Container(
      margin: const EdgeInsets.only(left: 64),
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: dividerColor, width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          ...widget.replies.map(
            (reply) => CommentReplyItem(
              id: reply.id,
              userId: reply.authorDid,
              username: reply.username,
              text: reply.text,
              timeAgo: reply.createdAt,
              likeCount: reply.likeCount,
              isDarkMode: widget.isDarkMode,
              onReply: widget.onReply,
              profileImageUrl: reply.profileImageUrl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (!widget.hasMedia) {
      return const SizedBox.shrink();
    }

    final borderRadius = BorderRadius.circular(8);
    final bool hasImages = widget.mediaType == 'image' && widget.imageUrls.isNotEmpty;
    final bool hasVideo = widget.mediaType == 'video' && widget.mediaUrl != null;

    if (hasImages) {
      return _buildImageThumbnail(borderRadius);
    } else if (hasVideo) {
      return _buildVideoContent(borderRadius);
    }

    return const SizedBox.shrink();
  }

  Widget _buildImageThumbnail(BorderRadius borderRadius) {
    final imageCount = widget.imageUrls.length;
    const double thumbnailSize = 120.0;
    final firstImageUrl = widget.imageUrls.first;

    return GestureDetector(
      onTap: _showImageCarousel,
      child: Container(
        width: thumbnailSize,
        height: thumbnailSize,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender, width: 0.5),
          color: widget.isDarkMode ? AppColors.deepPurple.withValues(alpha: 50) : AppColors.lightLavender.withValues(alpha: 50),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: firstImageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[850]?.withValues(alpha: 128),
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
                    color: AppColors.darkPurple.withValues(alpha: 26),
                    child: const Center(child: Icon(FluentIcons.image_off_24_regular, size: 24, color: Colors.white70)),
                  ),
            ),

            if (imageCount > 1)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 179), borderRadius: BorderRadius.circular(10)),
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

  Widget _buildVideoContent(BorderRadius borderRadius) {
    return GestureDetector(
      onTap: _toggleVideoPlayback,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender, width: 0.5),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_videoController != null && _isVideoInitialized)
              AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)),

            if (!_isVideoInitialized) const CircularProgressIndicator(color: AppColors.white),

            if (_isVideoInitialized && !_videoController!.value.isPlaying)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 128), shape: BoxShape.circle),
                child: const Icon(FluentIcons.play_24_filled, size: 24, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
