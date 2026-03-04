import 'dart:async';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_feed_searchposts.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/utils/label_utils.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/search/providers/post_search_state.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';

part 'post_search_provider.g.dart';

/// Search provider for post search functionality
@riverpod
class PostSearch extends _$PostSearch {
  Timer? _debounce;
  int _activeSearchToken = 0;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'PostSearchProvider',
  );
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
    final trimmedQuery = query.trim();

    // Update query and reset pagination state
    state = state.copyWith(
      query: trimmedQuery,
      searchResults: [],
      sprkNextCursor: null,
      bskyNextCursor: null,
      isLoadingMore: false,
      error: null,
    );

    if (trimmedQuery.isEmpty) {
      _activeSearchToken++;
      state = state.copyWith(isLoading: false);
      return;
    }

    // Set loading state immediately for non-empty queries
    state = state.copyWith(isLoading: true);

    // Debounce the search
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    final requestToken = ++_activeSearchToken;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPosts(trimmedQuery, requestToken: requestToken);
    });
  }

  /// Submit the search query and run search immediately.
  Future<void> submitQuery(String query) async {
    final trimmedQuery = query.trim();

    _debounce?.cancel();

    state = state.copyWith(
      query: trimmedQuery,
      searchResults: [],
      sprkNextCursor: null,
      bskyNextCursor: null,
      error: null,
      isLoadingMore: false,
    );

    if (trimmedQuery.isEmpty) {
      _activeSearchToken++;
      state = state.copyWith(isLoading: false);
      return;
    }

    final requestToken = ++_activeSearchToken;
    await _searchPosts(trimmedQuery, requestToken: requestToken);
  }

  /// Search for posts with the given query
  Future<void> _searchPosts(String query, {required int requestToken}) async {
    if (query.isEmpty) return;
    if (requestToken != _activeSearchToken || state.query != query) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final atproto = _authRepository.atproto;
      if (atproto == null || atproto.oAuthSession == null) {
        return;
      }

      final bskyApi = bsky.Bluesky.fromOAuthSession(atproto.oAuthSession!);
      final sprkSearch = _feedRepository.searchPosts(query);
      final bskySearch = bskyApi.feed.searchPosts(
        q: query,
        sort: const FeedSearchPostsSort.unknown(data: 'top'),
      );

      final results = await Future.wait([sprkSearch, bskySearch]);

      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      final sprkResponse =
          results[0] as ({String? cursor, List<PostView> posts});
      final bskyResponse = results[1] as XRPCResponse<FeedSearchPostsOutput>;

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
              _logger
                ..e(
                  'Failed to convert bsky post ${index + 1}/${bskyResponse.data.posts.length}',
                )
                ..e('Post URI: ${post.uri}')
                ..e('Post JSON: $postJson')
                ..e('Error: $e')
                ..e('Stack trace: $stackTrace');
              return null;
            }
          })
          .where((post) => post != null && post.hasSupportedMedia)
          .cast<PostView>()
          .toList();

      final filteredSprkPosts = _filterHiddenPosts(sprkResponse.posts);
      final filteredBskyPosts = _filterHiddenPosts(bskyPosts);

      final combinedPosts = [...filteredSprkPosts, ...filteredBskyPosts];

      state = state.copyWith(
        searchResults: combinedPosts,
        sprkNextCursor: sprkResponse.cursor,
        bskyNextCursor: bskyResponse.data.cursor,
        isLoading: false,
      );

      // If we have very few results, try to load more immediately
      if (state.searchResults.length < 10 &&
          (state.sprkNextCursor != null || state.bskyNextCursor != null)) {
        await _loadMorePostsForToken(requestToken);
      }
    } catch (e) {
      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      _logger.e('Error searching posts: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Load more posts using the next cursor if available
  Future<void> loadMorePosts() async {
    await _loadMorePostsForToken(_activeSearchToken);
  }

  Future<void> _loadMorePostsForToken(int requestToken) async {
    if (requestToken != _activeSearchToken) {
      return;
    }

    if (state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      await _loadMorePostsRecursive(requestToken);
    } catch (e) {
      if (!ref.mounted || requestToken != _activeSearchToken) {
        return;
      }

      _logger.e('Error loading more posts: $e');
      state = state.copyWith(error: e.toString(), isLoadingMore: false);
    } finally {
      if (ref.mounted &&
          requestToken == _activeSearchToken &&
          state.isLoadingMore) {
        state = state.copyWith(isLoadingMore: false);
      }
    }
  }

  Future<void> _loadMorePostsRecursive(int requestToken) async {
    final query = state.query;

    final sprkCursor = state.sprkNextCursor;
    if (sprkCursor != null && sprkCursor.isNotEmpty) {
      final response = await _feedRepository.searchPosts(
        query,
        cursor: sprkCursor,
      );

      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      final filteredPosts = _filterHiddenPosts(response.posts);
      state = state.copyWith(
        searchResults: [...state.searchResults, ...filteredPosts],
        sprkNextCursor: response.cursor,
      );

      // If sprk is exhausted now and we have a bsky cursor, fetch from bsky.
      if ((response.cursor == null || response.cursor!.isEmpty) &&
          (state.bskyNextCursor != null && state.bskyNextCursor!.isNotEmpty)) {
        await _loadMorePostsRecursive(requestToken);
      }
      return;
    }

    final bskyCursor = state.bskyNextCursor;
    if (bskyCursor != null && bskyCursor.isNotEmpty) {
      final atproto = _authRepository.atproto;
      if (atproto == null || atproto.oAuthSession == null) {
        return;
      }
      final bskyApi = bsky.Bluesky.fromOAuthSession(atproto.oAuthSession!);
      final response = await bskyApi.feed.searchPosts(
        q: query,
        sort: const FeedSearchPostsSort.unknown(data: 'latest'),
        cursor: bskyCursor,
      );

      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

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
              _logger
                ..e(
                  'Failed to convert bsky post ${index + 1}/${response.data.posts.length}',
                )
                ..e('Post URI: ${post.uri}')
                ..e('Post JSON: $postJson')
                ..e('Error: $e')
                ..e('Stack trace: $stackTrace');
              return null;
            }
          })
          .where((post) => post != null && post.hasSupportedMedia)
          .cast<PostView>()
          .toList();

      final initialCount = state.searchResults.length;
      final filteredBskyPosts = _filterHiddenPosts(bskyPosts);
      state = state.copyWith(
        searchResults: [...state.searchResults, ...filteredBskyPosts],
        bskyNextCursor: response.data.cursor,
      );

      // If we still have few results and a cursor, & added new posts, recurse
      if (state.searchResults.length < 10 &&
          (state.bskyNextCursor != null && state.bskyNextCursor!.isNotEmpty) &&
          state.searchResults.length > initialCount) {
        await _loadMorePostsRecursive(requestToken);
      }
    }
  }

  List<PostView> _filterHiddenPosts(List<PostView> posts) {
    final preferences = ref.read(userPreferencesProvider).asData?.value;
    if (preferences == null) {
      return posts; // Can't filter without preferences
    }

    final filteredPosts = <PostView>[];
    for (final post in posts) {
      if (!LabelUtils.shouldHideContent(preferences, post.labels ?? [])) {
        filteredPosts.add(post);
      }
    }

    return filteredPosts;
  }
}
