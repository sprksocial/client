import 'dart:async';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
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
  final AuthRepository _authRepository = GetIt.instance<AuthRepository>();

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
    state = state.copyWith(query: query, searchResults: [], sprkNextCursor: null, bskyNextCursor: null, error: null);

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
      final bskySession = _authRepository.session;
      if (bskySession == null) {
        return;
      }

      final bskyApi = bsky.Bluesky.fromSession(bskySession);
      final sprkSearch = _feedRepository.searchPosts(query);
      final bskySearch = bskyApi.feed.searchPosts(query, sort: 'top');

      final results = await Future.wait([sprkSearch, bskySearch]);

      final sprkResponse = results[0] as ({String? cursor, List<PostView> posts});
      final bskyResponse = results[1] as XRPCResponse<bsky.PostsByQuery>;

      final bskyPosts = bskyResponse.data.posts
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final post = entry.value;

            try {
              final postJson = post.toJson();
              if (postJson['record']['reply'] != null || post.embed == null) {
                return null;
              }
              return PostView.fromJson(postJson);
            } catch (e, stackTrace) {
              final postJson = post.toJson();
              _logger.e('Failed to convert bsky post ${index + 1}/${bskyResponse.data.posts.length}');
              _logger.e('Post URI: ${post.uri}');
              _logger.e('Post JSON: $postJson');
              _logger.e('Error: $e');
              _logger.e('Stack trace: $stackTrace');
              return null;
            }
          })
          .where((post) => post != null && post.hasSupportedMedia)
          .cast<PostView>()
          .toList();

      _logger.d('Successfully converted ${bskyPosts.length}/${bskyResponse.data.posts.length} bsky posts');

      final combinedPosts = [...sprkResponse.posts, ...bskyPosts];

      state = state.copyWith(
        searchResults: combinedPosts,
        sprkNextCursor: sprkResponse.cursor,
        bskyNextCursor: bskyResponse.data.cursor,
        isLoading: false,
      );
      _logger.d(
        'Search completed with ${combinedPosts.length} results, sprkNextCursor: ${sprkResponse.cursor}, bskyNextCursor: ${bskyResponse.data.cursor}',
      );

      // If we have very few results, try to load more immediately
      if (state.searchResults.length < 10 && (state.sprkNextCursor != null || state.bskyNextCursor != null)) {
        await loadMorePosts();
      }
    } catch (e) {
      _logger.e('Error searching posts: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Load more posts using the next cursor if available
  Future<void> loadMorePosts() async {
    if (state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      await _loadMorePostsRecursive();
    } catch (e) {
      _logger.e('Error loading more posts: $e');
      state = state.copyWith(error: e.toString(), isLoadingMore: false);
    } finally {
      if (state.isLoadingMore) {
        state = state.copyWith(isLoadingMore: false);
      }
    }
  }

  Future<void> _loadMorePostsRecursive() async {
    final sprkCursor = state.sprkNextCursor;
    if (sprkCursor != null && sprkCursor.isNotEmpty) {
      final response = await _feedRepository.searchPosts(state.query, cursor: sprkCursor);
      state = state.copyWith(
        searchResults: [...state.searchResults, ...response.posts],
        sprkNextCursor: response.cursor,
      );

      // If sprk is exhausted now and we have a bsky cursor, fetch from bsky.
      if ((response.cursor == null || response.cursor!.isEmpty) &&
          (state.bskyNextCursor != null && state.bskyNextCursor!.isNotEmpty)) {
        await _loadMorePostsRecursive();
      }
      return;
    }

    final bskyCursor = state.bskyNextCursor;
    if (bskyCursor != null && bskyCursor.isNotEmpty) {
      final bskySession = _authRepository.session;
      if (bskySession == null) {
        return;
      }
      final bskyApi = bsky.Bluesky.fromSession(bskySession);
      final response = await bskyApi.feed.searchPosts(state.query, sort: 'latest', cursor: bskyCursor);

      final bskyPosts = response.data.posts
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final post = entry.value;

            try {
              final postJson = post.toJson();
              if (postJson['record']['reply'] != null || post.embed == null) {
                return null;
              }
              return PostView.fromJson(postJson);
            } catch (e, stackTrace) {
              final postJson = post.toJson();
              _logger.e('Failed to convert bsky post ${index + 1}/${response.data.posts.length}');
              _logger.e('Post URI: ${post.uri}');
              _logger.e('Post JSON: $postJson');
              _logger.e('Error: $e');
              _logger.e('Stack trace: $stackTrace');
              return null;
            }
          })
          .where((post) => post != null && post.hasSupportedMedia)
          .cast<PostView>()
          .toList();

      final initialCount = state.searchResults.length;
      state = state.copyWith(
        searchResults: [...state.searchResults, ...bskyPosts],
        bskyNextCursor: response.data.cursor,
      );

      // If we still have few results and a cursor, and we actually added new posts, recurse.
      if (state.searchResults.length < 10 &&
          (state.bskyNextCursor != null && state.bskyNextCursor!.isNotEmpty) &&
          state.searchResults.length > initialCount) {
        await _loadMorePostsRecursive();
      }
    }
  }
}
