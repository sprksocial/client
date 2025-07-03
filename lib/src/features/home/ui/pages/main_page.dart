import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:sparksocial/src/features/home/providers/navigation_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      key: const ValueKey('mainTabsRouter'),
      routes: [const FeedsRoute(), const SearchRoute(), const EmptyRoute(), const MessagesRoute(), UserProfileRoute()],
      transitionBuilder: (context, child, animation) => child,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          backgroundColor: Colors.black,
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                // Special case for Create button - navigate to create video page
                context.router.push(CreateVideoRoute(isStoryMode: false));
              } else {
                if (tabsRouter.activeIndex == index && index == 0) {
                  final activeFeed = ref.read(settingsProvider).activeFeed;
                  ref.read(feedRefreshTriggerProvider(activeFeed).notifier).trigger();
                } else {
                  tabsRouter.setActiveIndex(index);
                  ref.read(navigationProvider.notifier).updateIndex(index);
                }
              }
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(FluentIcons.home_24_regular),
                selectedIcon: Icon(FluentIcons.home_24_filled),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(FluentIcons.compass_northwest_24_regular),
                selectedIcon: Icon(FluentIcons.compass_northwest_24_filled),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Container(
                  width: 48,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Icon(FluentIcons.add_24_filled, color: AppColors.white, size: 24)),
                ),
                label: 'Create',
              ),
              const NavigationDestination(
                icon: Icon(FluentIcons.mail_inbox_all_24_regular),
                selectedIcon: Icon(FluentIcons.mail_inbox_all_24_filled),
                label: 'Inbox',
              ),
              const NavigationDestination(
                icon: Icon(FluentIcons.person_24_regular),
                selectedIcon: Icon(FluentIcons.person_24_filled),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
