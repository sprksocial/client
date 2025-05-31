import 'package:atproto/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:pool/pool.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';
import 'package:collection/collection.dart';

const int activeFeedPriority = 1;
const int inactiveFeedPriority = 10;

enum DownloadTaskStatus { pending, active, completed, failed }

class DownloadTask {
  DownloadTask({
    required this.uri,
    required this.post,
    required this.feed,
    required this.onComplete,
    required this.onError,
    this.priority = inactiveFeedPriority,
    this.status = DownloadTaskStatus.pending,
  }) : submittedAt = DateTime.now();

  final AtUri uri;
  final PostView post;
  final Feed feed;
  final DateTime submittedAt;
  final Function(DownloadTask) onComplete;
  final Function(DownloadTask, dynamic error, StackTrace stackTrace) onError;
  DownloadTaskStatus status;
  int priority; // lower number = higher priority

  DownloadTask copyWith({int? priority, DownloadTaskStatus? status}) {
    return DownloadTask(
      uri: uri,
      post: post,
      feed: feed,
      onComplete: onComplete,
      onError: onError,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DownloadTask && other.uri == uri;
  }

  @override
  int get hashCode => uri.hashCode;
}

class DownloadManager {
  DownloadManager() : _pool = Pool(FeedState.poolSize) {
    _sqlCache = GetIt.instance<SQLCache>();
    _logger = GetIt.instance<SparkLogger>();
    _cacheManager = GetIt.instance<CacheManagerInterface>();
  }

  late final SQLCache _sqlCache;
  late final SparkLogger _logger;
  late final CacheManagerInterface _cacheManager;
  final Pool _pool;
  final PriorityQueue<DownloadTask> _tasks = PriorityQueue<DownloadTask>((a, b) => a.priority.compareTo(b.priority));

  Feed? _activeFeed;
  bool _isProcessing = false;

  void setActiveFeed(Feed? feed) {
    _logger.d('Setting active feed to: ${feed?.name}');
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

  Future<void> dispose() async {
    _logger.d('Disposing DownloadManager...');
    _cancelAllPendingTasks(); // Attempt to clean up
    await _pool.close(); // Closes the pool and waits for active tasks to complete
    _logger.d('DownloadManager disposed.');
  }

  bool areTherePendingActiveFeedTasks() {
    final tasks = _tasks.toList();
    return tasks.any((task) => task.status == DownloadTaskStatus.pending && task.feed == _activeFeed);
  }

  Future<void> _executeTask(DownloadTask task) async {
    _logger.d('Executing task: ${task.uri} for feed ${task.feed.identifier} with priority ${task.priority}');
    if (_activeFeed != task.feed && task.priority > activeFeedPriority && areTherePendingActiveFeedTasks()) {
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
