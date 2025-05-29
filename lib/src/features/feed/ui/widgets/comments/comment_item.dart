import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/menu_action_button.dart';
import 'package:sparksocial/src/core/widgets/report_dialog.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/feed/providers/comment_state.dart';
import 'package:sparksocial/src/features/feed/providers/comment_provider.dart';
import 'package:sparksocial/src/features/feed/providers/comments_tray_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:video_player/video_player.dart';


class CommentItem extends ConsumerStatefulWidget {
  final PostView comment;
  final String parentPostUri;
  final String parentPostCid;
  const CommentItem({super.key, required this.comment, required this.parentPostUri, required this.parentPostCid});

  @override
  ConsumerState<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<CommentItem> {
  late CommentState commentState;

  @override
  void initState() {
    super.initState();
  }

  void _showImageCarousel() {
    if (!commentState.comment.hasMedia) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 217),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              ImageCarousel(imageUrls: commentState.comment.imageUrls, autoPreload: true, disableBackgroundBlur: false),
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final sprkRepository = GetIt.instance<SprkRepository>();
    showDialog(
      context: context,
      builder:
          (context) => ReportDialog(
            postUri: commentState.comment.uri,
            postCid: commentState.comment.cid,
            onSubmit: (subject, reasonType, reason, service) async {
              try {
                final result = await sprkRepository.repo.createReport(
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Confirm deletion
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Comment'),
            content: const Text('Are you sure you want to delete this comment? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => context.router.maybePop(), child: const Text('Cancel')),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  try {
                    ref
                        .read(
                          CommentsTrayProvider(
                            postUri: widget.parentPostUri,
                            postCid: widget.parentPostCid,
                            isSprk: commentState.comment.isSprk,
                          ).notifier,
                        )
                        .deleteComment(widget.comment.cid.toString());
                    context.router.maybePop();
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
    commentState = ref.watch(CommentNotifierProvider(widget.comment));
    final imageCount = commentState.comment.imageUrls.length;
    const double thumbnailSize = 120.0;

    final borderRadius = BorderRadius.circular(8);
    final bool hasImages = commentState.comment.mediaType == 'image' && commentState.comment.imageUrls.isNotEmpty;
    final bool hasVideo = commentState.comment.mediaType == 'video' && commentState.comment.mediaUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(widget: widget),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                commentState.comment.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                commentState.comment.createdAt,
                                style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                              ),
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
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          isProfile: false,
                          authorDid: commentState.comment.authorDid,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(commentState.comment.text, style: Theme.of(context).textTheme.bodyMedium),

                    if (commentState.comment.hasMedia) ...[
                      const SizedBox(height: 8),
                      if (hasImages)
                        GestureDetector(
                          onTap: _showImageCarousel,
                          child: Container(
                            width: thumbnailSize,
                            height: thumbnailSize,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 0.5),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: commentState.comment.imageUrls.first,
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
                                        child: const Center(
                                          child: Icon(FluentIcons.image_off_24_regular, size: 24, color: Colors.white70),
                                        ),
                                      ),
                                ),

                                if (imageCount > 1)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 179),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '+${imageCount - 1}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      else if (hasVideo)
                        _VideoContent(ref: ref, commentState: commentState, context: context, borderRadius: borderRadius),
                    ],

                    const SizedBox(height: 8),
                    _ActionButtons(
                      ref: ref,
                      commentState: commentState,
                      widget: widget,
                      secondaryTextColor: Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (commentState.showReplies && commentState.comment.replyCount > 0)
          _RepliesSection(
            commentState: commentState,
            context: context,
            widget: widget,
            dividerColor: Theme.of(context).colorScheme.surface,
          ),

        Container(height: 0.5, color: Theme.of(context).colorScheme.surface),
      ],
    );
  }
}

class _RepliesSection extends StatelessWidget {
  const _RepliesSection({required this.commentState, required this.context, required this.widget, required this.dividerColor});

  final CommentState commentState;
  final BuildContext context;
  final CommentItem widget;
  final Color dividerColor;

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
          ...commentState.comment.replies.map(
            // TODO: reddit
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.ref, required this.commentState, required this.widget, required this.secondaryTextColor});

  final WidgetRef ref;
  final CommentState commentState;
  final CommentItem widget;
  final Color secondaryTextColor;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(CommentNotifierProvider(commentState.comment).notifier);
    final trayNotifier = ref.read(
      CommentsTrayProvider(
        postUri: widget.parentPostUri,
        postCid: widget.parentPostCid,
        isSprk: commentState.comment.isSprk,
      ).notifier,
    );
    return Row(
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: notifier.toggleLike,
          child: Row(
            children: [
              Icon(
                (!commentState.isLiked) ? FluentIcons.heart_24_regular : FluentIcons.heart_24_filled,
                size: 16,
                color: commentState.isLiked ? AppColors.red : secondaryTextColor,
              ),
              const SizedBox(width: 4),
              Text(commentState.comment.likeCount.toString(), style: TextStyle(fontSize: 12, color: secondaryTextColor)),
            ],
          ),
        ),
        const SizedBox(width: 16),

        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => trayNotifier.replyToComment(commentState.comment.authorDid, commentState.comment.username),
          child: Text('Reply', style: TextStyle(fontSize: 12, color: secondaryTextColor)),
        ),

        if (commentState.comment.replyCount > 0) ...[
          const SizedBox(width: 16),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: notifier.toggleReplies,
            child: Row(
              children: [
                Icon(
                  commentState.showReplies ? FluentIcons.chevron_up_24_regular : FluentIcons.chevron_down_24_regular,
                  size: 16,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${commentState.comment.replyCount} ${commentState.comment.replyCount == 1 ? 'reply' : 'replies'}',
                  style: TextStyle(fontSize: 12, color: AppColors.blue),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _VideoContent extends StatelessWidget {
  const _VideoContent({required this.ref, required this.commentState, required this.context, required this.borderRadius});

  final WidgetRef ref;
  final CommentState commentState;
  final BuildContext context;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(CommentNotifierProvider(commentState.comment).notifier);
    return GestureDetector(
      onTap: notifier.toggleVideoPlayback,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 0.5),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (commentState.videoController != null && commentState.isVideoInitialized)
              AspectRatio(
                aspectRatio: commentState.videoController!.value.aspectRatio,
                child: VideoPlayer(commentState.videoController!),
              ),

            if (!commentState.isVideoInitialized) const CircularProgressIndicator(color: AppColors.white),

            if (commentState.isVideoInitialized && !commentState.videoController!.value.isPlaying)
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.widget});

  final CommentItem widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: UserAvatar(imageUrl: widget.comment.author.avatar.toString(), username: widget.comment.author.handle, size: 36, borderWidth: 0),
    );
  }
}
