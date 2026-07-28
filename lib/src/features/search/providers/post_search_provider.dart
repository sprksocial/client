import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/providers/debounce_scheduler.dart';
import 'package:spark/src/core/utils/label_utils.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/search/data/repositories/post_search_repository.dart';
import 'package:spark/src/features/search/providers/post_search_state.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';

part 'post_search_provider.g.dart';

final postSearchRepositoryProvider = Provider<PostSearchRepository>((ref) {
  return PostSearchRepositoryImpl(
    GetIt.instance<SprkRepository>().feed,
    GetIt.instance<AuthRepository>(),
    GetIt.instance<LogService>().getLogger('PostSearchRepository'),
  );
});

final postSearchPreferencesProvider = Provider<Preferences?>((ref) {
  return ref.watch(userPreferencesProvider).asData?.value;
});

/// Search provider for post search functionality
@riverpod
class PostSearch extends _$PostSearch {
  void Function()? _cancelDebounce;
  int _activeSearchToken = 0;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'PostSearchProvider',
  );
  late final PostSearchRepository _repository;

  @override
  PostSearchState build() {
    _repository = ref.read(postSearchRepositoryProvider);
    ref.onDispose(() {
      _cancelDebounce?.call();
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
    _cancelDebounce?.call();
    final requestToken = ++_activeSearchToken;
    _cancelDebounce = ref.read(debounceSchedulerProvider)(
      const Duration(milliseconds: 500),
      () => _searchPosts(trimmedQuery, requestToken: requestToken),
    );
  }

  /// Submit the search query and run search immediately.
  Future<void> submitQuery(String query) async {
    final trimmedQuery = query.trim();

    _cancelDebounce?.call();

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
      final response = await _repository.search(query);

      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      final filteredSprkPosts = _filterHiddenPosts(response.sprk.posts);
      final filteredBskyPosts = _filterHiddenPosts(response.bsky.posts);

      final combinedPosts = [...filteredSprkPosts, ...filteredBskyPosts];

      state = state.copyWith(
        searchResults: combinedPosts,
        sprkNextCursor: response.sprk.cursor,
        bskyNextCursor: response.bsky.cursor,
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
      final response = await _repository.searchSprk(query, cursor: sprkCursor);

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
      final response = await _repository.searchBsky(query, cursor: bskyCursor);

      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      final initialCount = state.searchResults.length;
      final filteredBskyPosts = _filterHiddenPosts(response.posts);
      state = state.copyWith(
        searchResults: [...state.searchResults, ...filteredBskyPosts],
        bskyNextCursor: response.cursor,
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
    final preferences = ref.read(postSearchPreferencesProvider);
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
