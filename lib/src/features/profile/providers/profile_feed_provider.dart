import 'dart:collection';

import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_state.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

part 'profile_feed_provider.g.dart';

typedef _FeedSourceFetcher = Future<({List<FeedViewPost> posts, String? cursor})> Function(String? cursor);

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

    try {
      final result = await _loadUnifiedFeed(
        profileUri: profileUri,
        sparkCursor: null,
        blueskyCursor: null,
        videosOnly: videosOnly,
      );
      _logger.d(
        'Loaded initial unified feed: ${result.allPosts.length} total posts, ${result.loadedPosts.length} filtered posts',
      );
      return result;
    } catch (e) {
      _logger.e('Error loading initial posts: $e');
      rethrow;
    }
  }

  Future<ProfileFeedState> _loadUnifiedFeed({
    required AtUri profileUri,
    required String? sparkCursor,
    required String? blueskyCursor,
    required bool videosOnly,
    ProfileFeedState? currentState,
  }) async {
    final postSources = Map<AtUri, String>.from(currentState?.postSources ?? {});
    final postTypes = Map<AtUri, bool>.from(currentState?.postTypes ?? {});
    final postViews = Map<AtUri, PostView>.from(currentState?.postViews ?? {});
    final allPosts = List<AtUri>.from(currentState?.allPosts ?? []);

    final sparkRkeys = allPosts.where((uri) => postSources[uri] == 'sprk').map((uri) => uri.rkey).toSet();

    final newPosts = <PostView>[];

    final sparkResult = await _fetchFromSource(
      (cursor) => _feedRepository.getAuthorFeed(profileUri, limit: ProfileFeedState.fetchLimit, cursor: cursor, bluesky: false),
      sparkCursor,
      'Sprk',
    );

    for (final feedViewPost in sparkResult.posts) {
      final uri = feedViewPost.post.uri;
      if (!postViews.containsKey(uri)) {
        newPosts.add(feedViewPost.post);
        postSources[uri] = 'sprk';
        postTypes[uri] = feedViewPost.post.videoUrl.isNotEmpty;
        postViews[uri] = feedViewPost.post;
        sparkRkeys.add(uri.rkey);
      }
    }

    final bskyResult = await _fetchFromSource(
      (cursor) => _feedRepository.getAuthorFeed(profileUri, limit: ProfileFeedState.fetchLimit, cursor: cursor, bluesky: true),
      blueskyCursor,
      'Bsky',
    );

    for (final feedViewPost in bskyResult.posts) {
      final uri = feedViewPost.post.uri;
      if (sparkRkeys.contains(uri.rkey) || postViews.containsKey(uri)) {
        _logger.d('Skipping Bsky post with rkey ${uri.rkey} - already exists.');
        continue;
      }
      newPosts.add(feedViewPost.post);
      postSources[uri] = 'bsky';
      postTypes[uri] = _isEmbedVideo(feedViewPost.post.embed);
      postViews[uri] = feedViewPost.post;
    }

    newPosts.sort((a, b) => b.indexedAt.compareTo(a.indexedAt));
    allPosts.addAll(newPosts.map((post) => post.uri));

    final filteredPosts = videosOnly
        ? allPosts.where((uri) => postTypes[uri] == true).toList()
        : allPosts.where((uri) => postTypes[uri] == false).toList();

    final isEndOfNetwork =
        (sparkResult.cursor == null && bskyResult.cursor == null) ||
        (currentState != null && currentState.loadedPosts.length == filteredPosts.length);

    return ProfileFeedState(
      loadedPosts: filteredPosts,
      allPosts: allPosts,
      isEndOfNetwork: isEndOfNetwork,
      cursor: sparkResult.cursor,
      blueskyCursor: bskyResult.cursor,
      // ignore: prefer_collection_literals
      extraInfo: currentState?.extraInfo ?? LinkedHashMap(),
      postSources: postSources,
      postTypes: postTypes,
      postViews: postViews,
    );
  }

  Future<({List<FeedViewPost> posts, String? cursor})> _fetchFromSource(
    _FeedSourceFetcher fetcher,
    String? cursor,
    String sourceName,
  ) async {
    try {
      final result = await fetcher(cursor);
      _logger.d('Loaded ${result.posts.length} posts from $sourceName');
      return result;
    } catch (e) {
      _logger.w('Failed to load from $sourceName: $e');
      return (posts: <FeedViewPost>[], cursor: cursor);
    }
  }

  bool _isEmbedVideo(EmbedView? embed) {
    if (embed == null) return false;
    return embed.when(
      video: (cid, playlist, thumbnail, alt) => true,
      bskyVideo: (cid, playlist, thumbnail, alt) => true,
      bskyRecordWithMedia: (record, media, cid) => _isEmbedVideo(media),
      image: (images) => false,
      bskyImages: (images) => false,
      bskyRecord: (record, cid) => false,
      bskyExternal: (external, cid) => false,
    );
  }

  Future<void> loadMore() async {
    if (_isLoading || state.value?.isEndOfNetwork == true) return;

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

      final newPostUris = result.allPosts.where((uri) => !currentState.allPosts.contains(uri)).toList();
      if (newPostUris.isNotEmpty) {
        final postViewsToCache = newPostUris.map((uri) => result.postViews[uri]!).toList();
        await _sqlCache.cachePosts(postViewsToCache);
      }

      _logger.d('Loaded more posts: ${result.allPosts.length - currentState.allPosts.length} new posts');
    } catch (e) {
      _logger.e('Error loading more posts: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
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
}
