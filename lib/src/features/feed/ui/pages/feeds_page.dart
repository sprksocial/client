// ignore_for_file: dead_code

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';
import 'package:sparksocial/src/features/feed/ui/pages/feed_page.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feeds_bar.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';

@RoutePage()
class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({super.key});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  PageController? _pageController;
  bool _isInitialized = false;
  Feed? _lastActiveFeed;
  List<Feed>? _lastFeedsList;
  bool _isPageControllerUpdating = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _updatePageController(List<Feed> feeds, Feed activeFeed) {
    if (_isPageControllerUpdating) return;
    
    final activeIndex = feeds.indexOf(activeFeed);
    if (activeIndex < 0) return;
    
    if (_pageController == null) {
      _pageController = PageController(initialPage: activeIndex);
      return;
    }
    
    if (!_pageController!.hasClients) return;
    
    final currentPage = _pageController!.page?.round() ?? 0;
    if (currentPage != activeIndex) {
      _isPageControllerUpdating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController!.hasClients) {
          _pageController!.jumpToPage(activeIndex);
        }
        _isPageControllerUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final feeds = settings.feeds;
    final activeFeed = settings.activeFeed;
    
    // Feed providers are watched at MainPage level, but we still need to watch them here
    // for the debug overlay to update properly
    final feedStates = <Feed, FeedState>{};
    for (final feed in feeds) {
      feedStates[feed] = ref.watch(feedNotifierProvider(feed));
    }
    
    // Initialize feeds that haven't been loaded yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final feed in feeds) {
        final state = feedStates[feed]!;
        final notifier = ref.read(feedNotifierProvider(feed).notifier);
        
        // Only load if the feed is empty and not already loading and active
        if (state.length == 0 && !state.loadingFirstLoad && !state.isEndOfNetworkFeed && feed == activeFeed) {
          notifier.loadAndUpdateFirstLoad();
        }
      }
    });
    
    // Check if we need to initialize or update the page controller
    final needsInitialization = !_isInitialized;
    final activeFeedChanged = _lastActiveFeed != activeFeed;
    final feedsListChanged = _lastFeedsList == null || 
        _lastFeedsList!.length != feeds.length ||
        !_lastFeedsList!.every((feed) => feeds.contains(feed));
    
    if (needsInitialization || activeFeedChanged || feedsListChanged) {
      _updatePageController(feeds, activeFeed);
      _isInitialized = true;
      _lastActiveFeed = activeFeed;
      _lastFeedsList = List.from(feeds); // Create a copy
    }
    
    if (_pageController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FeedsBar(pageController: _pageController!),
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: feeds.length,
            pageSnapping: true,
            onPageChanged: (index) {
              // Prevent recursive updates
              if (_isPageControllerUpdating) return;
              
              // Update the active feed when page changes via swipe
              if (index >= 0 && index < feeds.length) {
                final selectedFeed = feeds[index];
                if (selectedFeed != activeFeed) {
                  ref.read(settingsProvider.notifier).setActiveFeed(selectedFeed);
                }
              }
            },
            itemBuilder: (context, index) {
              if (index >= 0 && index < feeds.length) {
                // Use feed identifier as key to preserve state across reordering
                return KeyedSubtree(
                  key: ValueKey(feeds[index].identifier),
                  child: FeedPage(feed: feeds[index]),
                );
              }
              return const DecoratedBox(decoration: BoxDecoration(color: AppColors.black));
            },
          ),
        ],
      ),
    );
  }
}
