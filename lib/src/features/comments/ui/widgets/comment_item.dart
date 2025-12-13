import 'package:atproto/com_atproto_moderation_createreport.dart';
import 'package:atproto/com_atproto_moderation_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:sparksocial/src/core/ui/widgets/image_content.dart';
import 'package:sparksocial/src/core/ui/widgets/menu_action_button.dart';
import 'package:sparksocial/src/core/ui/widgets/report_dialog.dart';
import 'package:sparksocial/src/core/ui/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/comments/providers/comment_provider.dart';
import 'package:sparksocial/src/features/comments/providers/comment_state.dart';
import 'package:sparksocial/src/features/comments/providers/comments_page_provider.dart';

class CommentItem extends ConsumerStatefulWidget {
  const CommentItem({required this.thread, required this.mainPostUri, super.key});
  final ThreadViewPost thread;
  final AtUri mainPostUri;

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
              input: ModerationCreateReportInput(subject: subject, reasonType: reasonType as ReasonType, reason: reason),
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
    commentState = ref.watch(commentProvider(widget.thread));
    const double thumbnailSize = 120;

    final borderRadius = BorderRadius.circular(8);

    // Comments only support a single image (EmbedViewMediaImage)
    // The adapter transforms Bluesky comments to this format
    final hasImages = commentState.thread.post.media is MediaViewImage;

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
                          onPressed: _handleReportComment,
                          onDeletePressed: _handleDeleteComment,
                          isCompact: true,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          authorDid: commentState.thread.post.author.did,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    if (commentState.thread.post.displayText.isNotEmpty)
                      Text(commentState.thread.post.displayText, style: Theme.of(context).textTheme.bodyMedium),

                    if (commentState.thread.post.media != null && hasImages) ...[
                      const SizedBox(height: 8),
                      ImageContent(
                        imageUrls: commentState.thread.post.imageUrls,
                        borderRadius: borderRadius,
                        thumbnailSize: thumbnailSize,
                      ),
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
          border: Border(left: BorderSide(color: Theme.of(context).colorScheme.surface)),
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
    final notifier = ref.read(commentProvider(commentState.thread).notifier);
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.widget});

  final CommentItem widget;

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      imageUrl: widget.thread.post.author.avatar.toString(),
      username: widget.thread.post.author.handle,
      size: 36,
    );
  }
}
