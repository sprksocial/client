import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/templates/feeds_bar_template.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedsBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const FeedsBar({required this.pageController, super.key});

  final PageController pageController;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<FeedsBar> createState() => _FeedsBarState();
}

class _FeedsBarState extends ConsumerState<FeedsBar> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Only show pinned feeds in the home view
    final pinnedFeeds = settings.feeds.where((feed) => feed.config.pinned).toList();

    final tags = pinnedFeeds
        .map((feed) => (id: feed.config.id, text: feed.view != null ? feed.view!.displayName : 'Following'))
        .toList();

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
      action: IconButton(
        icon: AppIcons.hashtag(),
        padding: const EdgeInsets.all(5),
        onPressed: () => context.router.navigate(const FeedSettingsRoute()),
      ),
    );
  }
}
