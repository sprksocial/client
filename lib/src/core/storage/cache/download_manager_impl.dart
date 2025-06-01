import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:pool/pool.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/cache/download_manager_interface.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';
import 'package:collection/collection.dart';

class DownloadManagerImpl implements DownloadManagerInterface {
  DownloadManagerImpl() : _pool = Pool(FeedState.poolSize) {
    _sqlCache = GetIt.instance<SQLCacheInterface>();
    _logger = GetIt.instance<LogService>().getLogger('DownloadManager');
    _cacheManager = GetIt.instance<CacheManagerInterface>();
  }

  Future<void> init() async {
    _activeFeed = await GetIt.instance<SettingsRepository>().getActiveFeed();
  }

  late final SQLCacheInterface _sqlCache;
  late final SparkLogger _logger;
  late final CacheManagerInterface _cacheManager;
  late final Pool _pool;
  final PriorityQueue<DownloadTask> _tasks = PriorityQueue<DownloadTask>((a, b) => a.priority.compareTo(b.priority));

  late Feed _activeFeed;
  bool _isProcessing = false;

  @override
  void setActiveFeed(Feed feed) {
    _logger.d('Setting active feed to: ${feed.name}');
    _activeFeed = feed;
    _updateTaskPriorities();
    _processQueue(); // Re-evaluate queue processing if active feed changed
  }

  void _updateTaskPriorities() {
    _tasks.removeAll().forEach((task) {
      _tasks.add(task.copyWith(priority: _activeFeed == task.feed ? activeFeedPriority : inactiveFeedPriority));
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
      _logger.d('Task for ${task.uri} already in queue. Skipping.');
      return;
    }

    task.priority = (task.feed == _activeFeed) ? activeFeedPriority : inactiveFeedPriority;
    _tasks.add(task);
    _logger.d('Task submitted for ${task.uri} from feed ${task.feed.identifier}. Queue size: ${_tasks.length}');
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return; // Already processing
    _isProcessing = true;
    _logger.d('Processing queue. Queue size: ${_tasks.length}');
    final newTasks = <DownloadTask>[];

    while (_tasks.isNotEmpty) {
      var task = _tasks.removeFirst();
      if (task.status == DownloadTaskStatus.pending) {
        // Try to acquire a pool resource. If pool is full, withResource will wait.
        // We want to submit to the pool and let it manage, not block _processQueue.
        // So, we don't await the withResource call here directly in the loop
        // that would make _processQueue sequential for task submission to pool.
        // Instead, we launch it and let the pool handle concurrency.

        _pool
            .withResource(() => _executeTask(task))
            .then((_) {
              // This 'then' block executes after _executeTask is fully done
              // (either success or failure handled within _executeTask).
              // It's mainly for pool resource management.
            })
            .catchError((e, s) {
              // This catchError is for unexpected errors from _pool.withResource itself,
              // or if _executeTask re-throws an error not caught internally.
              _logger.e('Error from pool for task ${task.uri}: $e', error: e, stackTrace: s);
              // Ensure task is marked as failed and removed if not already
              if (task.status != DownloadTaskStatus.failed && task.status != DownloadTaskStatus.completed) {
                task.status = DownloadTaskStatus.failed;
                task.onError(task, e, s);
              }
              _tasks.remove(task); // Ensure removal on unhandled pool error
            });

        _logger.d('Task ${task.uri} submitted to pool for execution.');
      }
      if (task.status != DownloadTaskStatus.completed && task.status != DownloadTaskStatus.failed) {
        newTasks.add(task);
      }
    }

    _tasks.addAll(newTasks);

    _isProcessing = false;
    _logger.d('Finished a processing pass. Queue size: ${_tasks.length}');
  }

  @override
  Future<void> dispose() async {
    _logger.d('Disposing DownloadManager...');
    _cancelAllPendingTasks(); // Attempt to clean up
    await _pool.close(); // Closes the pool and waits for active tasks to complete
    _logger.d('DownloadManager disposed.');
  }

  bool _areTherePendingActiveFeedTasks() {
    final tasks = _tasks.toList();
    return tasks.any((task) => task.status == DownloadTaskStatus.pending && task.feed == _activeFeed);
  }

  Future<void> _executeTask(DownloadTask task) async {
    _logger.d('Executing task: ${task.uri} for feed ${task.feed.identifier} with priority ${task.priority}');
    if (_activeFeed != task.feed && task.priority > activeFeedPriority && _areTherePendingActiveFeedTasks()) {
      _logger.d('Task ${task.uri} is for an inactive feed, but there are still pending active feed tasks. Skipping.');
      return;
    }
    try {
      // Simulate a check if this feed is still "desired" to be cached.
      // This is a softer check than full cancellation.

      task.status = DownloadTaskStatus.active;

      // Actual caching work// start downloading the embed
      switch (task.post.embed) {
        case EmbedViewVideo():
          await _cacheManager.getFile(task.post.videoUrl);
          break;
        case EmbedViewImage():
          for (String url in task.post.imageUrls) {
            await CachedNetworkImageProvider.defaultCacheManager.downloadFile(url, key: url);
          }
          break;
        case _:
          break;
      }
      await _sqlCache.cachePost(task.post);
      await _sqlCache.cacheFeed(task.feed);
      await _sqlCache.appendPostsToFeed(task.feed, [task.post.uri.toString()]);

      task.status = DownloadTaskStatus.completed;
      _logger.d('Task ${task.uri} completed successfully.');
      task.onComplete(task);
    } catch (e, s) {
      task.status = DownloadTaskStatus.failed;
      _logger.e('Task ${task.uri} failed: $e', error: e, stackTrace: s);
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
