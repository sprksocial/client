import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

class AudioPostsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<PostView> posts;
  final String? nextCursor;
  final String? error;

  const AudioPostsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.posts = const <PostView>[],
    this.nextCursor,
    this.error,
  });

  factory AudioPostsState.initial() => const AudioPostsState();

  AudioPostsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<PostView>? posts,
    String? nextCursor,
    String? error,
  }) {
    return AudioPostsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      posts: posts ?? this.posts,
      nextCursor: nextCursor ?? this.nextCursor,
      error: error ?? this.error,
    );
  }
}
