import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:pool/pool.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/storage/cache/download_manager_interface.dart';
import 'package:spark/src/core/utils/image_url_resolver.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/feed/providers/feed_state.dart';

class DownloadManagerImpl implements DownloadManagerInterface {
  DownloadManagerImpl() : _pool = Pool(FeedState.poolSize) {
    _logger = GetIt.instance<LogService>().getLogger('DownloadManager');
  }

  /// Initializes the download manager with a default feed.
  /// The actual active feed will be set via [setActiveFeed] once the
  /// UserPreferencesProvider has loaded.
  Future<void> init() async {
    // Start with default feed - the actual active feed will be set
    // via setActiveFeed() once preferences are loaded from the provider
    _activeFeed = Feed(
      type: 'timeline',
      config: SavedFeed(type: 'timeline', value: 'following', pinned: true),
    );
  }

  @override
  bool get poolFull => _tasks.length >= FeedState.poolSize;

  late final SparkLogger _logger;
  late final Pool _pool;
  final PriorityQueue<DownloadTask> _tasks = PriorityQueue<DownloadTask>(
    (a, b) => a.priority.compareTo(b.priority),
  );

  late Feed _activeFeed;
  bool _isProcessing = false;

  static final controller = BetterPlayerController(
    const BetterPlayerConfiguration(),
  ); // static controller for caching

  @override
  void setActiveFeed(Feed feed) {
    _activeFeed = feed;
    _updateTaskPriorities();
    _processQueue(); // Re-evaluate queue processing if active feed changed
  }

  void _updateTaskPriorities() {
    _tasks.removeAll().forEach((task) {
      _tasks.add(
        task.copyWith(
          priority: _activeFeed == task.feed
              ? activeFeedPriority
              : inactiveFeedPriority,
        ),
      );
    });
  }

  void _cancelAllPendingTasks() {
    _tasks.removeAll().forEach((task) {
      if (task.status != DownloadTaskStatus.pending) {
        _tasks.add(task);
      }
    });
  }

  @override
  void submitTask(DownloadTask task) {
    // Prevent duplicate tasks for the same post if one is already pending/active
    if (_tasks.contains(task)) {
      return;
    }

    task.priority = (task.feed == _activeFeed)
        ? activeFeedPriority
        : inactiveFeedPriority;
    _tasks.add(task);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return; // Already processing
    _isProcessing = true;
    final newTasks = <DownloadTask>[];

    while (_tasks.isNotEmpty) {
      final task = _tasks.removeFirst();
      if (task.status == DownloadTaskStatus.pending) {
        // Try to acquire pool resource. If pool full, withResource will wait.
        // We want to submit to pool and let it manage, not block _processQueue.
        // So, we don't await the withResource call here directly in the loop
        // that would make _processQueue sequential for task submission to pool.
        // Instead, we launch it and let the pool handle concurrency.

        task.status = DownloadTaskStatus.submitted;
        await _pool
            .withResource(() => _executeTask(task))
            .then((_) {
              // This 'then' block executes after _executeTask is fully done
              // (either success or failure handled within _executeTask).
              // It's mainly for pool resource management.
            })
            .catchError((e, s) {
              // This is for unexpected errors from _pool.withResource itself,
              // or if _executeTask re-throws an error not caught internally.
              _logger.e(
                'Error from pool for task ${task.uri}: $e',
                error: e,
                stackTrace: s as StackTrace,
              );
              // Ensure task is marked as failed and removed if not already
              if (task.status != DownloadTaskStatus.failed &&
                  task.status != DownloadTaskStatus.completed) {
                task.status = DownloadTaskStatus.failed;
                task.onError(task, e, s);
              }
              _tasks.remove(task); // Ensure removal on unhandled pool error
            });
      }
      if (task.status != DownloadTaskStatus.completed &&
          task.status != DownloadTaskStatus.failed) {
        newTasks.add(task);
      }
    }

    _tasks.addAll(newTasks);

    _isProcessing = false;
  }

  @override
  Future<void> dispose() async {
    _cancelAllPendingTasks(); // Attempt to clean up
    await _pool
        .close(); // Closes the pool and waits for active tasks to complete
  }

  bool _areTherePendingActiveFeedTasks() {
    final tasks = _tasks.toList();
    return tasks.any(
      (task) =>
          task.status == DownloadTaskStatus.pending && task.feed == _activeFeed,
    );
  }

  Future<void> _executeTask(DownloadTask task) async {
    if (_activeFeed != task.feed &&
        task.priority > activeFeedPriority &&
        _areTherePendingActiveFeedTasks()) {
      return;
    }
    try {
      // Simulate a check if this feed is still "desired" to be cached.
      // This is a softer check than full cancellation.

      task.status = DownloadTaskStatus.active;
      // Actual caching work - start downloading the media
      switch (task.post.media) {
        case MediaViewVideo():
          await DownloadManagerImpl.controller.preCache(
            BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              task.post.videoUrl,
              cacheConfiguration: BetterPlayerCacheConfiguration(
                useCache: true,
                preCacheSize: 10 * 1024 * 1024, // 10 MB
                maxCacheSize: 500 * 1024 * 1024, // 500 MB
                key: task.post.videoUrl,
              ),
            ),
          );
        case MediaViewImages():
          for (final url in task.post.imageUrls) {
            // Download the image and verify it's cached
            final fileInfo = await CachedNetworkImageProvider
                .defaultCacheManager
                .downloadFile(url, key: url);
            if (fileInfo.statusCode != 200) {
              _logger.w(
                'Image file was not properly cached after download: $url',
              );
            }
          }
        case MediaViewBskyRecordWithMedia(:final media):
          // Handle nested media in record with media embeds
          switch (media) {
            case MediaViewVideo() || MediaViewBskyVideo():
              await DownloadManagerImpl.controller.preCache(
                BetterPlayerDataSource(
                  BetterPlayerDataSourceType.network,
                  task.post.videoUrl,
                  videoFormat: BetterPlayerVideoFormat.hls,
                  videoExtension: 'm3u8',
                  cacheConfiguration: BetterPlayerCacheConfiguration(
                    useCache: true,
                    preCacheSize: 10 * 1024 * 1024, // 10 MB
                    maxCacheSize: 500 * 1024 * 1024, // 500 MB
                    key: task.post.videoUrl,
                  ),
                ),
              );
            case MediaViewImage() || MediaViewImages() || MediaViewBskyImages():
              for (final url in task.post.imageUrls) {
                // Download the image and verify it's cached
                await CachedNetworkImageProvider.defaultCacheManager
                    .downloadFile(url, key: url);
              }
            default:
              throw Exception('Unsupported media type: ${media.runtimeType}');
          }
        case MediaViewBskyVideo(:final thumbnail):
          await DownloadManagerImpl.controller.preCache(
            BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              videoFormat: BetterPlayerVideoFormat.hls,
              videoExtension: 'm3u8',
              task.post.videoUrl,
              placeholder: CachedNetworkImage(
                fadeInDuration: Duration.zero,
                imageUrl: resolveImageUrlOrEmpty(thumbnail),
              ),
              cacheConfiguration: BetterPlayerCacheConfiguration(
                useCache: true,
                preCacheSize: 10 * 1024 * 1024, // 10 MB
                maxCacheSize: 500 * 1024 * 1024, // 500 MB
                key: task.post.videoUrl,
              ),
            ),
          );
        default:
          throw Exception(
            'Unsupported media type: ${task.post.media.runtimeType}',
          );
      }

      task.status = DownloadTaskStatus.completed;
      task.onComplete(task);
    } catch (e, s) {
      task.status = DownloadTaskStatus.failed;
      _logger.w('Failed to cache media for ${task.uri}');
      task.onError(task, e, s);
    } finally {
      // Remove from the main queue regardless of outcome, as it's processed.
      _tasks.remove(task);
      // Potentially trigger queue processing again if a slot opened up.
      // This helps ensure the pool stays busy if there's work.
      _processQueue();
    }
  }
}
