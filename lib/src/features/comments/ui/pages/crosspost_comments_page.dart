import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/ui/widgets/image_content.dart';
import 'package:spark/src/core/ui/widgets/user_avatar.dart';

final crosspostCommentsProvider =
    FutureProvider.family<List<ThreadViewPost>, AtUri>((ref, anchorUri) async {
      final feedRepository = GetIt.instance<SprkRepository>().feed;
      final thread = await feedRepository.getCrosspostThread(anchorUri);

      return switch (thread) {
        ThreadViewPost(:final replies) =>
          replies?.whereType<ThreadViewPost>().toList() ??
              const <ThreadViewPost>[],
        _ => const <ThreadViewPost>[],
      };
    });

@RoutePage()
class CrosspostCommentsPage extends ConsumerWidget {
  const CrosspostCommentsPage({required this.postUri, super.key});

  final String postUri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchorUri = AtUri.parse(postUri);
    final l10n = AppLocalizations.of(context);
    final asyncComments = ref.watch(crosspostCommentsProvider(anchorUri));
    final textColor = Theme.of(context).colorScheme.onSurface;
    final borderColor = Theme.of(context).colorScheme.outline;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => context.router.maybePop(),
                    icon: Icon(
                      FluentIcons.chevron_left_24_regular,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Crosspost comments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: asyncComments.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(child: Text(l10n.emptyNoCrosspostComments));
                }

                return ListView.separated(
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    return _CrosspostCommentTile(
                      comment: comments[index],
                      textColor: textColor,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(l10n.errorWithDetail(error.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrosspostCommentTile extends StatelessWidget {
  const _CrosspostCommentTile({required this.comment, required this.textColor});

  final ThreadViewPost comment;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final author = comment.post.author;
    final imageUrls = comment.post.imageUrls;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imageUrl: author.avatar?.toString() ?? '',
            username: author.handle,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        author.handle,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _formatRelative(comment.post.indexedAt),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (comment.post.displayText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(comment.post.displayText),
                ],
                if (imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ImageContent(
                    imageUrls: imageUrls,
                    borderRadius: BorderRadius.circular(8),
                    thumbnailSize: 120,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelative(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toLocal());

    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()}y';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo';
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'now';
  }
}
