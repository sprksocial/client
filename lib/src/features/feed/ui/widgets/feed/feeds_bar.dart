import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/molecules/create_media_sheet.dart';
import 'package:spark/src/core/design_system/components/molecules/feed_tag_list.dart';
import 'package:spark/src/core/design_system/templates/feeds_bar_template.dart';
import 'package:spark/src/core/media/create_media_actions.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

class FeedsBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const FeedsBar({required this.pageController, super.key});

  final PageController pageController;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<FeedsBar> createState() => _FeedsBarState();
}

class _FeedsBarState extends ConsumerState<FeedsBar> {
  void _showCreateMenu(BuildContext context) {
    showCreateMediaSheet(
      context,
      onRecord: CreateMediaActions.onRecord(context, storyMode: false),
      onUploadVideo: CreateMediaActions.onUploadVideo(
        context,
        storyMode: false,
      ),
      onUploadImages: CreateMediaActions.onUploadImages(
        context,
        storyMode: false,
      ),
    );
  }

  void _showFeedOptionsSheet(BuildContext context, Feed feed) {
    final isTimeline =
        feed.type == 'timeline' && feed.config.value == 'following';
    final isLiked = feed.view?.viewer?.like != null;
    final canDelete = !isTimeline;
    final canLike = feed.view != null; // Only non-timeline feeds can be liked

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Feed name header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    feed.view?.displayName ?? 'Following',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                // Like/Unlike option
                if (canLike)
                  ListTile(
                    leading: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    title: Text(isLiked ? 'Unlike Feed' : 'Like Feed'),
                    onTap: () async {
                      Navigator.pop(context);
                      if (isLiked) {
                        await ref
                            .read(settingsProvider.notifier)
                            .unlikeFeed(feed);
                      } else {
                        await ref
                            .read(settingsProvider.notifier)
                            .likeFeed(feed);
                      }
                    },
                  ),
                // Delete option
                if (canDelete)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Remove Feed',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      // Show confirmation dialog
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove Feed'),
                          content: Text(
                            'Are you sure you want to remove '
                            '"${feed.view?.displayName ?? 'this feed'}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed ?? false) {
                        await ref
                            .read(settingsProvider.notifier)
                            .removeFeed(feed);
                      }
                    },
                  ),
                // Cancel option
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Only show pinned feeds in the home view
    final pinnedFeeds = settings.feeds
        .where((feed) => feed.config.pinned)
        .toList();

    final tags = pinnedFeeds.map((feed) {
      final isTimeline =
          feed.type == 'timeline' && feed.config.value == 'following';
      return FeedTagData(
        id: feed.config.id,
        text: feed.view != null ? feed.view!.displayName : 'Following',
        isTimeline: isTimeline,
        isLiked: feed.view?.viewer?.like != null,
        canDelete: !isTimeline,
      );
    }).toList();

    return FeedsBarTemplate(
      tags: tags,
      selectedTagId: settings.activeFeed.config.id,
      onTagTap: (tagId) {
        final feed = pinnedFeeds.firstWhere(
          (f) => f.config.id == tagId,
        );

        if (settings.activeFeed == feed) {
          ref.read(feedRefreshTriggerProvider(feed).notifier).trigger();
        } else {
          ref.read(settingsProvider.notifier).setActiveFeed(feed);
          final feedIndex = pinnedFeeds.indexOf(feed);
          if (feedIndex != -1 && widget.pageController.hasClients) {
            widget.pageController.jumpToPage(feedIndex);
          }
        }
      },
      onLongPress: (tagData) {
        final feed = pinnedFeeds.firstWhere(
          (f) => f.config.id == tagData.id,
        );
        _showFeedOptionsSheet(context, feed);
      },
      action: SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => _showCreateMenu(context),
          icon: AppIcons.addPostFilled(size: 30),
        ),
      ),
    );
  }
}
