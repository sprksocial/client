import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_tabbar/reorderable_tabbar.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_option.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedsBar extends ConsumerWidget implements PreferredSizeWidget {
  const FeedsBar({super.key, this.tabController});

  final TabController? tabController;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final feedOptions = settings.feeds.map((feed) => FeedOption(feed: feed)).toList();
    return AppBar(
      title: ReorderableTabBar(
        tabs: feedOptions,
        controller: tabController,
        isScrollable: true,
        enableFeedback: false,
        onTap: (value) {
          ref.read(settingsProvider.notifier).setActiveFeed(settings.feeds[value]);
          AutoTabsRouter.of(context).setActiveIndex(value);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(FluentIcons.options_24_regular),
          color: AppColors.lightLavender,
          iconSize: 30,
          onPressed: () => context.router.navigate(FeedSettingsRoute()),
        ),
      ],
    );
  }
}
