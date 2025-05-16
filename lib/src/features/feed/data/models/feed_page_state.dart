import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'feed_page_state.freezed.dart';

/// State class for the feed page
@freezed
class FeedPageState with _$FeedPageState {
  const factory FeedPageState({
    required bool isLoading,
    required List<FeedPost> posts,
    required int currentIndex,
    String? errorMessage,
    @Default(false) bool wasPlayingBeforePause,
  }) = _FeedPageState;

  factory FeedPageState.initial() => const FeedPageState(
    isLoading: true,
    posts: [],
    currentIndex: 0,
  );
} 