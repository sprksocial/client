import 'dart:collection';

import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_state.dart';

part 'profile_feed_provider.g.dart';

@riverpod
class ProfileFeed extends _$ProfileFeed {
  final FeedRepository _feedRepository = GetIt.instance<SprkRepository>().feed;
  final SQLCacheInterface _sqlCache = GetIt.instance<SQLCacheInterface>();
  final SettingsRepository _settingsRepository = GetIt.instance<SettingsRepository>();
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('ProfileFeed');
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
      _logger.e('Error loading initial posts: $e', error: e, stackTrace: stackTrace);
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
      (cursor) => _feedRepository.getAuthorFeed(profileUri, limit: ProfileFeedState.fetchLimit, cursor: cursor),
      sparkCursor,
      'Sprk',
    );

    for (final feedViewPost in sparkResult.posts) {
      final uri = feedViewPost.uri;
      if (!postViews.containsKey(uri)) {
        final postView = feedViewPost.asPost;
        if (postView != null) {
          newPosts.add(postView);
          postSources[uri] = 'sprk';
          postTypes[uri] = postView.videoUrl.isNotEmpty;
          postViews[uri] = postView;
          sparkRkeys.add(uri.rkey);
        }
      }
    }

    final bskyResult = await _fetchFromSource(
      (cursor) => _feedRepository.getAuthorFeed(profileUri, limit: ProfileFeedState.fetchLimit, cursor: cursor, bluesky: true),
      blueskyCursor,
      'Bsky',
    );

    for (final feedViewPost in bskyResult.posts) {
      final uri = feedViewPost.uri;
      if (sparkRkeys.contains(uri.rkey) || postViews.containsKey(uri)) {
        continue;
      }
      final postView = feedViewPost.asPost;
      if (postView != null) {
        newPosts.add(postView);
        postSources[uri] = 'bsky';
        postTypes[uri] = _isMediaVideo(postView.media);
        postViews[uri] = postView;
      }
    }

    newPosts.sort((a, b) => b.indexedAt.compareTo(a.indexedAt));
    allPosts.addAll(newPosts.map((post) => post.uri));

    // Get additional labels from followed labelers for new posts
    if (newPosts.isNotEmpty) {
      try {
        final followedLabelers = await _settingsRepository.getFollowedLabelers();
        final newPostUris = newPosts.map((post) => post.uri).toList();
        final (cursor: _, labels: additionalLabels) = await _feedRepository.getLabels(newPostUris, sources: followedLabelers);
        // Add the additional labels to the posts
        for (final label in additionalLabels) {
          final uri = AtUri.parse(label.uri);
          final post = postViews[uri];
          if (post != null) {
            final existingLabels = post.labels != null ? List<Label>.from(post.labels!) : <Label>[];
            existingLabels.add(label);
            postViews[uri] = post.copyWith(labels: existingLabels);
          }
        }
      } catch (e) {
        _logger.e('Error fetching additional labels: $e');
      }
    }

    // Client-side components decide whether to show videos/images/all.
    // Here we only apply label-based filtering and return all posts.
    final filteredPosts = await _filterHiddenPosts(allPosts, postViews);

    final isEndOfNetwork =
        (sparkResult.cursor == null && bskyResult.cursor == null) ||
        (currentState != null && currentState.allPosts.length == allPosts.length);

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
    Future<({List<FeedViewPost> posts, String? cursor})> Function(String? cursor) fetcher,
    String? cursor,
    String sourceName,
  ) async {
    try {
      final result = await fetcher(cursor);
      return result;
    } catch (e, stackTrace) {
      _logger.e('Failed to load from $sourceName: $e', error: e, stackTrace: stackTrace);
      return (posts: <FeedViewPost>[], cursor: cursor);
    }
  }

  bool _isMediaVideo(MediaView? embed) {
    if (embed == null) return false;
    return embed.when(
      video: (cid, playlist, thumbnail, alt) => true,
      bskyVideo: (cid, playlist, thumbnail, alt) => true,
      bskyRecordWithMedia: (record, media) => _isMediaVideo(media),
      image: (image) => false,
      images: (images) => false,
      bskyImages: (images) => false,
      bskyRecord: (record) => false,
      bskyExternal: (external) => false,
    );
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

      final newPostUris = result.allPosts.where((uri) => !currentState.allPosts.contains(uri)).toList();
      if (newPostUris.isNotEmpty) {
        final postViewsToCache = newPostUris.map((uri) => result.postViews[uri]!).toList();
        await _sqlCache.cachePosts(postViewsToCache);
      }
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

  /// Checks if a post should be hidden based on its labels and user preferences
  Future<bool> _shouldHidePost(AtUri uri, List<Label> postLabels) async {
    final hideAdultContent = await _settingsRepository.getHideAdultContent();
    for (final label in postLabels) {
      try {
        final labelPreference = await _settingsRepository.getLabelPreference(label.value);
        if (labelPreference.setting == Setting.hide || (labelPreference.adultOnly && hideAdultContent)) {
          return true;
        }
      } catch (e) {
        // Label preference not found, continue checking other labels
        continue;
      }
    }
    return false;
  }

  /// Filters URIs based on label preferences, removing posts that should be hidden
  Future<List<AtUri>> _filterHiddenPosts(
    List<AtUri> uris,
    Map<AtUri, PostView> postViews,
  ) async {
    final filteredUris = <AtUri>[];

    for (final uri in uris) {
      final postView = postViews[uri];
      if (postView != null) {
        // Collect all labels for this post
        final postLabels = <Label>[];

        // Add labels from the post itself
        if (postView.labels != null) {
          postLabels.addAll(postView.labels!);
        }

        // Add self labels from the post record
        if (postView.record.selfLabels != null) {
          for (final selfLabel in postView.record.selfLabels!) {
            postLabels.add(
              Label(
                uri: postView.uri.toString(),
                value: selfLabel.value,
                src: postView.uri.toString(),
                createdAt: postView.indexedAt,
              ),
            );
          }
        }

        final shouldHide = await _shouldHidePost(uri, postLabels);
        if (!shouldHide) {
          filteredUris.add(uri);
        }
      } else {
        // No post view means no labels, so include the post
        filteredUris.add(uri);
      }
    }

    return filteredUris;
  }

  Future<void> deletePost(AtUri postUri) async {
    try {
      await GetIt.I<SQLCacheInterface>().deletePost(postUri);
      await GetIt.I<SprkRepository>().repo.deleteRecord(uri: postUri);
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
