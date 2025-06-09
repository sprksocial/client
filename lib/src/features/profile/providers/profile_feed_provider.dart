import 'dart:collection';

import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_state.dart';

part 'profile_feed_provider.g.dart';

@riverpod
class ProfileFeed extends _$ProfileFeed {
  late final FeedRepository _feedRepository;
  late final SQLCacheInterface _sqlCache;
  late final SparkLogger _logger;
  bool _isLoading = false;

  @override
  Future<ProfileFeedState> build(AtUri profileUri, bool videosOnly) async {
    _feedRepository = GetIt.instance<SprkRepository>().feed;
    _sqlCache = GetIt.instance<SQLCacheInterface>();
    _logger = GetIt.instance<LogService>().getLogger('ProfileFeed ${profileUri.toString()}');

    // Load initial data instead of returning empty state
    try {
      final result = await _feedRepository.getAuthorFeed(
        profileUri,
        limit: ProfileFeedState.fetchLimit,
        cursor: null,
        videosOnly: videosOnly,
      );

      if (!videosOnly) {
        result.posts.removeWhere((post) => post.post.videoUrl.isNotEmpty);
      }
      final posts = result.posts.map((feedViewPost) => feedViewPost.post.uri).toList();
      
      _logger.d('Loaded initial ${result.posts.length} posts for profile ${profileUri.toString()}, videosOnly: $videosOnly');
      
      return ProfileFeedState(
        loadedPosts: posts,
        isEndOfNetwork: result.posts.length < ProfileFeedState.fetchLimit,
        cursor: result.cursor,
        extraInfo: LinkedHashMap(),
      );
    } catch (e) {
      _logger.e('Error loading initial posts: $e');
      // Rethrow the error so the provider enters error state
      rethrow;
    }
  }

  /// Load more posts for the profile
  Future<void> loadMore() async {
    if (_isLoading || state.value?.isEndOfNetwork == true) return;
    
    _isLoading = true;
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await _feedRepository.getAuthorFeed(
        profileUri,
        limit: ProfileFeedState.fetchLimit,
        cursor: currentState.cursor,
        videosOnly: videosOnly,
      );

      final newPosts = result.posts.map((feedViewPost) => feedViewPost.post.uri).toList();
      final allPosts = [...currentState.loadedPosts, ...newPosts];
      
      state = AsyncValue.data(currentState.copyWith(
        loadedPosts: allPosts,
        cursor: result.cursor,
        isEndOfNetwork: result.posts.length < ProfileFeedState.fetchLimit,
      ));

      // Cache the posts
      final postViews = result.posts.map((post) => post.post).toList();
      await _sqlCache.cachePosts(postViews);
      
      _logger.d('Loaded ${result.posts.length} posts for profile ${profileUri.toString()}, videosOnly: $videosOnly');
    } catch (e) {
      _logger.e('Error loading more posts: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  /// Refresh the profile feed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final freshState = ProfileFeedState(
      loadedPosts: [],
      isEndOfNetwork: false,
      cursor: null,
      extraInfo: LinkedHashMap(),
    );
    state = AsyncValue.data(freshState);
    await loadMore();
  }
}