import 'dart:collection';

import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/profile/providers/profile_feed_state.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

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

    // Get additional labels from followed labelers for new posts
    if (newPosts.isNotEmpty) {
      try {
        final settings = ref.read(settingsProvider.notifier);
        final followedLabelers = await settings.getLabelers();
        final newPostUris = newPosts.map((post) => post.uri).toList();
        final (cursor: _, labels: additionalLabels) = await _feedRepository
            .getLabels(newPostUris, sources: followedLabelers);
        // Add the additional labels to the posts
        for (final label in additionalLabels) {
          final uri = AtUri.parse(label.uri);
          final post = postViews[uri];
          if (post != null) {
            final existingLabels = post.labels != null
                ? List<Label>.from(post.labels!)
                : <Label>[];
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
      loadedPosts: filteredPosts,
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

  /// Checks if a post should be hidden based on its labels and user preferences
  Future<bool> _shouldHidePost(AtUri uri, List<Label> postLabels) async {
    final settings = ref.read(settingsProvider.notifier);
    for (final label in postLabels) {
      try {
        final labelPreference = await settings.getLabelPreference(label.val);
        if (labelPreference.setting == Setting.hide ||
            labelPreference.adultOnly) {
          return true;
        }
      } catch (e) {
        // Label preference not found, continue checking other labels
        continue;
      }
    }
    return false;
  }

  /// Filters URIs based on label preferences
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
                val: selfLabel.val,
                src: postView.uri.toString(),
                cts: postView.indexedAt,
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
      await GetIt.I<SprkRepository>().repo.deleteRecord(uri: postUri);
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
