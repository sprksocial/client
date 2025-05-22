import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/feed/data/models/feed_page_state.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_post_item.dart';

class FeedPageView extends ConsumerWidget {
  final PageController pageController;
  final FeedPageState feedState;
  final bool isParentFeedVisible;
  final int feedType;
  final List<FeedPost>? initialPosts;
  final int? initialIndex;
  final Function(int) onPageChanged;

  const FeedPageView({
    super.key,
    required this.pageController,
    required this.feedState,
    required this.isParentFeedVisible,
    required this.feedType,
    this.initialPosts,
    this.initialIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      physics: isParentFeedVisible ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
      itemCount: feedState.posts.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return FeedPostItem(
          post: feedState.posts[index],
          index: index,
          feedState: feedState,
          isParentFeedVisible: isParentFeedVisible,
          feedType: feedType,
          initialPosts: initialPosts,
          initialIndex: initialIndex,
          ref: ref,
        );
      },
    );
  }
}
