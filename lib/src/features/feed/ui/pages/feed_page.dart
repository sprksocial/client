import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';

@RoutePage()
class FeedPage extends ConsumerWidget {
  final Feed feed;
  const FeedPage({super.key, required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedNotifierProvider(feed));
    final notifier = ref.watch(feedNotifierProvider(feed).notifier);
    final pageController = PageController();

    return PageView.builder(
      controller: pageController,
      key: PageStorageKey(feed.identifier),
      itemCount: state.length + (state.isEndOfNetworkFeed ? 1 : 0),
      scrollDirection: Axis.vertical,
      pageSnapping: true,
      restorationId: feed.identifier,
      onPageChanged: (index) {
        if (index > state.index) {
          notifier.scrollDown();
        }
        notifier.setIndex(index);
      },
      itemBuilder: (context, index) {
        if (!state.active || (index - state.index).abs() > 1) {
          return SizedBox();
        } else if (index == state.length) {
          return NoMorePosts();
        } else if (index == state.index - 1 && !state.isEndOfNetworkFeed) {
          return Stack(
            children: [
              PostWidget(post: state.posts[index], index: index),
              Positioned(bottom: 10, left: 0, right: 0, child: CircularProgressIndicator()),
            ],
          );
        } else {
          return PostWidget(post: state.posts[index], index: index);
        }
      },
    );
  }
}
