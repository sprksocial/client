import 'dart:async';

import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/search/providers/search_state.dart';

part 'search_provider.g.dart';

/// Search provider for user search functionality
@riverpod
class Search extends _$Search {
  Timer? _debounce;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'SearchProvider',
  );
  final ActorRepository _actorRepository = GetIt.instance<ActorRepository>();
  final AuthRepository _authRepository = GetIt.instance<AuthRepository>();
  final GraphRepository _graphRepository = GetIt.instance<GraphRepository>();

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    return SearchState.initial();
  }

  /// Update the search query and trigger search with debounce
  void updateQuery(String query) {
    // Update query and reset pagination state
    state = state.copyWith(
      query: query,
      searchResults: [],
      nextCursor: null,
      error: null,
    );

    if (query.isEmpty) {
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
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(query);
    });
  }

  /// Search for users with the given query
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final actorRepo = _actorRepository;
      final response = await actorRepo.searchActors(query);

      state = state.copyWith(
        searchResults: response.actors,
        nextCursor: response.cursor,
        isLoading: false,
        isLoadingMore: false,
      );

      _logger.d(
        'Search completed with ${response.actors.length} results, '
        'nextCursor: ${response.cursor}',
      );
    } catch (e) {
      _logger.e('Failed to search users', error: e);
      state = state.copyWith(error: 'Failed to search users', isLoading: false);
    }
  }

  /// Load more users using the next cursor if available
  Future<void> loadMoreUsers() async {
    final nextCursor = state.nextCursor;
    if (nextCursor == null || nextCursor.isEmpty || state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _actorRepository.searchActors(
        state.query,
        cursor: nextCursor,
      );

      state = state.copyWith(
        searchResults: [...state.searchResults, ...response.actors],
        nextCursor: response.cursor,
        isLoadingMore: false,
      );

      _logger.d(
        'Loaded more users: +${response.actors.length}, '
        'nextCursor: ${response.cursor}',
      );
    } catch (e) {
      _logger.e('Failed to load more users', error: e);
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Handle following a user
  Future<void> followUser(String userDid) async {
    try {
      final authRepo = _authRepository;
      if (!authRepo.isAuthenticated) {
        _logger.w('User not authenticated, cannot follow');
        return;
      }

      final graphRepo = _graphRepository;
      final response = await graphRepo.followUser(userDid);

      // Update the user in the search results with the follow URI
      final updatedResults = [...state.searchResults];
      final userIndex = updatedResults.indexWhere(
        (user) => user.did == userDid,
      );

      if (userIndex != -1) {
        final user = updatedResults[userIndex];

        final updatedUser = user.copyWith(
          viewer: ActorViewer(following: AtUri.parse(response.uri)),
        );

        updatedResults[userIndex] = updatedUser;
        state = state.copyWith(searchResults: updatedResults);
      }

      _logger.i('Successfully followed user: $userDid');
    } catch (e) {
      _logger.e('Failed to follow user', error: e);
    }
  }

  /// Handle unfollowing a user
  Future<void> unfollowUser(String userDid, AtUri followUri) async {
    try {
      final authRepo = _authRepository;
      if (!authRepo.isAuthenticated) {
        _logger.w('User not authenticated, cannot unfollow');
        return;
      }

      final graphRepo = _graphRepository;
      await graphRepo.unfollowUser(followUri);

      // Update the user in the search results to remove the follow URI
      final updatedResults = [...state.searchResults];
      final userIndex = updatedResults.indexWhere(
        (user) => user.did == userDid,
      );

      if (userIndex != -1) {
        final user = updatedResults[userIndex];

        final updatedUser = user.copyWith(viewer: const ActorViewer());

        updatedResults[userIndex] = updatedUser;
        state = state.copyWith(searchResults: updatedResults);
      }

      _logger.i('Successfully unfollowed user: $userDid');
    } catch (e) {
      _logger.e('Failed to unfollow user', error: e);
    }
  }

  bool isCurrentUser(String did) {
    final authRepo = _authRepository;
    if (!authRepo.isAuthenticated) {
      _logger.w('User not authenticated, cannot check if current user');
      return false;
    }
    final currentDid = authRepo.did;
    return did == currentDid;
  }
}
