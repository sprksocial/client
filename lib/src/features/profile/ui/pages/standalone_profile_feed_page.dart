import 'package:auto_route/auto_route.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/cacheable_page_view.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_feed_post_widget.dart';

@RoutePage()
class StandaloneProfileFeedPage extends ConsumerStatefulWidget {
  final String profileUri;
  final bool videosOnly;
  final int initialPostIndex;

  const StandaloneProfileFeedPage({
    super.key,
    required this.profileUri,
    required this.videosOnly,
    required this.initialPostIndex,
  });

  @override
  ConsumerState<StandaloneProfileFeedPage> createState() => _StandaloneProfileFeedPageState();
}

class _StandaloneProfileFeedPageState extends ConsumerState<StandaloneProfileFeedPage> {
  late final PageController pageController;
  late final AtUri profileAtUri;

  @override
  void initState() {
    super.initState();
    profileAtUri = AtUri.parse(widget.profileUri);
    pageController = PageController(initialPage: widget.initialPostIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(profileFeedProvider(profileAtUri, widget.videosOnly));

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(backgroundColor: AppColors.black, leading: AutoLeadingButton()),
      body: feedState.when(
        data: (state) {
          if (state.loadedPosts.isEmpty) {
            return const Center(
              child: Text('No posts available', style: TextStyle(color: AppColors.white)),
            );
          }

          // Ensure initial index is within bounds
          final safeInitialIndex = widget.initialPostIndex.clamp(0, state.loadedPosts.length - 1);

          // Update page controller if needed
          if (pageController.hasClients && pageController.page?.round() != safeInitialIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && pageController.hasClients) {
                pageController.jumpToPage(safeInitialIndex);
              }
            });
          }

          return CacheablePageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            pageSnapping: true,
            itemCount: state.loadedPosts.length,
            onPageChanged: (index) {
              // Load more posts when approaching the end
              if (index >= state.loadedPosts.length - 3 && !state.isEndOfNetwork) {
                ref.read(profileFeedProvider(profileAtUri, widget.videosOnly).notifier).loadMore();
              }
            },
            itemBuilder: (context, index) {
              if (index >= state.loadedPosts.length) {
                return const Center(child: CircularProgressIndicator(color: AppColors.white));
              }

              final postUri = state.loadedPosts[index];
              final post = state.postViews[postUri];
              return ProfileFeedPostWidget(postUri: postUri, profileUri: profileAtUri, videosOnly: widget.videosOnly, post: post);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.white)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading feed: $error',
                style: const TextStyle(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(profileFeedProvider(profileAtUri, widget.videosOnly).notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
