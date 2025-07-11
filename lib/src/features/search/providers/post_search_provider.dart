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
      final bskySession = _authRepository.session;
      if (bskySession == null) {
        // Handle case where user is not logged in, or only search sprk
        final response = await _feedRepository.searchPosts(query);
        state = state.copyWith(
          searchResults: response.posts,
          nextCursor: response.cursor,
          isLoading: false,
        );
        return;
      }

      final bskyApi = bsky.Bluesky.fromSession(bskySession);
      final sprkSearch = _feedRepository.searchPosts(query);
      final bskySearch = bskyApi.feed.searchPosts(query, sort: 'latest');

      final results = await Future.wait([sprkSearch, bskySearch]);

      final sprkResponse = results[0] as ({String? cursor, List<PostView> posts});
      final bskyResponse = results[1] as XRPCResponse<bsky.PostsByQuery>;

      final bskyPosts = <PostView>[];
      for (var i = 0; i < bskyResponse.data.posts.length; i++) {
        try {
          final post = bskyResponse.data.posts[i];
          final postJson = post.toJson();
          if (postJson['record']['reply'] != null || post.embed == null) {
            _logger.d('Skipping reply or no embed post ${i + 1}/${bskyResponse.data.posts.length}: ${post.uri}');
            continue;
          }

          _logger.d('Converting bsky post ${i + 1}/${bskyResponse.data.posts.length}: $postJson');

          final postView = PostView.fromJson(postJson);
          bskyPosts.add(postView);
          _logger.d('Successfully converted bsky post ${i + 1}: ${post.uri}');
        } catch (e, stackTrace) {
          final post = bskyResponse.data.posts[i];
          final postJson = post.toJson();
          _logger.e('Failed to convert bsky post ${i + 1}/${bskyResponse.data.posts.length}');
          _logger.e('Post URI: ${post.uri}');
          _logger.e('Post JSON: $postJson');
          _logger.e('Error: $e');
          _logger.e('Stack trace: $stackTrace');
          // Continue processing other posts instead of failing completely
        }
      }

      bskyPosts.removeWhere((post) => post.hasSupportedMedia == false);
      _logger.d('Successfully converted ${bskyPosts.length}/${bskyResponse.data.posts.length} bsky posts');

      final combinedPosts = [...sprkResponse.posts, ...bskyPosts];
      //combinedPosts.shuffle();

      state = state.copyWith(
        searchResults: combinedPosts,
        nextCursor: sprkResponse.cursor, // TODO: Handle bsky cursor
        isLoading: false,
      );
      _logger.d('Search completed with ${combinedPosts.length} results, nextCursor: ${sprkResponse.cursor}');
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
      // TODO: Handle pagination for both bsky and sprk
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
