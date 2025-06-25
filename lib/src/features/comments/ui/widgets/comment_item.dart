import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/menu_action_button.dart';
import 'package:sparksocial/src/core/widgets/report_dialog.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/comments/providers/comment_provider.dart';
import 'package:sparksocial/src/features/comments/providers/comment_state.dart';
import 'package:sparksocial/src/features/comments/providers/comments_page_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:video_player/video_player.dart';

class CommentItem extends ConsumerStatefulWidget {
  final ThreadViewPost thread;
  final AtUri mainPostUri;
  const CommentItem({super.key, required this.thread, required this.mainPostUri});

  @override
  ConsumerState<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<CommentItem> {
  late CommentState commentState;

  @override
  void initState() {
    super.initState();
  }

  void _navigateToProfile() {
    context.router.push(ProfileRoute(did: commentState.thread.post.author.did));
  }

  void _showImageCarousel() {
    if (commentState.thread.post.embed == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 217),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              ImageCarousel(
                imageUrls: commentState.thread.post.imageUrls,
                alts: (commentState.thread.post.embed as EmbedViewImage).images.map((e) => e.alt ?? '').toList(),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(FluentIcons.dismiss_24_filled, color: Colors.white, size: 30),
                  onPressed: () => context.router.maybePop(),
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
      builder: (context) => ReportDialog(
        postUri: commentState.thread.post.uri.toString(),
        postCid: commentState.thread.post.cid,
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => context.router.maybePop(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref
                    .read(commentsPageProvider(postUri: widget.mainPostUri).notifier)
                    .deleteComment(commentState.thread.post.uri.toString());
                if (context.mounted) {
                  await context.router.maybePop(); // to close the menu below
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
    commentState = ref.watch(commentNotifierProvider(widget.thread));
    final imageCount = commentState.thread.post.imageUrls.length;
    const double thumbnailSize = 120.0;

    final borderRadius = BorderRadius.circular(8);
    final bool hasImages = commentState.thread.post.embed is EmbedViewImage;
    final bool hasVideo = commentState.thread.post.embed is EmbedViewVideo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _navigateToProfile,
                child: _Avatar(widget: widget),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _navigateToProfile,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  commentState.thread.post.author.handle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDate(commentState.thread.post.indexedAt.toLocal().toString()),
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                                ),
                              ],
                            ),
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
                          authorDid: commentState.thread.post.author.did,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(commentState.thread.post.record.text ?? '', style: Theme.of(context).textTheme.bodyMedium),

                    if (commentState.thread.post.embed != null) ...[
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
                                  imageUrl: commentState.thread.post.imageUrls.first,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[850]?.withValues(alpha: 128),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
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

        if (commentState.thread.post.replyCount != null && commentState.thread.post.replyCount! > 0)
          _RepliesSection(commentState),

        Container(height: 0.5, color: Theme.of(context).colorScheme.surface),
      ],
    );
  }

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class _RepliesSection extends StatelessWidget {
  const _RepliesSection(this.commentState);
  final CommentState commentState;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(RepliesRoute(postUri: commentState.thread.post.uri.toString())),
      child: Container(
        margin: const EdgeInsets.only(left: 64),
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Theme.of(context).colorScheme.surface, width: 1)),
        ),
        child: Text('Show ${commentState.thread.post.replyCount} replies'),
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
    final notifier = ref.read(commentNotifierProvider(commentState.thread).notifier);
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
              Text(commentState.likeCount.toString(), style: TextStyle(fontSize: 12, color: secondaryTextColor)),
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
          onPressed: () {
            context.router.push(RepliesRoute(postUri: commentState.thread.post.uri.toString()));
          },
          child: Text('Reply', style: TextStyle(fontSize: 12, color: secondaryTextColor)),
        ),
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
    final notifier = ref.read(CommentNotifierProvider(commentState.thread).notifier);
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
    return UserAvatar(
      imageUrl: widget.thread.post.author.avatar.toString(),
      username: widget.thread.post.author.handle,
      size: 36,
      borderWidth: 0,
    );
  }
}
