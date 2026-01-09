import 'package:flutter_riverpod/legacy.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

class FeedRefreshTrigger extends StateNotifier<int> {
  FeedRefreshTrigger() : super(0);

  void trigger() {
    state++;
  }
}

final StateNotifierProviderFamily<FeedRefreshTrigger, int, Feed>
feedRefreshTriggerProvider =
    StateNotifierProvider.family<FeedRefreshTrigger, int, Feed>(
      (ref, feed) => FeedRefreshTrigger(),
    );
