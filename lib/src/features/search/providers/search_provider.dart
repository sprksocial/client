import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/graph_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/features/search/providers/search_state.dart';

part 'search_provider.g.dart';

/// Search provider for user search functionality
@riverpod
class Search extends _$Search {
  Timer? _debounce;
  final _logger = GetIt.instance<LogService>().getLogger('SearchProvider');
  final _actorRepository = GetIt.instance<ActorRepository>();
  final _authRepository = GetIt.instance<AuthRepository>();
  final _graphRepository = GetIt.instance<GraphRepository>();

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    return SearchState.initial();
  }

  /// Update the search query and trigger search with debounce
  void updateQuery(String query) {
    state = state.copyWith(query: query);

    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], error: null, isLoading: false);
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

      state = state.copyWith(searchResults: response.actors, isLoading: false);

      _logger.d('Search completed with ${response.actors.length} results');
    } catch (e) {
      _logger.e('Failed to search users', error: e);
      state = state.copyWith(error: 'Failed to search users', isLoading: false);
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
      final userIndex = updatedResults.indexWhere((user) => user.did == userDid);

      if (userIndex != -1) {
        final user = updatedResults[userIndex];
        // Create a viewer map with following field if it doesn't exist
        final viewerMap = user.viewer ?? {};
        viewerMap['following'] = response.uri;

        // Create updated user with the new viewer map
        final updatedUser = user.copyWith(youFollow: true, viewer: viewerMap);

        updatedResults[userIndex] = updatedUser;
        state = state.copyWith(searchResults: updatedResults);
      }

      _logger.i('Successfully followed user: $userDid');
    } catch (e) {
      _logger.e('Failed to follow user', error: e);
    }
  }

  /// Handle unfollowing a user
  Future<void> unfollowUser(String userDid, String followUri) async {
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
      final userIndex = updatedResults.indexWhere((user) => user.did == userDid);

      if (userIndex != -1) {
        final user = updatedResults[userIndex];
        // Create a viewer map without following field
        final viewerMap = user.viewer ?? {};
        viewerMap.remove('following');

        // Create updated user with the updated viewer map
        final updatedUser = user.copyWith(youFollow: false, viewer: viewerMap);

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
    final currentDid = authRepo.session?.did;
    return did == currentDid;
  }
}
