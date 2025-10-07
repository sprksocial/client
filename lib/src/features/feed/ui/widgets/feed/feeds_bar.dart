import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/feed_tag_list.dart';
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

    final tags = settings.feeds.map((feed) => (id: feed.identifier, text: feed.name)).toList();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(221, 0, 0, 0), Colors.transparent],
          ),
        ),
      ),
      title: Center(
        child: FeedTagList(
          tags: tags,
          selectedTagId: settings.activeFeed.identifier,
          onTagTap: (tagId) {
            final feed = settings.feeds.firstWhere(
              (f) => f.identifier == tagId,
            );

            if (settings.activeFeed == feed) {
              ref.read(feedRefreshTriggerProvider(feed).notifier).trigger();
            } else {
              ref.read(settingsProvider.notifier).setActiveFeed(feed);
              final feedIndex = settings.feeds.indexOf(feed);
              if (feedIndex != -1 && widget.pageController.hasClients) {
                widget.pageController.jumpToPage(feedIndex);
              }
            }
          },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(FluentIcons.options_24_regular),
          color: Colors.white,
          iconSize: 30,
          onPressed: () => context.router.navigate(const FeedSettingsRoute()),
        ),
      ],
    );
  }
}
