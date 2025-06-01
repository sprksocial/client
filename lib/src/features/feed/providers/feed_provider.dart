import 'dart:collection';
import 'dart:math';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_algorithms/hardcoded_feed_algorithm.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/cache/download_manager_interface.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';

part 'feed_provider.g.dart';

@Riverpod(keepAlive: true)
class FeedNotifier extends _$FeedNotifier {
  final _initialUris = <AtUri>{};
  bool _isWaitingForFreshPostsAtEnd = false;
  late final SQLCacheInterface _sqlCache;
  late final Feed _feed;
  late final FeedRepository _feedRepository;
  late final SparkLogger _logger;
  late final DownloadManagerInterface _downloadManager;
  late final SettingsRepository _settingsRepository;

  @override
  FeedState build(Feed feed) {
    _feed = feed;
    _feedRepository = GetIt.instance<SprkRepository>().feed;
    _settingsRepository = GetIt.instance<SettingsRepository>();
    _sqlCache = GetIt.instance<SQLCacheInterface>();
    _downloadManager = GetIt.instance<DownloadManagerInterface>();
    _logger = GetIt.instance<LogService>().getLogger('FeedNotifier ${feed.identifier}');

    listenSelf((previous, next) {
      final prevFreshCount = previous?.freshPostCount ?? 0;
      // If we were waiting at the end of the feed and new posts have arrived
      if (_isWaitingForFreshPostsAtEnd && next.freshPostCount > 0 && prevFreshCount == 0) {
        _logger.d('New posts arrived! Loading...');
        load(); // load() should reset _isWaitingForFreshPostsAtEnd if it loads something
      }
    });

    return FeedState(
      active: true,
      loadedPosts: [],
      index: 0,
      freshPostCount: 0,
      isCaching: true,
      isEndOfNetworkFeed: false,
      cursor: null,
      extraInfo: LinkedHashMap(),
    );
  }

  Future<void> loadAndUpdateFirstLoad() async {
    _logger.d('First load started');
    // gets the first posts from the database
    final uriStrings = await _sqlCache.getUrisForFeed(_feed, limit: FeedState.firstLoadLimit);
    final uris = uriStrings.map((e) => AtUri.parse(e)).toList();

    // adds the initial uris to the list of initial uris so that they are not fetched again
    _initialUris.addAll(uris);

    // gets the subscribed labels for the posts
    final followedLabelers = await _settingsRepository.getFollowedLabelers();
    final (cursor: _, labels: List<Label> labels) = await _feedRepository.getLabels(uris, sources: followedLabelers);

    if (uris.isNotEmpty) {
      // updates the posts in the database with new information if they have been edited
      final updatedPostViews = await _feedRepository.getPosts(uris);

      for (var post in updatedPostViews) {
        labels.addAll(post.labels ?? []); // labels from the post
        if (post.record.selfLabels != null) {
          final recordLabels = <Label>[];
          for (SelfLabel selfLabel in post.record.selfLabels!) {
            recordLabels.add(
              Label(uri: post.uri.toString(), value: selfLabel.value, src: post.uri.toString(), createdAt: post.record.createdAt),
            );
          }
          labels.addAll(recordLabels); // self labels
        }
      }
      await _sqlCache.cachePosts(updatedPostViews);
      _logger.d('Updated starting posts in database');
    }

    // starts fetching and storing new posts
    final (int count, List<AtUri> fetchedUris, String? cursor) = await fetch();
    if (count > 0) {
      await store(fetchedUris, cursor);
    } else {
      endOfNetworkFeed();
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
        final newExtraInfos = await extraInfoGetter(uris);
        extraInfo.updateAll((key, value) => (postLabels: value.postLabels, hardcodedFeedExtraInfo: newExtraInfos[key]));
      }
    }
    state = state.copyWith(loadedPosts: uris, freshPostCount: 0, extraInfo: extraInfo);
    _logger.d('First load finished');
  }

  Future<(int, List<AtUri>, String?)> fetch() async {
    _logger.d('Fetching started. Cursor: ${state.cursor}');
    // gets the skeleton of the feed
    final skeleton = await _feedRepository.getFeedSkeleton(_feed, limit: FeedState.fetchLimit, cursor: state.cursor);
    final fetchedUris = skeleton.feed.map((e) => e.uri).toList();

    // remove fetched uris that were present when the feed was first loaded
    final filteredUris = fetchedUris.where((uri) => !_initialUris.contains(uri)).toList();
    _logger.d('Fetched ${skeleton.feed.length} posts. Filtered ${fetchedUris.length - filteredUris.length}');
    return (skeleton.feed.length, filteredUris, skeleton.cursor);
  }

  Future<void> increaseFreshPostCount() async {
    state = state.copyWith(freshPostCount: state.freshPostCount + 1);
  }

  Future<void> store(List<AtUri> uris, String? cursor) async {
    state = state.copyWith(isCaching: true);
    int updatedPostCount = 0;

    // checks if the posts have already been cached
    final existingUris = await _sqlCache.getExistingPostUris(uris);
    // cache hit
    if (existingUris.isNotEmpty) {
      final posts = await _feedRepository.getPosts(existingUris);
      await _sqlCache.cachePosts(posts);
      updatedPostCount = posts.length;
      if (updatedPostCount > 0) {
        _logger.d('Updated $updatedPostCount posts in database');
        state = state.copyWith(freshPostCount: state.freshPostCount + updatedPostCount);
      }
    }

    // gets the posts that are not cached
    final nonExistingUris = uris.where((uri) => !existingUris.contains(uri)).toList();
    if (nonExistingUris.isEmpty) {
      state = state.copyWith(isCaching: false, cursor: cursor);
      return;
    }
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
            increaseFreshPostCount();
            newPostsCached++;
            // == to only trigger this once
            // this exists to prevent the feed from being fetched too much
            // it is divided in half to prevent the feed from getting stuck loading big files
            // (the other half will keep being downloaded, but you can start downloading another batch to be more efficient)
            // should use pool to have a limit on the number of concurrent downloads
            if (newPostsCached == (nonExistingPosts.length - errorCount) >> 1) {
              state = state.copyWith(isCaching: false, cursor: cursor);
            }
            _logger.d('Downloaded embed and cached post ${post.uri}');
          },
          onError: (task, e, s) {
            errorCount++;
          },
        ),
      );
    }
  }

  Future<void> load() async {
    // loads the next (loadLimit) posts from the database
    final amountToLoad = min(FeedState.loadLimit, state.freshPostCount);
    if (amountToLoad > 0) {
      // this ALWAYS gets new posts (most recent + only the amount of new ones that have been cached)
      final posts = await _sqlCache.getPostsForFeed(_feed, limit: amountToLoad);
      final uris = posts.map((e) => e.uri).toList();
      _isWaitingForFreshPostsAtEnd = false;
      _logger.d('Loaded $amountToLoad posts from database');

      // gets the subscribed labels for the posts
      final followedLabelers = await _settingsRepository.getFollowedLabelers();
      final (cursor: _, labels: List<Label> labels) = await _feedRepository.getLabels(uris, sources: followedLabelers);

      for (var post in posts) {
        labels.addAll(post.labels ?? []); // labels from the post
        if (post.record.selfLabels != null) {
          final recordLabels = <Label>[];
          for (SelfLabel selfLabel in post.record.selfLabels!) {
            recordLabels.add(
              Label(uri: post.uri.toString(), value: selfLabel.value, src: post.uri.toString(), createdAt: post.record.createdAt),
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
          final newExtraInfos = await extraInfoGetter(uris);
          extraInfo.updateAll((key, value) => (postLabels: value.postLabels, hardcodedFeedExtraInfo: newExtraInfos[key]));
        }
      }
      state = state.copyWith(
        loadedPosts: [...state.loadedPosts, ...uris],
        freshPostCount: state.freshPostCount - amountToLoad,
        extraInfo: extraInfo,
      );
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
