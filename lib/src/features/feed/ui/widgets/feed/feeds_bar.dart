import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/design_system/components/molecules/feed_tag_list.dart';
import 'package:spark/src/core/design_system/templates/feeds_bar_template.dart';
import 'package:spark/src/features/posting/utils/create_media_actions.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:spark/src/features/feed/providers/visible_pinned_feeds_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

export 'package:spark/src/core/design_system/templates/feeds_bar_template.dart'
    show kFeedsBarHeight;

class FeedsBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const FeedsBar({required this.pageController, super.key});

  final PageController pageController;

  @override
  Size get preferredSize => const Size.fromHeight(kFeedsBarHeight);

  @override
  ConsumerState<FeedsBar> createState() => _FeedsBarState();
}

class _FeedsBarState extends ConsumerState<FeedsBar> {
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
        final l10n = AppLocalizations.of(context);
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
                    feed.view?.displayName ?? l10n.labelFollowing,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                // Like/Unlike option
                if (canLike)
                  ListTile(
                    leading: AppIcon(
                      isLiked ? AppIconData.likeFilled : AppIconData.like,
                      color: isLiked ? Colors.red : null,
                    ),
                    title: Text(
                      isLiked ? l10n.buttonUnlikeFeed : l10n.buttonLikeFeed,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref
                          .read(settingsProvider.notifier)
                          .setFeedLiked(feed, liked: !isLiked);
                    },
                  ),
                // Delete option
                if (canDelete)
                  ListTile(
                    leading: const AppIcon(
                      AppIconData.delete,
                      color: Colors.red,
                    ),
                    title: Text(
                      l10n.dialogRemoveFeed,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      // Show confirmation dialog
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.dialogRemoveFeed),
                          content: Text(
                            l10n.dialogRemoveFeedConfirm(
                              feed.view?.displayName ?? l10n.labelFollowing,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.buttonCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: Text(l10n.buttonRemove),
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
                  leading: const AppIcon(AppIconData.cancel),
                  title: Text(l10n.buttonCancel),
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
    final l10n = AppLocalizations.of(context);
    final visiblePinnedFeedsState = ref.watch(visiblePinnedFeedsProvider);
    final visiblePinnedFeeds = visiblePinnedFeedsState.feeds;
    final effectiveActiveFeed = visiblePinnedFeedsState.effectiveActiveFeed;
    final engine = ref.watch(moderationEngineProvider).asData?.value;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final tags = visiblePinnedFeeds.map((feed) {
      final isTimeline =
          feed.type == 'timeline' && feed.config.value == 'following';
      final generator = feed.view;
      var text = generator?.displayName ?? l10n.labelFollowing;
      if (engine != null && generator != null) {
        final decision = feedGeneratorModerationSubject(
          generator,
        ).evaluate(engine, preferredLocales: [locale]);
        if (decision.forContext(ModerationContext.contentList).blur) {
          text = l10n.moderationContentNotice;
        }
      }
      return FeedTagData(
        id: feed.config.id,
        text: text,
        isTimeline: isTimeline,
        isLiked: feed.view?.viewer?.like != null,
        canDelete: !isTimeline,
      );
    }).toList();

    return FeedsBarTemplate(
      tags: tags,
      selectedTagId: effectiveActiveFeed.config.id,
      onLeadingPressed: CreateMediaActions.onRecord(context, storyMode: false),
      onTagTap: (tagId) {
        final feed = visiblePinnedFeeds.firstWhere((f) => f.config.id == tagId);

        if (effectiveActiveFeed.config.id == feed.config.id) {
          ref.read(feedRefreshTriggerProvider(feed).notifier).trigger();
        } else {
          ref.read(settingsProvider.notifier).setActiveFeed(feed);
          final feedIndex = visiblePinnedFeeds.indexOf(feed);
          if (feedIndex != -1 && widget.pageController.hasClients) {
            widget.pageController.jumpToPage(feedIndex);
          }
        }
      },
      onLongPress: (tagData) {
        final feed = visiblePinnedFeeds.firstWhere(
          (f) => f.config.id == tagData.id,
        );
        _showFeedOptionsSheet(context, feed);
      },
    );
  }
}
