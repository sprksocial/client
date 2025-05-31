import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:pool/pool.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/feed/providers/feed_state.dart';
import 'package:collection/collection.dart';

const int activeFeedPriority = 1;
const int inactiveFeedPriority = 10;

enum DownloadTaskStatus { pending, active, completed, failed }

class DownloadTask {
  DownloadTask({
    required this.uri,
    required this.feed,
    required this.onComplete,
    required this.onError,
    this.priority = inactiveFeedPriority,
    this.status = DownloadTaskStatus.pending,
  }) : submittedAt = DateTime.now();

  final AtUri uri;
  final Feed feed;
  final DateTime submittedAt;
  final Function(DownloadTask) onComplete;
  final Function(DownloadTask, dynamic error, StackTrace stackTrace) onError;
  DownloadTaskStatus status;
  int priority; // lower number = higher priority

  DownloadTask copyWith({int? priority, DownloadTaskStatus? status}) {
    return DownloadTask(
      uri: uri,
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
  }

  late final SQLCache _sqlCache;
  late final SparkLogger _logger;
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

  void submitTask(DownloadTask task) {
    // Prevent duplicate tasks for the same post if one is already pending/active
    if (_tasks.contains(task)) {
      _logger.d('Task for ${task.uri} already in queue. Skipping.');
      return;
    }

    task.priority = (task.feed == _activeFeed) ? activeFeedPriority : inactiveFeedPriority;
    _tasks.add(task);
    _logger.d('Task submitted for ${task.uri} from feed ${task.feed.name}. Queue size: ${_tasks.length}');
    //    _processQueue();
  }
}
