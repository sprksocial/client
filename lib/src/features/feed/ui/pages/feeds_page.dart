import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feeds_bar.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class FeedsPage extends ConsumerWidget {
  const FeedsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final routes = <FeedRoute>[];

    for (final feed in settings.feeds) {
      routes.add(FeedRoute(feed: feed));
    }

    return AutoTabsRouter.tabBar(
      routes: routes,
      homeIndex: settings.feeds.indexOf(settings.activeFeed),
      builder: (context, child, tabController) {
        return SafeArea(child: Scaffold(appBar: FeedsBar(tabController: tabController), body: child));
      },
    );
  }
}
