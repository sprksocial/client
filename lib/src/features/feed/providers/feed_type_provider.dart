import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'feed_type_provider.g.dart';

/// Provider for managing the current feed type
@riverpod
class FeedTypeNotifier extends _$FeedTypeNotifier {
  @override
  FeedType build() {
    // Default to the For You feed
    return FeedType.forYou;
  }

  /// Update the current feed type
  void setFeedType(FeedType feedType) {
    state = feedType;
  }
} 