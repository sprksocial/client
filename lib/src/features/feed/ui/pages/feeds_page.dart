import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/feed_state.dart';
import 'package:spark/src/features/feed/ui/pages/feed_page.dart';
import 'package:spark/src/features/feed/ui/widgets/feed/feeds_bar.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

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
    
    // Always try to create controller if we don't have one and have feeds
    if (_pageController == null && feeds.isNotEmpty) {
      _pageController = PageController(
        initialPage: activeIndex >= 0 ? activeIndex : 0,
      );
      return;
    }

    if (activeIndex < 0 && feeds.isNotEmpty) {
      // If active feed not in list but we have feeds, ensure controller exists
      if (_pageController == null) {
        _pageController = PageController(initialPage: 0);
      }
      return;
    }

    if (_pageController == null) return;
    if (!_pageController!.hasClients) return;

    final currentPage = _pageController!.page?.round() ?? 0;
    if (currentPage != activeIndex && activeIndex >= 0) {
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
    // Only show pinned feeds in the home view
    final feeds = settings.feeds.where((feed) => feed.config.pinned).toList();
    final activeFeed = settings.activeFeed;

    // Feed providers are watched at MainPage level, but we still need to watch
    // them here for the debug overlay to update properly
    final feedStates = <Feed, FeedState>{};
    for (final feed in feeds) {
      feedStates[feed] = ref.watch(feedProvider(feed));
    }

    // Initialize feeds that haven't been loaded yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final feed in feeds) {
        final state = feedStates[feed]!;
        final notifier = ref.read(feedProvider(feed).notifier);

        // Only load if the feed is empty and not already loading and active
        if (state.length == 0 &&
            !state.loadingFirstLoad &&
            !state.isEndOfNetworkFeed &&
            feed == activeFeed) {
          notifier.loadAndUpdateFirstLoad();
        }
      }
    });

    // Check if we need to initialize or update the page controller
    final needsInitialization = !_isInitialized;
    final activeFeedChanged = _lastActiveFeed != activeFeed;
    final feedsListChanged =
        _lastFeedsList == null ||
        _lastFeedsList!.length != feeds.length ||
        !_lastFeedsList!.every(feeds.contains);

    if (needsInitialization || activeFeedChanged || feedsListChanged) {
      _updatePageController(feeds, activeFeed);
      _isInitialized = true;
      _lastActiveFeed = activeFeed;
      _lastFeedsList = List.from(feeds); // Create a copy
    }

    // Ensure controller is created if we have feeds but controller is null
    // This prevents the FeedsBar from disappearing during initialization
    // Also create it early if feeds list is still empty (handles transition from initial empty state)
    if (_pageController == null) {
      if (feeds.isNotEmpty) {
        final activeIndex = feeds.indexOf(activeFeed);
        _pageController = PageController(
          initialPage: activeIndex >= 0 ? activeIndex : 0,
        );
      } else {
        // Create controller even when feeds list is empty to keep FeedsBar visible
        // This handles the case when settings are still loading (feeds will populate soon)
        _pageController = PageController(initialPage: 0);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          if (_pageController != null && feeds.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: feeds.length,
              onPageChanged: (index) {
                // Prevent recursive updates
                if (_isPageControllerUpdating) return;

                // Update the active feed when page changes via swipe
                if (index >= 0 && index < feeds.length) {
                  final selectedFeed = feeds[index];
                  if (selectedFeed != activeFeed) {
                    ref
                        .read(settingsProvider.notifier)
                        .setActiveFeed(selectedFeed);
                  }
                }
              },
              itemBuilder: (context, index) {
                if (index >= 0 && index < feeds.length) {
                  // Use feed ID as key to preserve state across reordering
                  return KeyedSubtree(
                    key: ValueKey(feeds[index].config.id),
                    child: FeedPage(feed: feeds[index]),
                  );
                }
                return const DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.black),
                );
              },
            )
          else
            const Center(child: CircularProgressIndicator()),
          // Always show FeedsBar once we have a controller
          // The controller is created as soon as we have activeFeed,
          // keeping it visible through the initialization transition
          if (_pageController != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FeedsBar(pageController: _pageController!),
            ),
        ],
      ),
    );
  }
}
