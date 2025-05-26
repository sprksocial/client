import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/feed/providers/feed_option_state.dart';

part 'feed_option_provider.g.dart';

@riverpod
class FeedOption extends _$FeedOption {
  @override
  FeedOptionState build(Feed feed) {
    return FeedOptionState();
  }

  void setSelected(bool isSelected) {
    state = state.copyWith(isSelected: isSelected);
  }
}
