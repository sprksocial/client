import 'package:atproto_core/atproto_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/audio/providers/audio_posts_state.dart';

class AudioPostsNotifier extends StateNotifier<AudioPostsState> {
  final FeedRepository _feedRepository;
  final SparkLogger _logger;
  final String audioUri;

  AudioPostsNotifier(this.audioUri)
    : _feedRepository = GetIt.instance<SprkRepository>().feed,
      _logger = GetIt.instance<LogService>().getLogger('AudioPostsNotifier'),
      super(AudioPostsState.initial()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, posts: <PostView>[]);
    try {
      final uri = AtUri.parse(audioUri);
      final query = uri.rkey.isNotEmpty ? uri.rkey : audioUri;
      final res = await _feedRepository.searchPosts(query);
      final filtered = res.posts.where((p) => p.sound?.uri.toString() == audioUri).toList();
      state = state.copyWith(isLoading: false, posts: filtered, nextCursor: res.cursor);
    } catch (e) {
      _logger.e('Failed to load audio posts: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || (state.nextCursor == null || state.nextCursor!.isEmpty)) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final uri = AtUri.parse(audioUri);
      final query = uri.rkey.isNotEmpty ? uri.rkey : audioUri;
      final res = await _feedRepository.searchPosts(query, cursor: state.nextCursor);
      final filtered = res.posts.where((p) => p.sound?.uri.toString() == audioUri).toList();
      state = state.copyWith(
        isLoadingMore: false,
        posts: [...state.posts, ...filtered],
        nextCursor: res.cursor,
      );
    } catch (e) {
      _logger.e('Failed to load more audio posts: $e');
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final audioPostsProvider = StateNotifierProvider.family<AudioPostsNotifier, AudioPostsState, String>(
  (ref, audioUri) => AudioPostsNotifier(audioUri),
);
