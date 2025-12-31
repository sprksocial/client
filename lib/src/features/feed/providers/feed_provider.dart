import 'dart:async';
import 'dart:collection';

import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/cache/download_manager_interface.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

part 'feed_provider.g.dart';

@Riverpod(keepAlive: true)
class FeedNotifier extends _$FeedNotifier {
  bool _isLoadingInProgress = false;
  bool _isFetching = false;
  DateTime? _lastErrorTime;
  static const _errorCooldown = Duration(seconds: 10);
  late Feed _feed;
  late final FeedRepository _feedRepository;
  late final SprkRepository _sprkRepository;
  late final SparkLogger _logger;
  late final DownloadManagerInterface _downloadManager;

  // Add a flag to track if this notifier has been built before
  bool _hasBeenBuilt = false;
  FeedState? _preservedState;

  @override
  FeedState build(Feed feed) {
    _feed = feed;

    // Initialize logger first for debugging
    if (!_isInitialized()) {
      _sprkRepository = GetIt.instance<SprkRepository>();
      _feedRepository = _sprkRepository.feed;
      _downloadManager = GetIt.instance<DownloadManagerInterface>();
      _logger = GetIt.instance<LogService>().getLogger('FeedNotifier ${feed.config.id}');
    } else {
      _logger.d('Build called again for ${feed.config.id}, hasBeenBuilt: $_hasBeenBuilt');
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
      case Feed(type: 'timeline'):
        return false;
      case Feed(type: 'feed'):
        if (_feed.view != null) {
          return _feed.view!.uri.collection.toString() == 'app.bsky.feed.generator';
        }
      case _:
        throw ArgumentError('Invalid feed type: $_feed');
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
      // Labels are already included in post views from the appview
      // We just need to merge them with self-labels and process them
      final allLabels = <Label>[];
      final postsWithMergedLabels = <PostView>[];
      var postsWithoutLabels = 0;

      for (final post in posts) {
        final key = post.uri.toString();
        // Start with labels from the post view (from appview)
        final postLabels = <Label>[...?post.labels];

        // Add self-labels from the post record
        if (post.record.selfLabels != null) {
          for (final selfLabel in post.record.selfLabels!) {
            postLabels.add(
              Label(uri: key, val: selfLabel.val, src: key, cts: post.indexedAt),
            );
          }
        }

        // Check if post has no labels from appview (after adding self-labels, check original)
        if (post.labels == null || post.labels!.isEmpty) {
          postsWithoutLabels++;
        }

        allLabels.addAll(postLabels);
        postsWithMergedLabels.add(post.copyWith(labels: postLabels));
      }

      // Log warning if many posts are missing labels (might indicate header issue)
      if (postsWithoutLabels > 0 && postsWithoutLabels == posts.length) {
        _logger.w('All ${posts.length} posts are missing labels - check if atproto-accept-labelers header is being sent');
      } else if (postsWithoutLabels > posts.length / 2) {
        _logger.w('$postsWithoutLabels/${posts.length} posts are missing labels - some labels may not be included');
      }

      final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels})>.from(
        state.extraInfo,
      );

      for (final newLabel in allLabels) {
        final uri = AtUri.parse(newLabel.uri);
        extraInfo.update(
          uri,
          (value) {
            final existingLabels = value.postLabels;

            // if the new label is already in the existing labels, check if it should replace the existing one
            if (existingLabels.any((label) => label.val == newLabel.val)) {
              final existingLabel = existingLabels.firstWhere((label) => label.val == newLabel.val);

              // if the new label says that the existing one is negated or expired, replace the existing one
              if (((newLabel.ver ?? 0) > (existingLabel.ver ?? 0) && newLabel.isNeg) ||
                  existingLabel.exp != null && existingLabel.exp!.isBefore(DateTime.now())) {
                existingLabels.remove(existingLabel);
                return (
                  postLabels: [...existingLabels, newLabel],
                );
              } else {
                // if the new label is the same as the existing one, do nothing
                return value;
              }
            } else {
              // if the new label is not in the existing labels, add it
              return (
                postLabels: [...existingLabels, newLabel],
              );
            }
          },
          ifAbsent: () => (
            postLabels: [newLabel],
          ),
        );
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
      // Ensure loadingFirstLoad is set to false even on error
      state = state.copyWith(loadingFirstLoad: false, error: true);
    }
  }

  Future<({int count, List<PostView> posts, String? cursor})> fetch({int? limit}) async {
    final pageLimit = limit ?? FeedState.fetchLimit;

    // Get labelers for the header
    final settings = ref.read(settingsProvider.notifier);
    List<String> labelerDids;
    try {
      labelerDids = await settings.getLabelers().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Use modDid from repository as fallback
          final modDid = _sprkRepository.modDid.split('#').first;
          return [modDid];
        },
      );
    } catch (e) {
      // Use modDid from repository as fallback
      final modDid = _sprkRepository.modDid.split('#').first;
      labelerDids = [modDid];
    }

    final feedView = await _feedRepository.getFeed(_feed, limit: pageLimit, cursor: state.cursor, labelerDids: labelerDids);

    // Extract PostView from FeedViewPost items (they're already hydrated)
    final posts = <PostView>[];
    for (final feedPost in feedView.feed) {
      final postView = feedPost.asPost;
      if (postView != null) {
        posts.add(postView);
      }
    }

    return (count: feedView.feed.length, posts: posts, cursor: feedView.cursor);
  }

  Future<void> _maybeFetchNextBatch({int? limit, bool replaceExisting = false}) async {
    if (_isFetching || state.isEndOfNetworkFeed) {
      return;
    }

    _isFetching = true;
    try {
      var attempts = 0;
      var consecutiveEmptyResults = 0;
      const maxAttempts = 5;
      const maxConsecutiveEmpty = 3;
      while (attempts < maxAttempts && !state.isEndOfNetworkFeed) {
        attempts++;
        final (:count, :posts, :cursor) = await fetch(limit: limit);
        final fetchedCount = count;
        final fetchedPosts = posts;
        if (fetchedPosts.isEmpty) {
          if (fetchedCount == 0 || cursor == null) {
            await endOfNetworkFeed();
            state = state.copyWith(loadingFirstLoad: false, isEndOfNetworkFeed: true);
            break;
          }
          if (fetchedCount > 0) {
            consecutiveEmptyResults++;
            if (consecutiveEmptyResults >= maxConsecutiveEmpty) {
              await endOfNetworkFeed();
              state = state.copyWith(loadingFirstLoad: false, isEndOfNetworkFeed: true);
              break;
            }
          }
          state = state.copyWith(cursor: cursor, loadingFirstLoad: false);
          continue;
        }

        consecutiveEmptyResults = 0;
        final newPosts = fetchedPosts;

        if (newPosts.isEmpty) {
          if (fetchedCount == 0 || cursor == null) {
            await endOfNetworkFeed();
            state = state.copyWith(loadingFirstLoad: false, isEndOfNetworkFeed: true);
            break;
          }
          state = state.copyWith(cursor: cursor, loadingFirstLoad: false);
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
    final settings = ref.read(settingsProvider.notifier);
    for (final label in postLabels) {
      try {
        final labelPreference = await settings.getLabelPreference(label.val);
        if (labelPreference.setting == Setting.hide || labelPreference.adultOnly) {
          _logger.d('Hiding post $uri due to label: ${label.val}');
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
    LinkedHashMap<AtUri, ({List<Label> postLabels})> extraInfo,
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
