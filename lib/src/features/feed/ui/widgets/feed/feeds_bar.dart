import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_option.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedsBar extends ConsumerWidget implements PreferredSizeWidget {
  const FeedsBar({super.key, this.pageController});

  final PageController? pageController;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final feedOptions =
        settings.feeds
            .map(
              (feed) => FeedOption(
                feed: feed,
                key: ValueKey(feed.identifier),
                onTap: () {
                  ref.read(settingsProvider.notifier).setActiveFeed(feed);
                  AutoTabsRouter.of(context).setActiveIndex(settings.feeds.indexOf(feed));
                },
              ),
            )
            .toList();
    return AppBar(
      title: Container(
        height: 40,
        child: ReorderableList(
          itemCount: feedOptions.length,
          itemBuilder: (context, index) => feedOptions[index],
          onReorder: (oldIndex, newIndex) {
            ref.read(settingsProvider.notifier).reorderFeed(oldIndex, newIndex);
          },
          scrollDirection: Axis.horizontal,
        ),
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
