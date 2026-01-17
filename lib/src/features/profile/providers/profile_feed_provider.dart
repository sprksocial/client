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

part 'profile_feed_provider.g.dart';

@riverpod
class ProfileFeed extends _$ProfileFeed {
  final FeedRepository _feedRepository = GetIt.instance<SprkRepository>().feed;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'ProfileFeed',
  );
  bool _isLoading = false;

  @override
  Future<ProfileFeedState> build(AtUri profileUri, bool videosOnly) async {
    try {
      final result = await _loadUnifiedFeed(
        profileUri: profileUri,
        sparkCursor: null,
        blueskyCursor: null,
        videosOnly: videosOnly,
      );
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading initial posts: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Load author feed from Spark first, falling back to Bluesky if Spark fails.
  /// This mirrors the profile loading behavior where we only show one source.
  Future<ProfileFeedState> _loadUnifiedFeed({
    required AtUri profileUri,
    required String? sparkCursor,
    required String? blueskyCursor,
    required bool videosOnly,
    ProfileFeedState? currentState,
  }) async {
    final postSources = Map<AtUri, String>.from(
      currentState?.postSources ?? {},
    );
    final postTypes = Map<AtUri, bool>.from(currentState?.postTypes ?? {});
    final postViews = Map<AtUri, PostView>.from(currentState?.postViews ?? {});
    final allPosts = List<AtUri>.from(currentState?.allPosts ?? []);

    final newPosts = <PostView>[];

    // Fetch from Spark API (internally falls back to Bluesky if Spark fails)
    // This mirrors profile loading behavior
    final result = await _fetchFromSource(
      (cursor) => _feedRepository.getAuthorFeed(
        profileUri,
        limit: ProfileFeedState.fetchLimit,
        cursor: cursor,
      ),
      sparkCursor,
      'AuthorFeed',
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
    // 2. API returns fewer posts than requested (last page)
    // 3. No new posts were added (duplicates or empty response)
    final isEndOfNetwork =
        result.cursor == null ||
        result.posts.length < ProfileFeedState.fetchLimit ||
        (currentState != null &&
            currentState.allPosts.length == allPosts.length);

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
      final result = await _loadUnifiedFeed(
        profileUri: profileUri,
        sparkCursor: currentState.cursor,
        blueskyCursor: currentState.blueskyCursor,
        videosOnly: videosOnly,
        currentState: currentState,
      );

      state = AsyncValue.data(result);
    } catch (e) {
      _logger.e('Error loading more posts: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    try {
      final result = await _loadUnifiedFeed(
        profileUri: profileUri,
        sparkCursor: null,
        blueskyCursor: null,
        videosOnly: videosOnly,
      );
      state = AsyncValue.data(result);
    } catch (e) {
      _logger.e('Error refreshing posts: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deletePost(AtUri postUri) async {
    try {
      await GetIt.I<SprkRepository>().repo.deleteRecord(uri: postUri);
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
