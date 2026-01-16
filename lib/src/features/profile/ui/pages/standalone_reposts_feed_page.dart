import 'dart:ui';

import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/feed/ui/widgets/feed/cacheable_page_view.dart';
import 'package:spark/src/features/feed/ui/widgets/feed/snappy_page_scroll_physics.dart';
import 'package:spark/src/features/profile/providers/profile_feed_index_provider.dart';
import 'package:spark/src/features/profile/providers/profile_reposts_provider.dart';
import 'package:spark/src/features/profile/ui/widgets/profile_feed_post_widget.dart';

@RoutePage()
class StandaloneRepostsFeedPage extends ConsumerStatefulWidget {
  const StandaloneRepostsFeedPage({
    @PathParam('did') required this.did,
    required this.initialPostIndex,
    super.key,
  });
  final String did;
  final int initialPostIndex;

  @override
  ConsumerState<StandaloneRepostsFeedPage> createState() =>
      _StandaloneRepostsFeedPageState();
}

class _StandaloneRepostsFeedPageState
    extends ConsumerState<StandaloneRepostsFeedPage> {
  late final PageController pageController;
  int _currentIndex = 0;
  bool _hasInitializedIndex = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPostIndex;
    pageController = PageController(initialPage: widget.initialPostIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInitializedIndex) {
      _hasInitializedIndex = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(profileFeedIndexProvider('reposts:${widget.did}').notifier)
            .setIndex(widget.initialPostIndex);
      });
    }

    final repostsState = ref.watch(profileRepostsProvider(widget.did));
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Full-screen content
          repostsState.when(
            data: (state) {
              // Display all posts returned by server - no client-side filtering
              final filteredUris = state.loadedPosts;

              if (filteredUris.isEmpty) {
                return const Center(
                  child: Text(
                    'No reposts available',
                    style: TextStyle(color: AppColors.white),
                  ),
                );
              }

              return CacheablePageView.builder(
                cachePageExtent: 1,
                controller: pageController,
                scrollDirection: Axis.vertical,
                physics: const SnappyPageScrollPhysics(),
                allowImplicitScrolling: true,
                itemCount: filteredUris.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  ref
                      .read(
                        profileFeedIndexProvider(
                          'reposts:${widget.did}',
                        ).notifier,
                      )
                      .setIndex(index);
                  // Load more posts when approaching the end
                  if (index >= filteredUris.length - 3 &&
                      !state.isEndOfNetwork) {
                    ref
                        .read(profileRepostsProvider(widget.did).notifier)
                        .loadMore();
                  }
                },
                itemBuilder: (context, index) {
                  final postUri = filteredUris[index];
                  final post = state.postViews[postUri];
                  // Create a profile URI from the did for the post widget
                  final profileUri = AtUri.parse('at://${widget.did}');
                  return ProfileFeedPostWidget(
                    postUri: postUri,
                    profileUri: profileUri,
                    videosOnly: false,
                    post: post,
                    index: index,
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reposts: $error',
                    style: const TextStyle(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(profileRepostsProvider(widget.did).notifier)
                          .refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          // Back button overlay - respects safe area for the button only
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => context.router.maybePop(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _CommentBar(
        bottomPadding: bottomPadding,
        onTap: () {
          final state = repostsState.value;
          if (state != null && state.loadedPosts.isNotEmpty) {
            final currentPostUri = state.loadedPosts[_currentIndex];
            final post = state.postViews[currentPostUri];
            if (post != null) {
              context.router.push(
                CommentsRoute(
                  postUri: post.uri.toString(),
                  isSprk: post.isSprk,
                  post: post,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _CommentBar extends StatelessWidget {
  const _CommentBar({
    required this.bottomPadding,
    required this.onTap,
  });

  final double bottomPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.blurBottomBar.toDouble(),
          sigmaY: AppConstants.blurBottomBar.toDouble(),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color.fromARGB(51, 0, 0, 0),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 2,
              ),
            ),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + bottomPadding,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Add comment...',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
