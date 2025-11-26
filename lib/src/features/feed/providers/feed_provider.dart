import 'dart:async';
import 'dart:collection';

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
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

part 'feed_provider.g.dart';

@Riverpod(keepAlive: true)
class FeedNotifier extends _$FeedNotifier {
  final _seenUris = <AtUri>{};
  bool _isLoadingInProgress = false;
  bool _isFetching = false;
  DateTime? _lastErrorTime;
  static const _errorCooldown = Duration(seconds: 10);
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
      _downloadManager = GetIt.instance<DownloadManagerInterface>();
      _logger = GetIt.instance<LogService>().getLogger('FeedNotifier ${feed.identifier}');
    } else {
      _logger.d('Build called again for ${feed.identifier}, hasBeenBuilt: $_hasBeenBuilt');
    }

    listenSelf((previous, next) {
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
      loadedPosts: const <PostView>[],
      index: 0,
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
          case HardCodedFeedEnum.timeline:
            // Following feed now uses Spark API timeline
            return false;
          case HardCodedFeedEnum.latest:
            // Latest Sprk feed uses Spark API
            return false;
        }
      case FeedRecord():
        // Custom feeds are currently Spark-based
        return false;
    }
    return false;
  }

  Future<void> loadAndUpdateFirstLoad() async {
    if (_isLoadingInProgress || state.loadingFirstLoad) {
      _logger.w('Load already in progress, skipping duplicate call');
      return;
    }

    if (_lastErrorTime != null && DateTime.now().difference(_lastErrorTime!) < _errorCooldown) {
      _logger.w('In error cooldown, skipping load');
      return;
    }

    _isLoadingInProgress = true;
    try {
      _seenUris.clear();
      state = state.copyWith(
        loadingFirstLoad: true,
        error: false,
        loadedPosts: const <PostView>[],
        cursor: null,
        isEndOfNetworkFeed: false,
      );
      await _maybeFetchNextBatch(limit: FeedState.firstLoadLimit, replaceExisting: true);
    } catch (e, stackTrace) {
      _logger.e('Error in loadAndUpdateFirstLoad: $e', stackTrace: stackTrace);
      _lastErrorTime = DateTime.now();
      state = state.copyWith(loadingFirstLoad: false, error: true);
    } finally {
      _isLoadingInProgress = false;
      if (state.loadingFirstLoad) {
        state = state.copyWith(loadingFirstLoad: false);
      }
    }
  }

  Future<void> _processFetchedPosts(
    List<PostView> posts, {
    String? cursor,
    bool replaceExisting = false,
  }) async {
    if (posts.isEmpty) {
      state = state.copyWith(cursor: cursor, loadingFirstLoad: false);
      return;
    }

    try {
      final uris = posts.map((post) => post.uri).toList();
      final followedLabelers = await _settingsRepository.getFollowedLabelers();
      List<Label> fetchedLabels;
      try {
        final (cursor: _, labels: labelsFromApi) = await _feedRepository.getLabels(uris, sources: followedLabelers);
        fetchedLabels = labelsFromApi;
      } catch (e) {
        _logger.e('Error getting labels for new posts: $e');
        fetchedLabels = const [];
      }

      final labelsByUri = <String, List<Label>>{};
      for (final label in fetchedLabels) {
        labelsByUri.putIfAbsent(label.uri, () => []).add(label);
      }

      final allLabels = <Label>[];
      final postsWithMergedLabels = <PostView>[];
      for (final post in posts) {
        final key = post.uri.toString();
        final postLabels = <Label>[...?labelsByUri[key], ...?post.labels];
        if (post.record.selfLabels != null) {
          for (final selfLabel in post.record.selfLabels!) {
            postLabels.add(
              Label(uri: key, value: selfLabel.value, src: key, createdAt: post.indexedAt),
            );
          }
        }
        allLabels.addAll(postLabels);
        postsWithMergedLabels.add(post.copyWith(labels: postLabels));
      }

      final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})>.from(
        state.extraInfo,
      );

      for (final newLabel in allLabels) {
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

      if (_feed case FeedHardCoded(:final hardCodedFeed)) {
        final extraInfoGetter = HardCodedFeedAlgorithm.extraInfoFromEnum(hardCodedFeed);
        if (extraInfoGetter != null) {
          final newExtraInfos = await extraInfoGetter(uris);
          extraInfo.updateAll((key, value) => (postLabels: value.postLabels, hardcodedFeedExtraInfo: newExtraInfos[key]));
        }
      }

      final filteredPosts = await _filterHiddenPosts(postsWithMergedLabels, extraInfo);

      if (filteredPosts.isEmpty) {
        state = state.copyWith(cursor: cursor, extraInfo: extraInfo, loadingFirstLoad: false);
        return;
      }

      final updatedPosts = replaceExisting ? filteredPosts : [...state.loadedPosts, ...filteredPosts];
      state = state.copyWith(
        loadedPosts: updatedPosts,
        cursor: cursor,
        extraInfo: extraInfo,
        loadingFirstLoad: false,
      );

      for (final post in filteredPosts) {
        _downloadManager.submitTask(
          DownloadTask(
            uri: post.uri,
            post: post,
            feed: _feed,
            onComplete: (task) => _logger.d('Media cached for ${task.uri}'),
            onError: (task, error, stackTrace) =>
                _logger.e('Error caching media for ${task.uri}: $error', error: error, stackTrace: stackTrace),
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error while processing fetched posts: $e', stackTrace: stackTrace);
    }
  }

  Future<({int count, List<PostView> posts, String? cursor})> fetch({int? limit}) async {
    final pageLimit = limit ?? FeedState.fetchLimit;
    return switch (_feed) {
      FeedHardCoded(:final hardCodedFeed) => () async {
        final feedViewFunction = HardCodedFeedAlgorithm.feedViewFromEnum(hardCodedFeed);
        final feedView = await feedViewFunction(limit: pageLimit, cursor: state.cursor);
        final postViews = feedView.feed.map((feedPost) => feedPost.asPost).whereType<PostView>().toList();
        final filteredPosts = postViews.where((post) => !_seenUris.contains(post.uri)).toList(growable: false);
        return (count: postViews.length, posts: filteredPosts, cursor: feedView.cursor);
      }(),
      FeedRecord() => () async {
        final skeleton = await _feedRepository.getFeed(_feed, limit: pageLimit, cursor: state.cursor);
        final fetchedUris = skeleton.feed.map((e) => e.uri).toList();
        final filteredUris = fetchedUris.where((uri) => !_seenUris.contains(uri)).toList();
        if (filteredUris.isEmpty) {
          return (count: skeleton.feed.length, posts: const <PostView>[], cursor: skeleton.cursor);
        }
        final posts = await _feedRepository.getPosts(filteredUris, bluesky: _shouldUseBlueskyAPI());
        return (count: skeleton.feed.length, posts: posts, cursor: skeleton.cursor);
      }(),
      _ => throw ArgumentError('Invalid feed type: $_feed'),
    };
  }

  Future<void> _maybeFetchNextBatch({int? limit, bool replaceExisting = false}) async {
    if (_isFetching || state.isEndOfNetworkFeed) {
      return;
    }

    _isFetching = true;
    try {
      var attempts = 0;
      const maxAttempts = 5;
      while (attempts < maxAttempts && !state.isEndOfNetworkFeed) {
        attempts++;
        final (:count, :posts, :cursor) = await fetch(limit: limit);
        final fetchedCount = count;
        final fetchedPosts = posts;
        if (fetchedPosts.isEmpty) {
          if (fetchedCount == 0 || cursor == null) {
            await endOfNetworkFeed();
            break;
          }
          state = state.copyWith(cursor: cursor);
          continue;
        }

        final newPosts = <PostView>[];
        for (final post in fetchedPosts) {
          if (_seenUris.add(post.uri)) {
            newPosts.add(post);
          }
        }

        if (newPosts.isEmpty) {
          state = state.copyWith(cursor: cursor);
          if (cursor == null) {
            await endOfNetworkFeed();
            break;
          }
          continue;
        }

        await _processFetchedPosts(newPosts, cursor: cursor, replaceExisting: replaceExisting);
        break;
      }
    } catch (e, stackTrace) {
      _logger.e('Error prefetching feed: $e', stackTrace: stackTrace);
      _lastErrorTime = DateTime.now();
      state = state.copyWith(error: true, loadingFirstLoad: false);
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  Future<void> endOfNetworkFeed() async {
    if (state.isEndOfNetworkFeed) return;
    state = state.copyWith(isEndOfNetworkFeed: true);
  }

  Future<void> setIndex(int index) async {
    state = state.copyWith(index: index);
  }

  Future<void> scrollDown() async {
    if (state.error) return;
    if (_lastErrorTime != null && DateTime.now().difference(_lastErrorTime!) < _errorCooldown) return;
    if (state.length - state.index < FeedState.loadLimit && !state.isEndOfNetworkFeed) {
      try {
        await _maybeFetchNextBatch();
      } catch (_) {
        // Error already handled in _maybeFetchNextBatch
      }
    }
  }

  Future<void> setActive(bool active) async {
    state = state.copyWith(active: active);
    if (active) {
      _downloadManager.setActiveFeed(_feed);
    }
  }

  Future<void> refreshPost(AtUri uri) async {
    try {
      final posts = await _feedRepository.getPosts([uri], bluesky: _shouldUseBlueskyAPI());
      if (posts.isEmpty) return;
      replacePost(posts.first);
    } catch (e, stackTrace) {
      _logger.e('Error refreshing post $uri: $e', stackTrace: stackTrace);
    }
  }

  void replacePost(PostView updatedPost) {
    final index = state.loadedPosts.indexWhere((post) => post.uri == updatedPost.uri);
    if (index == -1) {
      return;
    }
    final updatedPosts = [...state.loadedPosts];
    updatedPosts[index] = updatedPost;
    state = state.copyWith(loadedPosts: updatedPosts);
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

  /// Filters posts based on label preferences, removing posts that should be hidden
  Future<List<PostView>> _filterHiddenPosts(
    List<PostView> posts,
    LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})> extraInfo,
  ) async {
    final filteredPosts = <PostView>[];

    for (final post in posts) {
      final postExtraInfo = extraInfo[post.uri];
      if (postExtraInfo != null) {
        final shouldHide = await _shouldHidePost(post.uri, postExtraInfo.postLabels);
        if (!shouldHide) {
          filteredPosts.add(post);
        }
      } else {
        filteredPosts.add(post);
      }
    }

    return filteredPosts;
  }
}
