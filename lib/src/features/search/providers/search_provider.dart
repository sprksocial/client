import 'package:poptart/poptart.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/search/providers/search_state.dart';
import 'package:spark/src/features/search/providers/search_debounce_scheduler.dart';

part 'search_provider.g.dart';

/// Search provider for user search functionality
@riverpod
class Search extends _$Search {
  void Function()? _cancelDebounce;
  int _activeSearchToken = 0;
  final Set<String> _pendingFollows = {};
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'SearchProvider',
  );
  final ActorRepository _actorRepository = GetIt.instance<ActorRepository>();
  final AuthRepository _authRepository = GetIt.instance<AuthRepository>();
  final GraphRepository _graphRepository = GetIt.instance<GraphRepository>();

  @override
  SearchState build() {
    ref.onDispose(() {
      _cancelDebounce?.call();
    });

    return SearchState.initial();
  }

  /// Update the search query and trigger search with debounce
  void updateQuery(String query) {
    final trimmedQuery = query.trim();

    // Update query and reset pagination state
    state = state.copyWith(
      query: trimmedQuery,
      searchResults: [],
      nextCursor: null,
      isLoadingMore: false,
      error: null,
    );

    if (trimmedQuery.isEmpty) {
      _activeSearchToken++;
      state = state.copyWith(
        searchResults: [],
        error: null,
        isLoading: false,
        isLoadingMore: false,
        nextCursor: null,
      );
      return;
    }

    // Debounce the search
    _cancelDebounce?.call();
    final requestToken = ++_activeSearchToken;
    _cancelDebounce = ref.read(searchDebounceSchedulerProvider)(
      const Duration(milliseconds: 500),
      () => _searchUsers(trimmedQuery, requestToken: requestToken),
    );
  }

  /// Submit the search query and run search immediately.
  Future<void> submitQuery(String query) async {
    final trimmedQuery = query.trim();

    _cancelDebounce?.call();

    state = state.copyWith(
      query: trimmedQuery,
      searchResults: [],
      nextCursor: null,
      isLoadingMore: false,
      error: null,
    );

    if (trimmedQuery.isEmpty) {
      _activeSearchToken++;
      state = state.copyWith(
        searchResults: [],
        error: null,
        isLoading: false,
        isLoadingMore: false,
        nextCursor: null,
      );
      return;
    }

    final requestToken = ++_activeSearchToken;
    await _searchUsers(trimmedQuery, requestToken: requestToken);
  }

  /// Search for users with the given query
  Future<void> _searchUsers(String query, {required int requestToken}) async {
    if (query.isEmpty) return;
    if (requestToken != _activeSearchToken || state.query != query) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final actorRepo = _actorRepository;
      final response = await actorRepo.searchActors(query);

      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      state = state.copyWith(
        searchResults: response.actors,
        nextCursor: response.cursor,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      _logger.e('Failed to search users', error: e);
      state = state.copyWith(error: 'Failed to search users', isLoading: false);
    }
  }

  /// Load more users using the next cursor if available
  Future<void> loadMoreUsers() async {
    final query = state.query;
    final requestToken = _activeSearchToken;
    final nextCursor = state.nextCursor;
    if (nextCursor == null || nextCursor.isEmpty || state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _actorRepository.searchActors(
        query,
        cursor: nextCursor,
      );

      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      state = state.copyWith(
        searchResults: [...state.searchResults, ...response.actors],
        nextCursor: response.cursor,
        isLoadingMore: false,
      );
    } catch (e) {
      if (!ref.mounted ||
          requestToken != _activeSearchToken ||
          state.query != query) {
        return;
      }

      _logger.e('Failed to load more users', error: e);
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Handle following a user
  Future<void> followUser(String userDid) async {
    final authRepo = _authRepository;
    if (!authRepo.isAuthenticated || !_pendingFollows.add(userDid)) return;

    try {
      final response = await _graphRepository.followUser(userDid);

      if (!ref.mounted) return;
      final current = state.searchResults
          .where((user) => user.did == userDid)
          .firstOrNull;
      if (current != null && current.viewer?.following == null) {
        _replaceUser(
          current.copyWith(viewer: ViewerState(following: response.uri)),
        );
      }
    } catch (e) {
      _logger.e('Failed to follow user', error: e);
    } finally {
      _pendingFollows.remove(userDid);
    }
  }

  /// Handle unfollowing a user
  Future<void> unfollowUser(String userDid, AtUri followUri) async {
    final authRepo = _authRepository;
    if (!authRepo.isAuthenticated) return;

    final userIndex = state.searchResults.indexWhere(
      (user) => user.did == userDid,
    );
    final originalUser = userIndex == -1
        ? null
        : state.searchResults[userIndex];
    if (originalUser != null) {
      _replaceUser(originalUser.copyWith(viewer: const ViewerState()));
    }

    try {
      await _graphRepository.unfollowUser(followUri);
    } catch (e) {
      _logger.e('Failed to unfollow user', error: e);
      if (ref.mounted && originalUser != null) {
        final current = state.searchResults
            .where((user) => user.did == userDid)
            .firstOrNull;
        if (current?.viewer?.following == null) {
          _replaceUser(originalUser);
        }
      }
    }
  }

  void _replaceUser(ProfileView updatedUser) {
    final updatedResults = [...state.searchResults];
    final index = updatedResults.indexWhere(
      (user) => user.did == updatedUser.did,
    );
    if (index == -1) return;
    updatedResults[index] = updatedUser;
    state = state.copyWith(searchResults: updatedResults);
  }

  bool isCurrentUser(String did) {
    final authRepo = _authRepository;
    if (!authRepo.isAuthenticated) {
      return false;
    }
    final currentDid = authRepo.did;
    return did == currentDid;
  }
}
