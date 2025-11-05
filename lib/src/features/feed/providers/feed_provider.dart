import 'dart:collection';
import 'dart:math' as math;

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/feed_algorithms/hardcoded_feed_algorithm.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/cache/download_manager_interface.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

part 'feed_provider.g.dart';

@Riverpod(keepAlive: true)
class FeedNotifier extends _$FeedNotifier {
  final _initialUris = <AtUri>{};
  bool _isWaitingForFreshPostsAtEnd = false;
  bool _isLoadingInProgress = false;
  bool _isLoading = false;
  bool _isCaching = false;
  late final SQLCacheInterface _sqlCache;
  late Feed _feed;
  late final FeedRepository _feedRepository;
  late final SparkLogger _logger;
  late final DownloadManagerInterface _downloadManager;
  late final SettingsRepository _settingsRepository;

  // Add a flag to track if this notifier has been built before
  bool _hasBeenBuilt = false;
  FeedState? _preservedState;

  @override
  FeedState build(Feed feed) {
    _feed = feed;

    // Initialize logger first for debugging
    if (!_isInitialized()) {
      _feedRepository = GetIt.instance<SprkRepository>().feed;
      _settingsRepository = GetIt.instance<SettingsRepository>();
      _sqlCache = GetIt.instance<SQLCacheInterface>();
      _downloadManager = GetIt.instance<DownloadManagerInterface>();
      _logger = GetIt.instance<LogService>().getLogger('FeedNotifier ${feed.identifier}');
    } else {
      _logger.d('Build called again for ${feed.identifier}, hasBeenBuilt: $_hasBeenBuilt');
    }

    listenSelf((previous, next) {
      // If we were waiting at the end of the feed and new posts have arrived
      if (_isWaitingForFreshPostsAtEnd && next.freshPostCount > 0) {
        Future.microtask(load); // Prevent synchronous execution during state change
      }

      // Update preserved state whenever state changes
      _preservedState = next;
    });

    final isActive = ref.watch(settingsProvider).activeFeed == feed;

    // If this notifier has been built before and we have preserved state, use it
    if (_hasBeenBuilt && _preservedState != null) {
      final restoredState = _preservedState!.copyWith(active: isActive);
      // Update preserved state with the new active status
      _preservedState = restoredState;
      return restoredState;
    }

    _hasBeenBuilt = true;

    // Only return fresh state on first initialization
    final freshState = FeedState(
      active: isActive,
      loadedPosts: [],
      index: 0,
      freshPostCount: 0,
      isEndOfNetworkFeed: false,
      cursor: null,
      extraInfo: LinkedHashMap(),
      loadingFirstLoad: false,
      error: false,
    );

    _preservedState = freshState;
    return freshState;
  }

  bool _isInitialized() {
    try {
      // Try to access one of the late final fields
      // ignore: unnecessary_statements
      _feedRepository;
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _shouldUseBlueskyAPI() {
    // Determine if this feed should use Bluesky API for post hydration
    switch (_feed) {
      case FeedHardCoded(:final hardCodedFeed):
        switch (hardCodedFeed) {
          case HardCodedFeedEnum.forYou:
            // For You feed uses Bluesky generator (TheVids)
            return true;
          case HardCodedFeedEnum.following:
            // Following feed now uses Spark API timeline
            return false;
          case HardCodedFeedEnum.latestSprk:
            // Latest Sprk feed uses Spark API
            return false;
          case HardCodedFeedEnum.mutuals:
          case HardCodedFeedEnum.shared:
            // These are not implemented yet (return empty feed)
            // When implemented, determine based on their actual implementation
            return false;
        }
      case FeedCustom():
        // Custom feeds are currently Spark-based
        return false;
    }
    return false;
  }

  Future<void> loadAndUpdateFirstLoad() async {
    if (_isLoadingInProgress || _isLoading) {
      _logger.w('Load already in progress, skipping duplicate call');
      return;
    }

    if (state.loadingFirstLoad) {
      return;
    }

    _isLoadingInProgress = true;
    try {
      state = state.copyWith(loadingFirstLoad: true, error: false);

      // gets ONLY the first f cached posts from the database (not all)
      final uriStrings = await _sqlCache.getUrisForFeed(_feed, limit: FeedState.firstLoadLimit);
      final uris = uriStrings.map(AtUri.parse).toList();
      final labels = <Label>[];

      // adds the initial uris to the list of initial uris so that they are not fetched again
      _initialUris.addAll(uris);

      if (uris.isNotEmpty) {
        // Get existing cached posts to preserve viewer information (like status)
        final cachedPosts = await _sqlCache.getPostsByUris(uris);
        final cachedPostsMap = {for (final post in cachedPosts) post.uri: post};

        // gets the subscribed labels for the posts
        final followedLabelers = await _settingsRepository.getFollowedLabelers();
        final (cursor: _, labels: labels) = await _feedRepository.getLabels(uris, sources: followedLabelers);

        // updates the posts in the database with new information if they have been edited
        final updatedPostViews = await _feedRepository.getPosts(uris, bluesky: _shouldUseBlueskyAPI());

        // Preserve viewer information from cached posts when updating with fresh data
        final mergedPosts = <PostView>[];
        for (final freshPost in updatedPostViews) {
          final cachedPost = cachedPostsMap[freshPost.uri];
          PostView finalPost;

          if (cachedPost != null && cachedPost.viewer != null) {
            // Preserve viewer information from cache if it exists
            finalPost = freshPost.copyWith(viewer: cachedPost.viewer);
          } else {
            finalPost = freshPost;
          }

          mergedPosts.add(finalPost);
        }

        for (final post in mergedPosts) {
          labels.addAll(post.labels ?? []); // labels from the post
          if (post.record.selfLabels != null) {
            final recordLabels = <Label>[];
            for (final selfLabel in post.record.selfLabels!) {
              recordLabels.add(
                Label(uri: post.uri.toString(), value: selfLabel.value, src: post.uri.toString(), createdAt: post.indexedAt),
              );
            }
            labels.addAll(recordLabels); // self labels
          }
        }
        await _sqlCache.cachePosts(mergedPosts);
      }

      // Store the cursor from the initial fetch
      var newCursor = state.cursor;
      var fetchedCount = 0;
      // starts fetching and storing new posts
      if (!state.isEndOfNetworkFeed) {
        final (int count, List<AtUri> fetchedUris, String? cursor) = await fetch();
        newCursor = cursor;
        fetchedCount = fetchedUris.length; // Use filtered URI count, not raw skeleton count
        if (fetchedUris.isNotEmpty) {
          await store(fetchedUris);
        } else if (count == 0) {
          // Only end if the skeleton itself is empty
          endOfNetworkFeed();
        }
      }

      // gets all extra info for the posts (labels and hardcoded feed extra info)
      final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})>.from(
        state.extraInfo,
      );

      for (final newLabel in labels) {
        final uri = AtUri.parse(newLabel.uri);
        extraInfo.update(uri, (value) {
          final existingLabels = value.postLabels;

          if (existingLabels.any((label) => label.value == newLabel.value)) {
            final existingLabel = existingLabels.firstWhere((label) => label.value == newLabel.value);

            if (((newLabel.ver ?? 0) > (existingLabel.ver ?? 0) && newLabel.isNegate) ||
                existingLabel.exp != null && existingLabel.exp!.isBefore(DateTime.now())) {
              existingLabels.remove(existingLabel);
              return (postLabels: [...existingLabels, newLabel], hardcodedFeedExtraInfo: value.hardcodedFeedExtraInfo);
            } else {
              return value;
            }
          } else {
            return (postLabels: [...existingLabels, newLabel], hardcodedFeedExtraInfo: value.hardcodedFeedExtraInfo);
          }
        }, ifAbsent: () => (postLabels: [newLabel], hardcodedFeedExtraInfo: null));
      }

      if (feed case FeedHardCoded(:final hardCodedFeed)) {
        final extraInfoGetter = HardCodedFeedAlgorithm.extraInfoFromEnum(hardCodedFeed);
        if (extraInfoGetter != null) {
          final newExtraInfos = await extraInfoGetter(uris);
          extraInfo.updateAll((key, value) => (postLabels: value.postLabels, hardcodedFeedExtraInfo: newExtraInfos[key]));
        }
      }
      bool loadingFirstLoad;
      if (uris.isNotEmpty) {
        loadingFirstLoad = false;
      } else {
        loadingFirstLoad = fetchedCount != 0;
      }

      // Filter out posts that should be hidden based on label preferences
      final filteredUris = await _filterHiddenPosts(uris, extraInfo);

      // Don't reset freshPostCount to 0 if we just fetched posts, as store() will have incremented it
      // and we need those posts to be loaded
      final freshPostCount = uris.isEmpty && fetchedCount > 0 ? state.freshPostCount : 0;

      state = state.copyWith(
        loadedPosts: filteredUris,
        freshPostCount: freshPostCount, // Preserve freshPostCount if we just fetched posts
        extraInfo: extraInfo,
        cursor: newCursor, // Store the cursor from fetch
        loadingFirstLoad: loadingFirstLoad,
      );
      _isWaitingForFreshPostsAtEnd = state.length <= 1;
    } catch (e, stackTrace) {
      _logger.e('Error in loadAndUpdateFirstLoad: $e', stackTrace: stackTrace);
      state = state.copyWith(loadingFirstLoad: false, error: true);
    } finally {
      _isLoadingInProgress = false;
    }
  }

  Future<(int, List<AtUri>, String?)> fetch() async {
    // gets the skeleton of the feed
    final skeleton = await _feedRepository.getFeedSkeleton(_feed, limit: FeedState.fetchLimit, cursor: state.cursor);
    final fetchedUris = skeleton.feed.map((e) => e.uri).toList();

    // remove fetched uris that were present when the feed was first loaded
    final filteredUris = fetchedUris.where((uri) => !_initialUris.contains(uri)).toList();
    return (skeleton.feed.length, filteredUris, skeleton.cursor);
  }

  Future<void> increaseFreshPostCount() async {
    state = state.copyWith(freshPostCount: state.freshPostCount + 1);
  }

  Future<void> store(List<AtUri> uris) async {
    _isCaching = true; // Set caching flag immediately
    var updatedPostCount = 0;
    state = state.copyWith(error: false);
    try {
      // checks if the posts have already been cached
      final existingUris = await _sqlCache.getExistingPostUris(uris);
      // cache hit
      if (existingUris.isNotEmpty) {
        // Get existing cached posts to preserve viewer information (like status)
        final cachedPosts = await _sqlCache.getPostsByUris(existingUris);
        final cachedPostsMap = {for (final post in cachedPosts) post.uri: post};

        final posts = await _feedRepository.getPosts(existingUris, bluesky: _shouldUseBlueskyAPI());

        // Preserve viewer information from cached posts when updating with fresh data
        final mergedPosts = <PostView>[];
        for (final freshPost in posts) {
          final cachedPost = cachedPostsMap[freshPost.uri];
          PostView finalPost;

          if (cachedPost != null && cachedPost.viewer != null) {
            // Preserve viewer information from cache if it exists
            finalPost = freshPost.copyWith(viewer: cachedPost.viewer);
          } else {
            finalPost = freshPost;
          }

          mergedPosts.add(finalPost);
        }

        await _sqlCache.cachePosts(mergedPosts);
        await _sqlCache.appendPostsToFeed(_feed, existingUris.map((e) => e.toString()).toList());

        // Only increment freshPostCount for posts that aren't already in loadedPosts
        final newExistingUris = existingUris.where((uri) => !state.loadedPosts.contains(uri)).toList();
        updatedPostCount = newExistingUris.length;

        if (updatedPostCount > 0) {
          state = state.copyWith(freshPostCount: state.freshPostCount + updatedPostCount);
        }
      }

      // gets the posts that are not cached
      final nonExistingUris = uris.where((uri) => !existingUris.contains(uri)).toList();
      if (nonExistingUris.isEmpty) {
        _isCaching = false;
        return;
      }
      final nonExistingPosts = await _feedRepository.getPosts(nonExistingUris, bluesky: _shouldUseBlueskyAPI());

      // gets the subscribed labels for the new posts
      final followedLabelers = await _settingsRepository.getFollowedLabelers();
      var newPostLabels = <Label>[];
      try {
        final (cursor: _, labels: fetchedLabels) = await _feedRepository.getLabels(nonExistingUris, sources: followedLabelers);
        newPostLabels = fetchedLabels;
      } catch (e) {
        _logger.e('Error getting labels for new posts: $e');
        newPostLabels = [];
      }

      final postsWithLabels = <PostView>[];
      for (final post in nonExistingPosts) {
        newPostLabels.addAll(post.labels ?? []); // labels from the post
        if (post.record.selfLabels != null) {
          final recordLabels = <Label>[];
          for (final selfLabel in post.record.selfLabels!) {
            recordLabels.add(
              Label(uri: post.uri.toString(), value: selfLabel.value, src: post.uri.toString(), createdAt: post.indexedAt),
            );
          }
          newPostLabels.addAll(recordLabels); // self labels
        }
        postsWithLabels.add(post.copyWith(labels: newPostLabels));
      }

      var newPostsCached = 0;
      var errorCount = 0;
      for (final post in postsWithLabels) {
        // concurrent execution
        _downloadManager.submitTask(
          DownloadTask(
            uri: post.uri,
            post: post,
            feed: _feed,
            onComplete: (task) {
              // Only increment if the post is not already in loadedPosts
              if (!state.loadedPosts.contains(task.uri)) {
                increaseFreshPostCount();
              }
              newPostsCached++;
              // == to only trigger this once
              // this exists to prevent the feed from being fetched too much
              // it is divided in half to prevent the feed from getting stuck loading big files
              // (the other half will keep being downloaded, but you can start downloading another batch to be more efficient)
              // should use pool to have a limit on the number of concurrent downloads
              if (newPostsCached == (nonExistingPosts.length - errorCount) >> 1 && !_downloadManager.poolFull) {
                _isCaching = false;
                _logger.d('Set isCaching to false after downloading $newPostsCached posts');
              }
            },
            onError: (task, e, s) {
              errorCount++;
              _logger.e('Error downloading post ${task.uri}: $e');
            },
          ),
        );
      }
    } catch (e, stackTrace) {
      state = state.copyWith(error: true);
      _logger.e('Error in store: $e', stackTrace: stackTrace);
    } finally {
      _isCaching = false;
    }
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    // loads the next (loadLimit) posts from the database
    final amountToLoad = math.min(FeedState.loadLimit, state.freshPostCount);
    if (amountToLoad > 0) {
      final posts = await _sqlCache.getPostsForFeed(_feed, limit: amountToLoad);
      // yeah this is O(n²). but i spent too much time trying to avoid repeated posts
      final uris = posts.map((e) => e.uri).toList().where((uri) => !state.loadedPosts.contains(uri)).toList();

      if (uris.isEmpty) {
        // Still need to decrement freshPostCount since those posts were "consumed"
        state = state.copyWith(freshPostCount: math.max(0, state.freshPostCount - amountToLoad));
        _isLoading = false;
        return;
      }

      _isWaitingForFreshPostsAtEnd = amountToLoad <= 1; // edge case where only one post is loaded

      // gets the subscribed labels for the posts
      final followedLabelers = await _settingsRepository.getFollowedLabelers();
      var labels = <Label>[];
      try {
        final (cursor: _, labels: fetchedLabels) = await _feedRepository.getLabels(uris, sources: followedLabelers);
        labels = fetchedLabels;
      } catch (e) {
        _logger.e('Error getting labels: $e');
        labels = [];
      }

      // Get the post data for the new URIs
      final newPosts = posts.where((post) => uris.contains(post.uri)).toList();
      for (final post in newPosts) {
        labels.addAll(post.labels ?? []); // labels from the post
        if (post.record.selfLabels != null) {
          final recordLabels = <Label>[];
          for (final selfLabel in post.record.selfLabels!) {
            recordLabels.add(
              Label(uri: post.uri.toString(), value: selfLabel.value, src: post.uri.toString(), createdAt: post.indexedAt),
            );
          }
          labels.addAll(recordLabels); // self labels
        }

        // Ensure media files are cached; if missing, enqueue a download task.
        if (post.media is MediaViewVideo) {
          _downloadManager.submitTask(
            DownloadTask(
              uri: post.uri,
              post: post,
              feed: _feed,
              onComplete: (task) => _logger.d('Re-cached media for \\${task.uri}'),
              onError: (task, e, s) => _logger.e('Failed to re-cache media for \\${task.uri}: \\$e'),
            ),
          );
        }
      }

      // gets all extra info for the posts (labels and hardcoded feed extra info)
      // for example, if it's the shared feed, the posts need to know the profile of the sender and the text of the message
      final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})>.from(
        state.extraInfo,
      );

      for (final newLabel in labels) {
        final uri = AtUri.parse(newLabel.uri);
        extraInfo.update(uri, (value) {
          final existingLabels = value.postLabels;

          // if the new label is already in the existing labels, check if it should replace the existing one
          if (existingLabels.any((label) => label.value == newLabel.value)) {
            final existingLabel = existingLabels.firstWhere((label) => label.value == newLabel.value);

            // if the new label says that the existing one is negated or expired, replace the existing one
            if (((newLabel.ver ?? 0) > (existingLabel.ver ?? 0) && newLabel.isNegate) ||
                existingLabel.exp != null && existingLabel.exp!.isBefore(DateTime.now())) {
              existingLabels.remove(existingLabel);
              return (postLabels: [...existingLabels, newLabel], hardcodedFeedExtraInfo: value.hardcodedFeedExtraInfo);
            } else {
              // if the new label is the same as the existing one, do nothing
              return value;
            }
          } else {
            // if the new label is not in the existing labels, add it
            return (postLabels: [...existingLabels, newLabel], hardcodedFeedExtraInfo: value.hardcodedFeedExtraInfo);
          }
        }, ifAbsent: () => (postLabels: [newLabel], hardcodedFeedExtraInfo: null));
      }

      if (feed case FeedHardCoded(:final hardCodedFeed)) {
        final extraInfoGetter = HardCodedFeedAlgorithm.extraInfoFromEnum(hardCodedFeed);
        if (extraInfoGetter != null) {
          final newExtraInfos = await extraInfoGetter(uris);
          extraInfo.updateAll((key, value) => (postLabels: value.postLabels, hardcodedFeedExtraInfo: newExtraInfos[key]));
        }
      }

      // Filter out posts that should be hidden based on label preferences
      final filteredUris = await _filterHiddenPosts(uris, extraInfo);

      state = state.copyWith(
        loadedPosts: [...state.loadedPosts, ...filteredUris],
        freshPostCount: state.freshPostCount - filteredUris.length, // Only subtract the actual new posts loaded
        extraInfo: extraInfo,
        loadingFirstLoad: false,
      );
    }
    _isLoading = false;
  }

  Future<void> endOfNetworkFeed() async {
    // the UI will be notified that the feed is at the end and also this will only be called once
    if (state.isEndOfNetworkFeed) return;
    // no isEndOfFeed because the UI warning is different
    state = state.copyWith(isEndOfNetworkFeed: true);
  }

  Future<void> setIndex(int index) async {
    state = state.copyWith(index: index);
  }

  Future<void> scrollDown() async {
    if (state.length - state.index < FeedState.loadLimit) {
      await load();
      if (!_isCaching) {
        final (int fetchedCount, List<AtUri> fetchedUris, String? cursor) = await fetch();
        if (fetchedUris.isEmpty && fetchedCount == 0) {
          // Only end if the skeleton itself is empty
          endOfNetworkFeed();
        } else if (fetchedUris.isNotEmpty) {
          // Store the new cursor and then store the fetched posts
          state = state.copyWith(cursor: cursor);
          store(fetchedUris);
        }
        // If fetchedUris is empty but fetchedCount > 0, just update cursor and continue
        else {
          state = state.copyWith(cursor: cursor);
        }
      }
    }
    if (state.length - state.index <= 1 && !_isWaitingForFreshPostsAtEnd && !state.isEndOfNetworkFeed) {
      _isWaitingForFreshPostsAtEnd = true;
    }
  }

  Future<void> setActive(bool active) async {
    state = state.copyWith(active: active);
    if (active) {
      _downloadManager.setActiveFeed(_feed); // Inform coordinator
    }
  }

  /// Checks if a post should be hidden based on its labels and user preferences
  Future<bool> _shouldHidePost(AtUri uri, List<Label> postLabels) async {
    final hideAdultContent = await _settingsRepository.getHideAdultContent();
    for (final label in postLabels) {
      try {
        final labelPreference = await _settingsRepository.getLabelPreference(label.value);
        if (labelPreference.setting == Setting.hide || (labelPreference.adultOnly && hideAdultContent)) {
          _logger.d('Hiding post $uri due to label: ${label.value}');
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
    LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})> extraInfo,
  ) async {
    final filteredUris = <AtUri>[];

    for (final uri in uris) {
      final postExtraInfo = extraInfo[uri];
      if (postExtraInfo != null) {
        final shouldHide = await _shouldHidePost(uri, postExtraInfo.postLabels);
        if (!shouldHide) {
          filteredUris.add(uri);
        }
      } else {
        // No extra info means no labels, so include the post
        filteredUris.add(uri);
      }
    }

    return filteredUris;
  }
}
