import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/feed/providers/feed_type_provider.dart';

class FeedTypeHelper {
  final WidgetRef ref;
  final PageController pageController;

  FeedTypeHelper(this.ref, this.pageController);

  /// Initialize the PageController to show the current feed type
  void initializePageController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        final settings = ref.read(settingsProvider);
        final initialFeedType = settings.selectedFeedType;
        final feedTypeIndex = getFeedTypeIndex(initialFeedType);

        final List<FeedType> enabledFeeds = _getEnabledFeeds();
        if (feedTypeIndex < enabledFeeds.length && feedTypeIndex >= 0) {
          pageController.jumpToPage(feedTypeIndex);
        } else if (enabledFeeds.isNotEmpty) {
          pageController.jumpToPage(0);
          ref.read(feedTypeNotifierProvider.notifier).setFeedType(enabledFeeds[0]);
        }
      }
    });

    // Listen to feedTypeNotifierProvider changes to animate the PageController
    ref.listen<FeedType>(feedTypeNotifierProvider, (previous, next) {
      final newIndex = getFeedTypeIndex(next);
      if (pageController.hasClients && pageController.page?.round() != newIndex && newIndex >= 0) {
        // Ensure newIndex is valid
        pageController.jumpToPage(newIndex);
      }
    });
  }

  /// Convert FeedType to index in the page view
  int getFeedTypeIndex(FeedType feedType) {
    final settings = ref.read(settingsProvider);
    final List<FeedType> enabledFeeds = [];
    if (settings.followingFeedEnabled) {
      enabledFeeds.add(FeedType.following);
    }
    if (settings.forYouFeedEnabled) {
      enabledFeeds.add(FeedType.forYou);
    }
    if (settings.latestFeedEnabled) {
      enabledFeeds.add(FeedType.latest);
    }
    int index = enabledFeeds.indexOf(feedType);
    return index != -1 ? index : 0;
  }

  List<FeedType> _getEnabledFeeds() {
    final settings = ref.read(settingsProvider);
    final List<FeedType> enabledFeeds = [];
    if (settings.followingFeedEnabled) enabledFeeds.add(FeedType.following);
    if (settings.forYouFeedEnabled) enabledFeeds.add(FeedType.forYou);
    if (settings.latestFeedEnabled) enabledFeeds.add(FeedType.latest);
    return enabledFeeds;
  }
}
