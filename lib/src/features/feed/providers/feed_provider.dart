import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider, Ref;
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart/poptart.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/storage/cache/download_manager_interface.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/feed/providers/feed_state.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

part 'feed_provider.g.dart';

abstract interface class FeedSettingsGateway {
  Future<List<String>> getLabelers();

  Future<LabelPreference> getLabelPreference(String value);
}

class _RiverpodFeedSettingsGateway implements FeedSettingsGateway {
  const _RiverpodFeedSettingsGateway(this.ref, this.sprkRepository);

  final Ref ref;
  final SprkRepository sprkRepository;

  @override
  Future<List<String>> getLabelers() async {
    try {
      return await ref
          .read(settingsProvider.notifier)
          .getLabelers()
          .timeout(const Duration(seconds: 5), onTimeout: _fallbackLabelers);
    } catch (_) {
      return _fallbackLabelers();
    }
  }

  List<String> _fallbackLabelers() {
    return [sprkRepository.modDid.split('#').first];
  }

  @override
  Future<LabelPreference> getLabelPreference(String value) {
    return ref.read(settingsProvider.notifier).getLabelPreference(value);
  }
}

final feedSettingsGatewayProvider = Provider<FeedSettingsGateway>((ref) {
  return _RiverpodFeedSettingsGateway(ref, GetIt.instance<SprkRepository>());
});

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
  late final FeedSettingsGateway _settingsGateway;
  Completer<void>? _fetchCompletion;

  // Track active fetch operation for cancellation
  int _fetchGeneration = 0;

  // Add a flag to track if this notifier has been built before
  bool _hasBeenBuilt = false;
  FeedState? _preservedState;

  @override
  FeedState build(Feed feed) {
    // Track previous feed to detect changes
    final previousFeed = _hasBeenBuilt ? _feed : null;
    _feed = feed;

    // If feed changed, increment generation to cancel any pending fetches
    if (previousFeed != null && previousFeed.config.id != feed.config.id) {
      _fetchGeneration++;
      _logger.d(
        'Feed changed from ${previousFeed.config.id} to ${feed.config.id}, '
        'incremented generation to $_fetchGeneration',
      );
    }

    // Initialize logger first for debugging
    if (!_isInitialized()) {
      _sprkRepository = GetIt.instance<SprkRepository>();
      _feedRepository = _sprkRepository.feed;
      _downloadManager = GetIt.instance<DownloadManagerInterface>();
      _settingsGateway = ref.read(feedSettingsGatewayProvider);
      _logger = GetIt.instance<LogService>().getLogger(
        'FeedNotifier ${feed.config.id}',
      );
    }

    listenSelf((previous, next) {
      // Update preserved state whenever state changes
      _preservedState = next;
    });

    final isActive = ref.watch(settingsProvider).activeFeed == feed;

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

  Future<void> loadAndUpdateFirstLoad() async {
    if (_isLoadingInProgress || state.loadingFirstLoad) {
      return;
    }

    if (_lastErrorTime != null &&
        DateTime.now().difference(_lastErrorTime!) < _errorCooldown) {
      return;
    }

    // Increment fetch generation to invalidate any in-flight fetches
    _fetchGeneration++;
    final currentGeneration = _fetchGeneration;

    _isLoadingInProgress = true;
    try {
      state = state.copyWith(
        loadingFirstLoad: true,
        error: false,
        loadedPosts: const <PostView>[],
        cursor: null,
        isEndOfNetworkFeed: false,
      );
      await _maybeFetchNextBatch(
        limit: FeedState.firstLoadLimit,
        replaceExisting: true,
        generation: currentGeneration,
      );
    } catch (e, stackTrace) {
      // Only update state if this is still the current generation
      if (ref.mounted && _fetchGeneration == currentGeneration) {
        _logger.e(
          'Error in loadAndUpdateFirstLoad: $e',
          stackTrace: stackTrace,
        );
        _lastErrorTime = DateTime.now();
        state = state.copyWith(loadingFirstLoad: false, error: true);
      }
    } finally {
      _isLoadingInProgress = false;
      if (ref.mounted &&
          _fetchGeneration == currentGeneration &&
          state.loadingFirstLoad) {
        state = state.copyWith(loadingFirstLoad: false);
      }
    }
  }

  Future<bool> _processFetchedPosts(
    List<PostView> posts, {
    String? cursor,
    bool replaceExisting = false,
    int? generation,
  }) async {
    // Check if generation has changed
    if (generation != null && generation != _fetchGeneration) {
      _logger.d('Process posts superseded by newer generation');
      return false;
    }

    if (posts.isEmpty) {
      if (ref.mounted &&
          (generation == null || generation == _fetchGeneration)) {
        state = state.copyWith(cursor: cursor, loadingFirstLoad: false);
      }
      return false;
    }

    try {
      // Labels are already included in post views from the appview
      // We just need to merge them with self-labels and process them
      final allLabels = <Label>[];
      final postsWithMergedLabels = <PostView>[];

      for (final post in posts) {
        final key = post.uri.toString();
        // Start with labels from the post view (from appview)
        final postLabels = <Label>[...?post.labels];

        // Add self-labels from the post record
        if (post.selfLabels != null) {
          for (final selfLabel in post.selfLabels!) {
            postLabels.add(
              Label(
                uri: key,
                val: selfLabel.val,
                src: key,
                cts: post.indexedAt,
              ),
            );
          }
        }

        allLabels.addAll(postLabels);
        postsWithMergedLabels.add(post.copyWith(labels: postLabels));
      }

      final extraInfo = LinkedHashMap<AtUri, ({List<Label> postLabels})>.from(
        state.extraInfo,
      );

      for (final newLabel in allLabels) {
        final uri = AtUri.parse(newLabel.uri);
        extraInfo.update(uri, (value) {
          final existingLabels = value.postLabels;

          // if new label in existing labels,
          //check if it should replace existing one
          if (existingLabels.any((label) => label.val == newLabel.val)) {
            final existingLabel = existingLabels.firstWhere(
              (label) => label.val == newLabel.val,
            );

            // if new label says that existing one is negated or expired,
            // replace the existing one
            if (((newLabel.ver ?? 0) > (existingLabel.ver ?? 0) &&
                    newLabel.isNeg) ||
                existingLabel.exp != null &&
                    existingLabel.exp!.isBefore(DateTime.now())) {
              existingLabels.remove(existingLabel);
              return (postLabels: [...existingLabels, newLabel]);
            } else {
              // if the new label is the same as the existing one, do nothing
              return value;
            }
          } else {
            // if the new label is not in the existing labels, add it
            return (postLabels: [...existingLabels, newLabel]);
          }
        }, ifAbsent: () => (postLabels: [newLabel]));
      }

      final filteredPosts = await _filterHiddenPosts(
        postsWithMergedLabels,
        extraInfo,
      );

      if (!ref.mounted) return false;

      // Check generation after async operation
      if (generation != null && generation != _fetchGeneration) {
        _logger.d('Process posts superseded after filtering');
        return false;
      }

      if (filteredPosts.isEmpty) {
        if (generation == null || generation == _fetchGeneration) {
          state = state.copyWith(
            cursor: cursor,
            extraInfo: extraInfo,
            loadingFirstLoad: false,
          );
        }
        return false;
      }

      final updatedPosts = replaceExisting
          ? filteredPosts
          : [...state.loadedPosts, ...filteredPosts];
      if (generation == null || generation == _fetchGeneration) {
        state = state.copyWith(
          loadedPosts: updatedPosts,
          cursor: cursor,
          extraInfo: extraInfo,
          loadingFirstLoad: false,
        );
      }

      for (final post in filteredPosts) {
        _downloadManager.submitTask(
          DownloadTask(
            uri: post.uri,
            post: post,
            feed: _feed,
            onComplete: (_) {},
            onError: (task, error, stackTrace) => _logger.e(
              'Error caching media for ${task.uri}: $error',
              error: error,
              stackTrace: stackTrace,
            ),
          ),
        );
      }
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Error while processing fetched posts: $e',
        stackTrace: stackTrace,
      );
      // Ensure loadingFirstLoad is set to false even on error
      if (ref.mounted) {
        state = state.copyWith(loadingFirstLoad: false, error: true);
      }
      return false;
    }
  }

  Future<({int count, List<PostView> posts, String? cursor})> fetch({
    int? limit,
  }) async {
    final pageLimit = limit ?? FeedState.fetchLimit;

    final labelerDids = await _settingsGateway.getLabelers();

    final feedView = await _feedRepository.getFeed(
      _feed,
      limit: pageLimit,
      cursor: state.cursor,
      labelerDids: labelerDids,
    );

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

  Future<void> _maybeFetchNextBatch({
    int? limit,
    bool replaceExisting = false,
    int? generation,
  }) async {
    if (state.isEndOfNetworkFeed) {
      return;
    }

    final activeGeneration = generation ?? _fetchGeneration;
    if (_isFetching) {
      final fetchCompletion = _fetchCompletion;
      if (generation != null && fetchCompletion != null) {
        await fetchCompletion.future;
        if (ref.mounted && activeGeneration == _fetchGeneration) {
          await _maybeFetchNextBatch(
            limit: limit,
            replaceExisting: replaceExisting,
            generation: activeGeneration,
          );
        }
      }
      return;
    }

    _isFetching = true;
    final fetchCompletion = Completer<void>();
    _fetchCompletion = fetchCompletion;
    try {
      var attempts = 0;
      var consecutiveEmptyResults = 0;
      const maxAttempts = 5;
      const maxConsecutiveEmpty = 3;
      while (attempts < maxAttempts && !state.isEndOfNetworkFeed) {
        attempts++;

        // Check if generation has changed (fetch was superseded)
        if (activeGeneration != _fetchGeneration) {
          _logger.d('Fetch superseded by newer generation, cancelling');
          return;
        }

        final (:count, :posts, :cursor) = await fetch(limit: limit);

        // Check again after await
        if (activeGeneration != _fetchGeneration) {
          _logger.d('Fetch superseded after network call, discarding results');
          return;
        }

        final fetchedCount = count;
        final fetchedPosts = posts;
        if (fetchedPosts.isEmpty) {
          if (fetchedCount == 0 || cursor == null) {
            await endOfNetworkFeed();
            if (ref.mounted && activeGeneration == _fetchGeneration) {
              state = state.copyWith(
                loadingFirstLoad: false,
                isEndOfNetworkFeed: true,
              );
            }
            break;
          }
          if (fetchedCount > 0) {
            consecutiveEmptyResults++;
            if (consecutiveEmptyResults >= maxConsecutiveEmpty) {
              await endOfNetworkFeed();
              if (ref.mounted && activeGeneration == _fetchGeneration) {
                state = state.copyWith(
                  loadingFirstLoad: false,
                  isEndOfNetworkFeed: true,
                );
              }
              break;
            }
          }
          if (ref.mounted && activeGeneration == _fetchGeneration) {
            state = state.copyWith(cursor: cursor, loadingFirstLoad: false);
          }
          continue;
        }

        final addedPosts = await _processFetchedPosts(
          fetchedPosts,
          cursor: cursor,
          replaceExisting: replaceExisting,
          generation: activeGeneration,
        );
        if (activeGeneration != _fetchGeneration) return;
        if (state.error) return;
        if (addedPosts) {
          if (cursor == null) await endOfNetworkFeed();
          break;
        }

        consecutiveEmptyResults++;
        if (cursor == null || consecutiveEmptyResults >= maxConsecutiveEmpty) {
          await endOfNetworkFeed();
          break;
        }
      }
    } catch (e, stackTrace) {
      // Only update error state if this generation is still current
      if (ref.mounted && activeGeneration == _fetchGeneration) {
        _logger.e('Error prefetching feed: $e', stackTrace: stackTrace);
        _lastErrorTime = DateTime.now();
        state = state.copyWith(error: true, loadingFirstLoad: false);
      }
      rethrow;
    } finally {
      _isFetching = false;
      if (!fetchCompletion.isCompleted) fetchCompletion.complete();
      if (identical(_fetchCompletion, fetchCompletion)) {
        _fetchCompletion = null;
      }
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
    if (_lastErrorTime != null &&
        DateTime.now().difference(_lastErrorTime!) < _errorCooldown) {
      return;
    }
    if (state.length - state.index < FeedState.loadLimit &&
        !state.isEndOfNetworkFeed) {
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

  void replacePost(PostView updatedPost) {
    final index = state.loadedPosts.indexWhere(
      (post) => post.uri == updatedPost.uri,
    );
    if (index == -1) {
      return;
    }
    final updatedPosts = [...state.loadedPosts];
    updatedPosts[index] = updatedPost;
    state = state.copyWith(loadedPosts: updatedPosts);
  }

  /// Removes a post at the specified index from the feed
  /// and adjusts the current index if necessary.
  void removePostAtIndex(int index) {
    if (index < 0 || index >= state.length) return;

    final postToRemove = state.loadedPosts[index];
    final updatedPosts = [...state.loadedPosts]..removeAt(index);

    // Clean up extraInfo for the removed post
    final updatedExtraInfo =
        LinkedHashMap<AtUri, ({List<Label> postLabels})>.from(state.extraInfo)
          ..remove(postToRemove.uri);

    // Keep the same visual post when removing before the current position,
    // and keep the index in bounds when removing the final visible post.
    final shiftedIndex = state.index > index ? state.index - 1 : state.index;
    final newIndex = updatedPosts.isEmpty
        ? 0
        : shiftedIndex.clamp(0, updatedPosts.length - 1);

    state = state.copyWith(
      loadedPosts: updatedPosts,
      extraInfo: updatedExtraInfo,
      index: newIndex,
    );
  }

  /// Checks if a post should be hidden based on its labels and user preferences
  Future<bool> _shouldHidePost(AtUri uri, List<Label> postLabels) async {
    for (final label in postLabels) {
      try {
        final labelPreference = await _settingsGateway.getLabelPreference(
          label.val,
        );
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

  /// Filters based on label preferences, removing posts that should be hidden
  Future<List<PostView>> _filterHiddenPosts(
    List<PostView> posts,
    LinkedHashMap<AtUri, ({List<Label> postLabels})> extraInfo,
  ) async {
    final filteredPosts = <PostView>[];

    for (final post in posts) {
      final postExtraInfo = extraInfo[post.uri];
      if (postExtraInfo != null) {
        final shouldHide = await _shouldHidePost(
          post.uri,
          postExtraInfo.postLabels,
        );
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
