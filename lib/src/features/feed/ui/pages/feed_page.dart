import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:auto_route/auto_route.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/feed_page_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_main_content.dart';

@RoutePage()
class FeedPage extends ConsumerStatefulWidget {
  final int feedType;
  final List<FeedPost>? initialPosts;
  final int? initialIndex;
  final bool showBackButton;
  final bool isParentFeedVisible;

  const FeedPage({
    super.key,
    required this.feedType,
    this.initialPosts,
    this.initialIndex,
    this.showBackButton = false,
    required this.isParentFeedVisible,
  });

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> with AutomaticKeepAliveClientMixin<FeedPage> {
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Jump to the initial index if provided
      if (widget.initialIndex != null && _pageController.hasClients) {
        _pageController.jumpToPage(widget.initialIndex!);
      }
    });
  }

  @override
  void didUpdateWidget(FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isParentFeedVisible != widget.isParentFeedVisible) {
      // Handle parent visibility changes
      Future.microtask(() {
        ref
            .read(
              feedPageStateNotifierProvider(
                widget.feedType,
                initialPosts: widget.initialPosts,
                initialIndex: widget.initialIndex,
              ).notifier,
            )
            .handleParentVisibilityChange(widget.isParentFeedVisible);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final feedState = ref.watch(
      feedPageStateNotifierProvider(widget.feedType, initialPosts: widget.initialPosts, initialIndex: widget.initialIndex),
    );

    // Optimization: Check if feed posts are available and parent is visible
    // before building the PageView. Reduces build calls when hidden.
    final bool canBuildPageView = feedState.posts.isNotEmpty && !feedState.isLoading && feedState.errorMessage == null;

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          FeedMainContent(
            feedState: feedState,
            canBuildPageView: canBuildPageView,
            pageController: _pageController,
            isParentFeedVisible: widget.isParentFeedVisible,
            feedType: widget.feedType,
            initialPosts: widget.initialPosts,
            initialIndex: widget.initialIndex,
            onPageChanged: (newIndex) {
              ref
                  .read(
                    feedPageStateNotifierProvider(
                      widget.feedType,
                      initialPosts: widget.initialPosts,
                      initialIndex: widget.initialIndex,
                    ).notifier,
                  )
                  .updateIndex(newIndex);
            },
          ),
          if (widget.showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(FluentIcons.arrow_left_24_regular, color: AppColors.white),
                onPressed: () => context.router.maybePop(),
              ),
            ),
        ],
      ),
    );
  }
}
