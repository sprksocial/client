import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedTypeHelper {
  final WidgetRef ref;
  final PageController pageController;
  
  FeedTypeHelper(this.ref, this.pageController);

  /// Initialize the PageController to show the current feed type
  void initializePageController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        final settings = ref.read(settingsProvider);
        final feedTypeIndex = getFeedTypeIndex(settings.selectedFeedType);
        pageController.jumpToPage(feedTypeIndex);
      }
    });
  }

  /// Convert FeedType to index in the page view
  int getFeedTypeIndex(FeedType feedType) {
    final settings = ref.read(settingsProvider);
    int index = 0;
    
    if (feedType == FeedType.following && settings.followingFeedEnabled) {
      return index;
    } else if (settings.followingFeedEnabled) {
      index++;
    }
    
    if (feedType == FeedType.forYou && settings.forYouFeedEnabled) {
      return index;
    } else if (settings.forYouFeedEnabled) {
      index++;
    }
    
    if (feedType == FeedType.latest && settings.latestFeedEnabled) {
      return index;
    }
    
    // Default to first available
    return 0;
  }
} 