import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';

void showFeedSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Important for full height sheet
    backgroundColor: Colors.transparent, // Let the sheet handle its own background
    builder: (context) => FeedSettingsPage(),
  );
}

@RoutePage()
class FeedSettingsPage extends ConsumerWidget {
  const FeedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;

    return AutoTabsRouter.tabBar(
      routes: const [FeedListRoute()],
      builder: (context, child, tabController) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Feed Settings'),
            centerTitle: true,
            leading: AutoLeadingButton(),
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            bottom: TabBar(
              controller: tabController,
              labelColor: textColor,
              unselectedLabelColor: textColor.withAlpha(127),
              isScrollable: true,
              onTap: (index) {
                tabController.animateTo(index);
                AutoTabsRouter.of(context).setActiveIndex(index);
              },

              tabs: const [Tab(text: "Your Feeds")],
            ),
          ),
          body: child,
        );
      },
    );
  }
}
