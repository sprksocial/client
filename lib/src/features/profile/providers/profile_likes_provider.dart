import 'dart:collection';

import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/profile/providers/profile_feed_state.dart';

part 'profile_likes_provider.g.dart';

@riverpod
class ProfileLikes extends _$ProfileLikes {
  final FeedRepository _feedRepository = GetIt.instance<SprkRepository>().feed;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'ProfileLikes',
  );
  bool _isLoading = false;
  late final String _actor;

  @override
  Future<ProfileFeedState> build(String actor, bool bsky) async {
    _actor = actor;
    try {
      final result = await _loadLikes(
        actor: actor,
        cursor: null,
      );
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading initial likes: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Load likes from specified API (Spark by default, Bluesky if bsky=true)
  Future<ProfileFeedState> _loadLikes({
    required String actor,
    required String? cursor,
    ProfileFeedState? currentState,
  }) async {
    final postSources = Map<AtUri, String>.from(
      currentState?.postSources ?? {},
    );
    final postTypes = Map<AtUri, bool>.from(currentState?.postTypes ?? {});
    final postViews = Map<AtUri, PostView>.from(currentState?.postViews ?? {});
    final allPosts = List<AtUri>.from(currentState?.allPosts ?? []);

    final newPosts = <PostView>[];

    // Fetch from the specified API (Spark by default, Bluesky if bsky=true)
    final result = await _fetchFromSource(
      (cursor) => _feedRepository.getActorLikes(
        actor,
        limit: ProfileFeedState.fetchLimit,
        cursor: cursor,
        bluesky: bsky,
      ),
      cursor,
      bsky ? 'BlueskyActorLikes' : 'SparkActorLikes',
    );

    for (final feedViewPost in result.posts) {
      final uri = feedViewPost.uri;
      if (!postViews.containsKey(uri)) {
        final postView = feedViewPost.asPost;
        if (postView != null) {
          newPosts.add(postView);
          // Determine source based on URI collection
          final isBlueskyPost = uri.collection.toString().startsWith(
            'app.bsky',
          );
          postSources[uri] = isBlueskyPost ? 'bsky' : 'sprk';
          postTypes[uri] = postView.videoUrl.isNotEmpty;
          postViews[uri] = postView;
        }
      }
    }

    newPosts.sort((a, b) => b.indexedAt.compareTo(a.indexedAt));
    allPosts.addAll(newPosts.map((post) => post.uri));

    // End of network when:
    // 1. API returns null cursor (no more pages)
    // 2. API returned posts but all were duplicates (prevents infinite loops)
    // Note: Don't check posts.isEmpty - empty page with cursor means more exist
    final isEndOfNetwork =
        result.cursor == null ||
        (result.posts.isNotEmpty && newPosts.isEmpty);

    return ProfileFeedState(
      loadedPosts: allPosts,
      allPosts: allPosts,
      isEndOfNetwork: isEndOfNetwork,
      cursor: result.cursor,
      // ignore: prefer_collection_literals
      extraInfo: currentState?.extraInfo ?? LinkedHashMap(),
      postSources: postSources,
      postTypes: postTypes,
      postViews: postViews,
    );
  }

  Future<({List<FeedViewPost> posts, String? cursor})> _fetchFromSource(
    Future<({List<FeedViewPost> posts, String? cursor})> Function(
      String? cursor,
    )
    fetcher,
    String? cursor,
    String sourceName,
  ) async {
    try {
      final result = await fetcher(cursor);
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to load from $sourceName: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return (posts: <FeedViewPost>[], cursor: cursor);
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || (state.value?.isEndOfNetwork ?? true)) return;

    _isLoading = true;
    final currentState = state.value;
    if (currentState == null) {
      _isLoading = false;
      return;
    }

    try {
      final result = await _loadLikes(
        actor: _actor,
        cursor: currentState.cursor,
        currentState: currentState,
      );

      state = AsyncValue.data(result);
    } catch (e) {
      _logger.e('Error loading more likes: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    try {
      final result = await _loadLikes(
        actor: _actor,
        cursor: null,
      );
      state = AsyncValue.data(result);
    } catch (e) {
      _logger.e('Error refreshing likes: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
