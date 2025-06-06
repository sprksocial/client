// ignore_for_file: dead_code

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
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
    // Settings are now loaded automatically in the provider's build method
    // No need to manually call loadSettings() here
  }

  @override
  Widget build(BuildContext context) {
    // Don't watch feed providers at this level as it causes unnecessary disposal/recreation
    // when settings change. Feed providers are managed by their individual pages.
    final settings = ref.watch(settingsProvider);

    return AutoTabsRouter(
      key: const ValueKey('mainTabsRouter'),
      routes: [const FeedsRoute(), const SearchRoute(), const EmptyRoute(), const MessagesRoute(), const UserProfileRoute()],
      transitionBuilder: (context, child, animation) => FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              child,

              // Debug overlay for MainPage (top left)
              if (false) // Disabled debug overlay
                Positioned(
                  top: 50,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.purple.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('MainPage:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        Text('Tab: ${tabsRouter.activeIndex}', style: const TextStyle(color: Colors.yellow, fontSize: 10)),
                        Text(
                          'Active Feed: ${settings.activeFeed.name}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                // Special case for Create button
                context.router.push(const PlaceholderRoute());
              } else {
                tabsRouter.setActiveIndex(index);
                ref.read(navigationProvider.notifier).updateIndex(index);
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
