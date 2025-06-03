import 'dart:collection';
import 'dart:math';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/feed_algorithms/hardcoded_feed_algorithm.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
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
  late final SQLCacheInterface _sqlCache;
  late Feed _feed;
  late final FeedRepository _feedRepository;
  late final SparkLogger _logger;
  late final DownloadManagerInterface _downloadManager;
  late final SettingsRepository _settingsRepository;
  
  // Track the highest association order from initial load
  int? _initialLoadMaxOrder;
  
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
      final prevFreshCount = previous?.freshPostCount ?? 0;
      // If we were waiting at the end of the feed and new posts have arrived
      if (_isWaitingForFreshPostsAtEnd && next.freshPostCount > 0 && prevFreshCount == 0) {
        _logger.d('New posts arrived! Loading...');
        Future.microtask(() => load()); // Prevent synchronous execution during state change
      }
    });

    var isActive = ref.watch(settingsProvider).activeFeed == feed;
    
    // If this notifier has been built before and we have preserved state, use it
    if (_hasBeenBuilt && _preservedState != null) {
      _logger.d('Restoring preserved state for ${feed.identifier}: ${_preservedState!.length} posts');
      final restoredState = _preservedState!.copyWith(active: isActive);
      return restoredState;
    }
    
    _hasBeenBuilt = true;
    _logger.d('Creating fresh state for ${feed.identifier}');
    
    // Only return fresh state on first initialization
    final freshState = FeedState(
      active: isActive,
      loadedPosts: [],
      index: 0,
      freshPostCount: 0,
      isCaching: true,
      isEndOfNetworkFeed: false,
      cursor: null,
      extraInfo: LinkedHashMap(),
      loadingFirstLoad: false,
    );
    
    _preservedState = freshState;
    return freshState;
  }
  
  // Override state setter to preserve state
  @override
  set state(FeedState newState) {
    _preservedState = newState;
    super.state = newState;
    _logger.d('State updated for ${_feed.identifier}: ${newState.length} posts, active: ${newState.active}');
  }

  bool _isInitialized() {
    try {
      // Try to access one of the late final fields
      _feedRepository;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadAndUpdateFirstLoad() async {
    if (_isLoadingInProgress) {
      _logger.w('Load already in progress, skipping duplicate call');
      return;
    }

    _isLoadingInProgress = true;
    try {
      _logger.d('First load started');
      state = state.copyWith(loadingFirstLoad: true);

      // gets ONLY the first f cached posts from the database (not all)
      final uriStrings = await _sqlCache.getUrisForFeed(_feed, limit: FeedState.firstLoadLimit);
      final uris = uriStrings.map((e) => AtUri.parse(e)).toList();
      List<Label> labels = <Label>[];

      // adds the initial uris to the list of initial uris so that they are not fetched again
      _initialUris.addAll(uris);
      _logger.d('Initial uris loaded: ${uris.length}');
      
      // Track the max association order from initial load - ALWAYS set this
      _initialLoadMaxOrder = await _sqlCache.getMaxAssociationOrderForFeed(_feed);
      _logger.d('Initial load max association order: $_initialLoadMaxOrder');

      if (uris.isNotEmpty) {
        // gets the subscribed labels for the posts
        final followedLabelers = await _settingsRepository.getFollowedLabelers();
        final (cursor: _, labels: labels) = await _feedRepository.getLabels(uris, sources: followedLabelers);

        // updates the posts in the database with new information if they have been edited
        final updatedPostViews = await _feedRepository.getPosts(uris);

        for (var post in updatedPostViews) {
          labels.addAll(post.labels ?? []); // labels from the post
          if (post.record.selfLabels != null) {
            final recordLabels = <Label>[];
            for (SelfLabel selfLabel in post.record.selfLabels!) {
              recordLabels.add(
                Label(uri: post.uri.toString(), value: selfLabel.value, src: post.uri.toString(), createdAt: post.indexedAt),
              );
            }
            labels.addAll(recordLabels); // self labels
          }
        }
        await _sqlCache.cachePosts(updatedPostViews);
        _logger.d('Updated starting posts in database');
      }

      // starts fetching and storing new posts
      if (!state.isEndOfNetworkFeed) {
        final (int count, List<AtUri> fetchedUris, String? cursor) = await fetch();
        if (count > 0) {
          await store(fetchedUris, cursor);
        } else {
          endOfNetworkFeed();
        }
      }

      // gets all extra info for the posts (labels and hardcoded feed extra info)
      final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})>.from(
        state.extraInfo,
      );

      for (Label newLabel in labels) {
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

      state = state.copyWith(
        loadedPosts: uris, 
        freshPostCount: 0, // Set to 0 as per strategy
        extraInfo: extraInfo, 
        loadingFirstLoad: false // Always set to false after loading
      );
      _isWaitingForFreshPostsAtEnd = uris.isEmpty;
      _logger.d('First load finished with ${uris.length} posts');
    } catch (e, stackTrace) {
      _logger.e('Error in loadAndUpdateFirstLoad: $e', stackTrace: stackTrace);
      state = state.copyWith(loadingFirstLoad: false);
    } finally {
      _isLoadingInProgress = false;
    }
  }

  Future<(int, List<AtUri>, String?)> fetch() async {
    _logger.d('Fetching started. Current cursor: ${state.cursor}');
    // gets the skeleton of the feed
    final skeleton = await _feedRepository.getFeedSkeleton(_feed, limit: FeedState.fetchLimit, cursor: state.cursor);
    final fetchedUris = skeleton.feed.map((e) => e.uri).toList();

    // remove fetched uris that were present when the feed was first loaded
    final filteredUris = fetchedUris.where((uri) => !_initialUris.contains(uri)).toList();
    _logger.d('Fetched ${skeleton.feed.length} posts, filtered to ${filteredUris.length}. New cursor: ${skeleton.cursor}');
    return (skeleton.feed.length, filteredUris, skeleton.cursor);
  }

  Future<void> increaseFreshPostCount() async {
    state = state.copyWith(freshPostCount: state.freshPostCount + 1);
  }

  Future<void> store(List<AtUri> uris, String? cursor) async {
    _logger.d('Store called with ${uris.length} URIs. Current freshPostCount: ${state.freshPostCount}. Cursor: $cursor');
    state = state.copyWith(isCaching: true, cursor: cursor); // Set cursor immediately
    int updatedPostCount = 0;

    // checks if the posts have already been cached
    final existingUris = await _sqlCache.getExistingPostUris(uris);
    // cache hit
    if (existingUris.isNotEmpty) {
      _logger.d('Found ${existingUris.length} existing posts in cache');
      final posts = await _feedRepository.getPosts(existingUris);
      await _sqlCache.cachePosts(posts);
      
      // Only increment freshPostCount for posts that aren't already in loadedPosts
      final newExistingUris = existingUris.where((uri) => !state.loadedPosts.contains(uri)).toList();
      updatedPostCount = newExistingUris.length;
      
      if (updatedPostCount > 0) {
        _logger.d('Updated $updatedPostCount posts in database (${existingUris.length - updatedPostCount} were already loaded)');
        state = state.copyWith(freshPostCount: state.freshPostCount + updatedPostCount);
      } else {
        _logger.d('All ${existingUris.length} existing posts were already loaded, not incrementing freshPostCount');
      }
    }

    // gets the posts that are not cached
    final nonExistingUris = uris.where((uri) => !existingUris.contains(uri)).toList();
    if (nonExistingUris.isEmpty) {
      _logger.d('No new posts to download, setting isCaching to false');
      state = state.copyWith(isCaching: false); // cursor already set above
      return;
    }
    _logger.d('Downloading ${nonExistingUris.length} new posts');
    final nonExistingPosts = await _feedRepository.getPosts(nonExistingUris);
    int newPostsCached = 0;
    int errorCount = 0;
    for (PostView post in nonExistingPosts) {
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
              _logger.d('Downloaded new post ${task.uri}, freshPostCount now: ${state.freshPostCount + 1}');
            } else {
              _logger.d('Downloaded post ${task.uri} but it was already loaded, not incrementing freshPostCount');
            }
            newPostsCached++;
            // == to only trigger this once
            // this exists to prevent the feed from being fetched too much
            // it is divided in half to prevent the feed from getting stuck loading big files
            // (the other half will keep being downloaded, but you can start downloading another batch to be more efficient)
            // should use pool to have a limit on the number of concurrent downloads
            if (newPostsCached == (nonExistingPosts.length - errorCount) >> 1) {
              state = state.copyWith(isCaching: false); // cursor already set above
              _logger.d('Set isCaching to false after downloading $newPostsCached posts');
            }
            _logger.d('Downloaded embed and cached post ${post.uri}');
          },
          onError: (task, e, s) {
            errorCount++;
            _logger.e('Error downloading post ${task.uri}: $e');
          },
        ),
      );
    }
  }

  Future<void> load() async {
    // loads the next (loadLimit) posts from the database
    final amountToLoad = min(FeedState.loadLimit, state.freshPostCount);
    if (amountToLoad > 0) {
      // Get posts that were added AFTER the initial load
      final afterOrder = _initialLoadMaxOrder ?? -1;
      _logger.d('Loading posts after association order: $afterOrder, amount to load: $amountToLoad');
      
      final posts = await _sqlCache.getPostsForFeedAfterOrder(_feed, afterOrder, limit: amountToLoad);
      final uris = posts.map((e) => e.uri).toList();
      
      _logger.d('Database returned ${posts.length} posts after order $afterOrder: ${uris.map((u) => u.toString()).take(3).join(', ')}${uris.length > 3 ? '...' : ''}');
      
      // Filter out posts that are already in loadedPosts to avoid duplicates
      final newUris = uris.where((uri) => !state.loadedPosts.contains(uri)).toList();
      
      if (newUris.isEmpty) {
        _logger.d('No new posts to load (all ${uris.length} were already loaded)');
        // Still need to decrement freshPostCount since those posts were "consumed"
        state = state.copyWith(freshPostCount: max(0, state.freshPostCount - amountToLoad));
        return;
      }
      
      _isWaitingForFreshPostsAtEnd = false;
      _logger.d('Loaded ${newUris.length} fresh posts from database (after order $afterOrder). Already loaded: ${uris.length - newUris.length}');

      // gets the subscribed labels for the posts
      final followedLabelers = await _settingsRepository.getFollowedLabelers();
      final (cursor: _, labels: List<Label> labels) = await _feedRepository.getLabels(newUris, sources: followedLabelers);

      // Get the post data for the new URIs
      final newPosts = posts.where((post) => newUris.contains(post.uri)).toList();
      for (var post in newPosts) {
        labels.addAll(post.labels ?? []); // labels from the post
        if (post.record.selfLabels != null) {
          final recordLabels = <Label>[];
          for (SelfLabel selfLabel in post.record.selfLabels!) {
            recordLabels.add(
              Label(uri: post.uri.toString(), value: selfLabel.value, src: post.uri.toString(), createdAt: post.indexedAt),
            );
          }
          labels.addAll(recordLabels); // self labels
        }
      }

      // gets all extra info for the posts (labels and hardcoded feed extra info)
      // for example, if it's the shared feed, the posts need to know the profile of the sender and the text of the message
      final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})>.from(
        state.extraInfo,
      );

      for (Label newLabel in labels) {
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
          final newExtraInfos = await extraInfoGetter(newUris);
          extraInfo.updateAll((key, value) => (postLabels: value.postLabels, hardcodedFeedExtraInfo: newExtraInfos[key]));
        }
      }
      state = state.copyWith(
        loadedPosts: [...state.loadedPosts, ...newUris],
        freshPostCount: state.freshPostCount - newUris.length, // Only subtract the actual new posts loaded
        extraInfo: extraInfo,
        loadingFirstLoad: false,
      );
      
      _logger.d('Load complete. Total loaded posts: ${state.loadedPosts.length}, remaining fresh: ${state.freshPostCount}');
    } else {
      _logger.d('No fresh posts available to load (freshPostCount: ${state.freshPostCount})');
    }
  }

  Future<void> endOfNetworkFeed() async {
    // the UI will be notified that the feed is at the end and also this will only be called once
    if (state.isEndOfNetworkFeed) return;
    // no isEndOfFeed because the UI warning is different
    _logger.d('End of network feed');
    state = state.copyWith(isEndOfNetworkFeed: true);
  }

  Future<void> setIndex(int index) async {
    state = state.copyWith(index: index);
  }

  Future<void> scrollDown() async {
    if (state.length - state.index < FeedState.loadLimit) {
      // this will be called every time the user scrolls down with few posts left
      await load();
      // this will be called only once with few posts left to minimize the number of fetches and posts downloaded at once
      if (!state.isCaching) {
        final (int fetchedCount, List<AtUri> fetchedUris, String? cursor) = await fetch();
        if (fetchedCount == 0) {
          // it's over. the user will have to open the app again to see new posts (if there are any)
          endOfNetworkFeed();
        } else {
          store(fetchedUris, cursor);
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
}
