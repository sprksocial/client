import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/search/providers/post_search_state.dart';

part 'post_search_provider.g.dart';

/// Search provider for post search functionality
@riverpod
class PostSearch extends _$PostSearch {
  Timer? _debounce;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('PostSearchProvider');
  final FeedRepository _feedRepository = GetIt.instance<SprkRepository>().feed;

  @override
  PostSearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    return PostSearchState.initial();
  }

  /// Update the search query and trigger search with debounce
  void updateQuery(String query) {
    // Update query and reset pagination state
    state = state.copyWith(query: query, searchResults: [], nextCursor: null, error: null);

    if (query.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    // Set loading state immediately for non-empty queries
    state = state.copyWith(isLoading: true);

    // Debounce the search
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPosts(query);
    });
  }

  /// Search for posts with the given query
  Future<void> _searchPosts(String query) async {
    if (query.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _feedRepository.searchPosts(query);
      state = state.copyWith(
        searchResults: response.posts,
        nextCursor: response.cursor,
        isLoading: false,
      );
      _logger.d('Search completed with ${response.posts.length} results, nextCursor: ${response.cursor}');
    } catch (e) {
      _logger.e('Error searching posts: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Load more posts using the next cursor if available
  Future<void> loadMorePosts() async {
    final nextCursor = state.nextCursor;
    if (nextCursor == null || nextCursor.isEmpty || state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _feedRepository.searchPosts(state.query, cursor: nextCursor);
      state = state.copyWith(
        searchResults: [...state.searchResults, ...response.posts],
        nextCursor: response.cursor,
        isLoadingMore: false,
      );
    } catch (e) {
      _logger.e('Error loading more posts: $e');
      state = state.copyWith(error: e.toString(), isLoadingMore: false);
    }
  }
}
