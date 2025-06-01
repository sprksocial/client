import 'dart:collection';
import 'dart:math';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_algorithms/hardcoded_feed_algorithm.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';

part 'feed_provider.g.dart';

@Riverpod(keepAlive: true)
class FeedNotifier extends _$FeedNotifier {
  final _initialUris = <AtUri>{};
  bool _isWaitingForFreshPostsAtEnd = false;
  late final SQLCache _sqlCache;
  late final Feed _feed;
  late final FeedRepository _feedRepository;
  late final SparkLogger _logger;
  late final DownloadManager _downloadManager;

  @override
  FeedState build(Feed feed) {
    _feed = feed;
    final storageManager = GetIt.instance<StorageManager>();
    _feedRepository = GetIt.instance<FeedRepository>();
    _sqlCache = storageManager.sqlCache;
    _downloadManager = storageManager.downloadManager;
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
    _initialUris.addAll(uris);

    if (uris.isNotEmpty) {
      // updates the posts in the database with new information if they have been edited
      final updatedPostViews = await _feedRepository.getPosts(uris);
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

    final List<Label> labels = []; //await _feedRepository.getLabels(uris);

    final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels, HardcodedFeedExtraInfo? hardcodedFeedExtraInfo})>.from(
      state.extraInfo,
    );

    for (Label label in labels) {
      final uri = AtUri.parse(label.uri);
      extraInfo.update(
        uri,
        (value) => (postLabels: [...value.postLabels, label], hardcodedFeedExtraInfo: value.hardcodedFeedExtraInfo),
      );
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
      final uriStrings = await _sqlCache.getUrisForFeed(_feed, limit: amountToLoad);
      final uris = uriStrings.map((e) => AtUri.parse(e)).toList();
      _isWaitingForFreshPostsAtEnd = false;
      _logger.d('Loaded $amountToLoad posts from database');

      final loadedPosts = <(AtUri, List<Label>)>[];

      final List<Label> labels = []; //await _feedRepository.getLabels(uris);

      Map<AtUri, List<Label>> postLabelsMap = {};
      for (Label label in labels) {
        postLabelsMap.putIfAbsent(AtUri.parse(label.uri), () => []).add(label);
      }

      for (AtUri uri in uris) {
        loadedPosts.add((uri, postLabelsMap[uri] ?? []));
      }

      state = state.copyWith(
        loadedPosts: [...state.loadedPosts, ...loadedPosts],
        freshPostCount: state.freshPostCount - amountToLoad,
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
