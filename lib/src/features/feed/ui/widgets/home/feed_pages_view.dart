import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/feed/providers/feed_type_provider.dart';
import 'package:sparksocial/src/features/feed/ui/pages/feed_page.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedPagesView extends ConsumerWidget {
  final PageController pageController;
  final bool isHomeScreenVisible;

  const FeedPagesView({super.key, required this.pageController, required this.isHomeScreenVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final pages = <Widget>[];

    if (settings.followingFeedEnabled) {
      pages.add(
        FeedPage(
          key: const ValueKey('feed_following'),
          feedType: FeedType.following.value,
          isParentFeedVisible: isHomeScreenVisible,
        ),
      );
    }

    if (settings.forYouFeedEnabled) {
      pages.add(
        FeedPage(key: const ValueKey('feed_for_you'), feedType: FeedType.forYou.value, isParentFeedVisible: isHomeScreenVisible),
      );
    }

    if (settings.latestFeedEnabled) {
      pages.add(
        FeedPage(key: const ValueKey('feed_latest'), feedType: FeedType.latest.value, isParentFeedVisible: isHomeScreenVisible),
      );
    }

    return PageView(
      controller: pageController,
      children: pages,
      onPageChanged: (index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Get enabled feeds in order
          final enabledFeeds = <FeedType>[];
          if (settings.followingFeedEnabled) enabledFeeds.add(FeedType.following);
          if (settings.forYouFeedEnabled) enabledFeeds.add(FeedType.forYou);
          if (settings.latestFeedEnabled) enabledFeeds.add(FeedType.latest);

          // Set the feed type based on index
          if (index < enabledFeeds.length) {
            if (ref.exists(feedTypeNotifierProvider)) {
              ref.read(feedTypeNotifierProvider.notifier).setFeedType(enabledFeeds[index]);
            }
          }
        });
      },
    );
  }
}
