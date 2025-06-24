import 'dart:collection';

import 'package:atproto/atproto.dart';
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

    // Load initial data from both sources
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

  /// Load unified feed from both Spark and Bluesky
  Future<ProfileFeedState> _loadUnifiedFeed({
    required AtUri profileUri,
    required String? sparkCursor,
    required String? blueskyCursor,
    required bool videosOnly,
    ProfileFeedState? currentState,
  }) async {
    final Map<AtUri, String> postSources = Map.from(currentState?.postSources ?? <AtUri, String>{});
    final Map<AtUri, bool> postTypes = Map.from(currentState?.postTypes ?? <AtUri, bool>{});
    final List<AtUri> allPosts = List.from(currentState?.allPosts ?? <AtUri>[]);
    final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})>.from(
      currentState?.extraInfo ?? {},
    );

    // Track rkeys from Spark posts to deduplicate against Bluesky
    final Set<String> sparkRkeys = <String>{};

    // Add existing Spark rkeys to our tracking set
    for (final uri in allPosts) {
      if (postSources[uri] == 'spark') {
        sparkRkeys.add(uri.rkey);
      }
    }

    String? newSparkCursor = sparkCursor;
    String? newBlueskyCursor = blueskyCursor;

    // Fetch from Spark first to establish the canonical posts
    try {
      final sparkResult = await _feedRepository.getAuthorFeed(
        profileUri,
        limit: ProfileFeedState.fetchLimit,
        cursor: sparkCursor,
        videosOnly: false, // Always fetch all posts, filter later
        bluesky: false, // Explicitly fetch from Spark
      );

      for (final feedViewPost in sparkResult.posts) {
        final uri = feedViewPost.post.uri;
        if (!allPosts.contains(uri)) {
          allPosts.add(uri);
          postSources[uri] = 'spark';
          postTypes[uri] = feedViewPost.post.videoUrl.isNotEmpty;
          sparkRkeys.add(uri.rkey); // Track this Spark rkey
        }
      }

      newSparkCursor = sparkResult.cursor;
      _logger.d('Loaded ${sparkResult.posts.length} posts from Spark');
    } catch (e) {
      _logger.w('Failed to load from Spark: $e');
    }

    // Fetch from Bluesky and deduplicate against Spark rkeys
    try {
      final bskyResult = await _feedRepository.getAuthorFeed(
        profileUri,
        limit: ProfileFeedState.fetchLimit,
        cursor: blueskyCursor,
        videosOnly: false, // Always fetch all posts, filter later
        bluesky: true, // Explicitly fetch from Bluesky
      );

      for (final feedViewPost in bskyResult.posts) {
        final uri = feedViewPost.post.uri;
        final rkey = uri.rkey;

        // Skip if we already have this post from Spark (same rkey) or exact URI
        if (sparkRkeys.contains(rkey) || allPosts.contains(uri)) {
          _logger.d('Skipping Bluesky post with rkey $rkey - already exists from Spark');
          continue;
        }

        allPosts.add(uri);
        postSources[uri] = 'bluesky';
        // Determine if it's a video post based on embed type
        final hasVideo =
            feedViewPost.post.embed?.when(
              video: (cid, playlist, thumbnail, alt) => true,
              image: (images) => false,
              bskyVideo: (cid, playlist, thumbnail, alt) => true,
              bskyImages: (images) => false,
              bskyRecord: (record, cid) => false,
              bskyRecordWithMedia: (record, media, cid) => _isEmbedVideo(media),
              bskyExternal: (external, cid) => false,
            ) ??
            false;
        postTypes[uri] = hasVideo;
      }

      newBlueskyCursor = bskyResult.cursor;
      _logger.d('Loaded ${bskyResult.posts.length} posts from Bluesky (after deduplication)');
    } catch (e) {
      _logger.w('Failed to load from Bluesky: $e');
    }

    // Filter posts based on videosOnly parameter
    final List<AtUri> filteredPosts = videosOnly
        ? allPosts.where((uri) => postTypes[uri] == true).toList()
        : allPosts.where((uri) => postTypes[uri] == false).toList();

    final isEndOfNetwork =
        (newSparkCursor == null && newBlueskyCursor == null) || (currentState?.loadedPosts.length == filteredPosts.length);

    return ProfileFeedState(
      loadedPosts: filteredPosts,
      allPosts: allPosts,
      isEndOfNetwork: isEndOfNetwork,
      cursor: newSparkCursor,
      blueskyCursor: newBlueskyCursor,
      extraInfo: extraInfo,
      postSources: postSources,
      postTypes: postTypes,
    );
  }

  /// Helper method to determine if an embed contains video
  bool _isEmbedVideo(EmbedView embed) {
    return embed.when(
      video: (cid, playlist, thumbnail, alt) => true,
      image: (images) => false,
      bskyVideo: (cid, playlist, thumbnail, alt) => true,
      bskyImages: (images) => false,
      bskyRecord: (record, cid) => false,
      bskyRecordWithMedia: (record, media, cid) => _isEmbedVideo(media),
      bskyExternal: (external, cid) => false,
    );
  }

  /// Load more posts for the profile
  Future<void> loadMore() async {
    if (_isLoading || state.value?.isEndOfNetwork == true) return;

    _isLoading = true;
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await _loadUnifiedFeed(
        profileUri: profileUri,
        sparkCursor: currentState.cursor,
        blueskyCursor: currentState.blueskyCursor,
        videosOnly: videosOnly,
        currentState: currentState,
      );

      state = AsyncValue.data(result);

      // Cache the new posts
      final newPostUris = result.allPosts.where((uri) => !currentState.allPosts.contains(uri)).toList();
      if (newPostUris.isNotEmpty) {
        final newPostViews = await _fetchPostViews(newPostUris);
        await _sqlCache.cachePosts(newPostViews);
      }

      _logger.d('Loaded more posts: ${result.allPosts.length - currentState.allPosts.length} new posts');
    } catch (e) {
      _logger.e('Error loading more posts: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  /// Helper method to fetch PostView objects for caching
  Future<List<PostView>> _fetchPostViews(List<AtUri> uris) async {
    final List<PostView> posts = [];

    // Split by source for efficient fetching
    final sparkUris = uris.where((uri) => state.value?.postSources[uri] == 'spark').toList();
    final bskyUris = uris.where((uri) => state.value?.postSources[uri] == 'bluesky').toList();

    if (sparkUris.isNotEmpty) {
      try {
        final sparkPosts = await _feedRepository.getPosts(sparkUris, bluesky: false);
        posts.addAll(sparkPosts);
      } catch (e) {
        _logger.w('Failed to fetch Spark posts for caching: $e');
      }
    }

    if (bskyUris.isNotEmpty) {
      try {
        final bskyPosts = await _feedRepository.getPosts(bskyUris, bluesky: true);
        posts.addAll(bskyPosts);
      } catch (e) {
        _logger.w('Failed to fetch Bluesky posts for caching: $e');
      }
    }

    return posts;
  }

  /// Refresh the profile feed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final freshState = ProfileFeedState(
      loadedPosts: [],
      allPosts: [],
      isEndOfNetwork: false,
      cursor: null,
      blueskyCursor: null,
      extraInfo: LinkedHashMap(),
      postSources: {},
      postTypes: {},
    );
    state = AsyncValue.data(freshState);
    await loadMore();
  }
}
