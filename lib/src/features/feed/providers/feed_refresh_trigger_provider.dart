import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

class FeedRefreshTrigger extends StateNotifier<int> {
  FeedRefreshTrigger() : super(0);

  void trigger() {
    state++;
  }
}

final feedRefreshTriggerProvider = StateNotifierProvider.family<FeedRefreshTrigger, int, Feed>(
  (ref, feed) => FeedRefreshTrigger(),
);
