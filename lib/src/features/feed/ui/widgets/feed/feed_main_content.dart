import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/data/models/feed_page_state.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_page_view.dart';

class FeedMainContent extends StatelessWidget {
  final FeedPageState feedState;
  final bool canBuildPageView;
  final PageController pageController;
  final bool isParentFeedVisible;
  final int feedType;
  final List<FeedPost>? initialPosts;
  final int? initialIndex;
  final Function(int) onPageChanged;

  const FeedMainContent({
    super.key,
    required this.feedState,
    required this.canBuildPageView,
    required this.pageController,
    required this.isParentFeedVisible,
    required this.feedType,
    this.initialPosts,
    this.initialIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child:
          feedState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : feedState.errorMessage != null
              ? Center(child: Text('Error: ${feedState.errorMessage}', style: const TextStyle(color: AppColors.white)))
              : feedState.posts.isEmpty
              ? const Center(child: Text('No media available', style: TextStyle(color: AppColors.white)))
              : canBuildPageView
              ? FeedPageView(
                pageController: pageController,
                feedState: feedState,
                isParentFeedVisible: isParentFeedVisible,
                feedType: feedType,
                initialPosts: initialPosts,
                initialIndex: initialIndex,
                onPageChanged: onPageChanged,
              )
              : const SizedBox.shrink(),
    );
  }
}
