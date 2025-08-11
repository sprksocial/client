import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/cacheable_page_view.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/feed_post_widget.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/no_more_posts.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({required this.feed, super.key});

  final Feed feed;

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> with AutomaticKeepAliveClientMixin {
  late final PageController pageController;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _hasInitialized = false;
  bool _isRefreshing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final state = ref.watch(feedNotifierProvider(widget.feed));
    final notifier = ref.read(feedNotifierProvider(widget.feed).notifier);
    final shouldBeActive = ref.watch(settingsProvider.select((settings) => settings.activeFeed == widget.feed));

    ref.listen(feedRefreshTriggerProvider(widget.feed), (previous, next) {
      if (previous != next) {
        _refreshIndicatorKey.currentState?.show();
      }
    });

    // Initialize feed when it becomes active for the first time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized && !state.loadingFirstLoad && state.length == 0 && !state.isEndOfNetworkFeed && !_isRefreshing) {
        _hasInitialized = true;
        notifier.loadAndUpdateFirstLoad();
      }
    });

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
          ? const Center(child: CircularProgressIndicator())
          : state.error
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading feed'),
                  TextButton(onPressed: onRefresh, child: const Text('Try again')),
                ],
              ),
            )
          : CacheablePageView.builder(
              cachePageExtent: 1,
              controller: pageController,
              key: PageStorageKey(widget.feed.identifier),
              itemCount: state.length + (state.isEndOfNetworkFeed ? 1 : 0),
              scrollDirection: Axis.vertical,
              restorationId: widget.feed.identifier,
              physics: shouldBeActive ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
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
                      : const DecoratedBox(decoration: BoxDecoration(color: AppColors.black));
                }
                // Handle last item with loading indicator
                else if (index == state.length - 1 && !state.isEndOfNetworkFeed) {
                  if (shouldBeActive) {
                    return Stack(
                      children: [
                        FeedPostWidget(index: index, feed: widget.feed),
                        const Positioned(
                          bottom: 10,
                          left: 10,
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const DecoratedBox(decoration: BoxDecoration(color: AppColors.black));
                  }
                }
                // Handle first load state
                else if (state.length == 0 && state.loadingFirstLoad) {
                  return shouldBeActive
                      ? const Center(child: CircularProgressIndicator())
                      : const DecoratedBox(decoration: BoxDecoration(color: AppColors.black));
                }
                // Handle empty state
                else if (state.length == 0 && !state.loadingFirstLoad) {
                  return shouldBeActive
                      ? const NoMorePosts()
                      : const DecoratedBox(decoration: BoxDecoration(color: AppColors.black));
                } else {
                  if (shouldBeActive) {
                    return FeedPostWidget(index: index, feed: widget.feed);
                  } else {
                    // Return SizedBox to maintain scroll position but hide content
                    return const DecoratedBox(decoration: BoxDecoration(color: AppColors.black));
                  }
                }
              },
            ),
    );
  }
}
