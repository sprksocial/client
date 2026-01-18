import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/feed/providers/feed_action_controller.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:spark/src/features/feed/ui/widgets/feed/cacheable_page_view.dart';
import 'package:spark/src/features/feed/ui/widgets/feed/snappy_page_scroll_physics.dart';
import 'package:spark/src/features/feed/ui/widgets/post/feed_post_skeleton.dart';
import 'package:spark/src/features/feed/ui/widgets/post/feed_post_widget.dart';
import 'package:spark/src/features/feed/ui/widgets/post/no_more_posts.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({required this.feed, super.key});

  final Feed feed;

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage>
    with AutomaticKeepAliveClientMixin {
  late final PageController pageController;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _hasInitialized = false;
  bool _isRefreshing = false;
  FeedActionControllerNotifier? _actionControllerNotifier;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // Register the feed action controller so child widgets can trigger
    // feed-level actions like advancing after blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      // Save the notifier for safe access in dispose()
      _actionControllerNotifier = ref.read(
        feedActionControllerProvider(widget.feed).notifier,
      );
      _actionControllerNotifier!.setController(
        FeedActionController(
          onAdvanceAndRemove: scrollToNextAndRemovePrevious,
        ),
      );
    });
  }

  @override
  void dispose() {
    // Delay clearing the controller to avoid modifying provider state
    // during widget tree finalization
    final notifier = _actionControllerNotifier;
    if (notifier != null) {
      Future(notifier.clearController);
    }
    pageController.dispose();
    super.dispose();
  }

  /// Scrolls to the next post and removes the current one from the feed.
  /// This allows users to quickly advance through their feed while
  /// removing posts they've already seen.
  Future<void> scrollToNextAndRemovePrevious() async {
    final state = ref.read(feedProvider(widget.feed));
    final notifier = ref.read(feedProvider(widget.feed).notifier);
    final currentIndex = state.index;

    // Check if there's a next post to scroll to
    if (currentIndex >= state.length - 1) return;

    // Remove the current post. Since the PageController is at currentIndex,
    // and we're removing the item at currentIndex, the next post naturally
    // takes its place at the same index. The PageView will rebuild with
    // the new item at this index, effectively showing the "next" post.
    notifier.removePostAtIndex(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final state = ref.watch(feedProvider(widget.feed));
    final notifier = ref.read(feedProvider(widget.feed).notifier);
    final shouldBeActive = ref.watch(
      settingsProvider.select((settings) => settings.activeFeed == widget.feed),
    );

    ref.listen(feedRefreshTriggerProvider(widget.feed), (previous, next) {
      if (previous != next) {
        _refreshIndicatorKey.currentState?.show();
      }
    });

    // Initialize feed when it becomes active for the first time
    if (!_hasInitialized &&
        !state.loadingFirstLoad &&
        state.length == 0 &&
        !state.isEndOfNetworkFeed &&
        !_isRefreshing &&
        shouldBeActive) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifier.loadAndUpdateFirstLoad();
        }
      });
    }

    // Always set the correct active state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.active != shouldBeActive) {
        notifier.setActive(shouldBeActive);
      }
    });

    Future<void> onRefresh() async {
      if (_isRefreshing) return;

      setState(() {
        _isRefreshing = true;
      });

      try {
        // Jump to top immediately without animation
        if (pageController.hasClients) {
          pageController.jumpToPage(0);
        }

        // Only reset initialization flag, don't invalidate the entire provider
        _hasInitialized = false;
        await notifier.loadAndUpdateFirstLoad();
      } finally {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      }
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: onRefresh,
      child: state.loadingFirstLoad
          ? const FeedPostSkeleton()
          : state.error
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading feed'),
                  TextButton(
                    onPressed: onRefresh,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )
          : CacheablePageView.builder(
              cachePageExtent: 1,
              controller: pageController,
              key: PageStorageKey(widget.feed.config.id),
              itemCount: state.length + (state.isEndOfNetworkFeed ? 1 : 0),
              scrollDirection: Axis.vertical,
              restorationId: widget.feed.config.id,
              physics: shouldBeActive
                  ? const SnappyPageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              allowImplicitScrolling: true,
              onPageChanged: (index) {
                // Only handle page changes when active
                if (shouldBeActive) {
                  if (index > state.index) {
                    notifier.scrollDown();
                  }
                  notifier.setIndex(index);
                }
              },
              itemBuilder: (context, index) {
                // Handle end of feed
                if (index == state.length) {
                  return shouldBeActive
                      ? const NoMorePosts()
                      : const DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.black),
                        );
                }
                // Handle last item with loading indicator
                else if (index == state.length - 1 &&
                    !state.isEndOfNetworkFeed) {
                  if (shouldBeActive) {
                    return Stack(
                      children: [
                        FeedPostWidget(
                          index: index,
                          feed: widget.feed,
                        ),
                        const Positioned(
                          bottom: 10,
                          left: 10,
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.black),
                    );
                  }
                }
                // Handle empty state
                else if (state.length == 0 && !state.loadingFirstLoad) {
                  return shouldBeActive
                      ? const NoMorePosts()
                      : const DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.black),
                        );
                } else {
                  if (shouldBeActive) {
                    return FeedPostWidget(
                      index: index,
                      feed: widget.feed,
                    );
                  } else {
                    // SizedBox to maintain scroll position but hide content
                    return const DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.black),
                    );
                  }
                }
              },
            ),
    );
  }
}
