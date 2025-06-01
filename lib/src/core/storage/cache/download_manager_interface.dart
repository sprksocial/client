import 'package:atproto/core.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart'; // For PostView, Feed

// --- Constants and Enums (can be defined here or imported if in separate files) ---
const int activeFeedPriority = 1;
const int inactiveFeedPriority = 10;

enum DownloadTaskStatus { pending, active, completed, failed }

// --- DownloadTask Data Class (as provided, used by the interface) ---
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

// --- Contract Interface for DownloadManager ---

/// Defines the contract for a download manager responsible for
/// queuing and processing download tasks for feed content.
abstract class IDownloadManager {

  /// Sets the currently active feed. Tasks related to the active feed
  /// may be prioritized.
  ///
  /// - [feed]: The feed to be marked as active
  void setActiveFeed(Feed feed);

  /// Submits a new download task to the manager's queue.
  /// The manager will handle its prioritization and execution.
  ///
  /// - [task]: The [DownloadTask] to be submitted.
  void submitTask(DownloadTask task);

  /// Disposes of the download manager, typically cancelling pending tasks
  /// and releasing any acquired resources.
  ///
  /// This should be called when the manager is no longer needed to prevent
  /// resource leaks and ensure graceful shutdown of ongoing operations.
  Future<void> dispose();

  /// Checks if there are any pending tasks specifically for the currently
  /// active feed.
  ///
  /// Returns `true` if there are pending tasks for the active feed,
  /// `false` otherwise.
  bool areTherePendingActiveFeedTasks();

  // Note: Properties like `_activeFeed` (if it were public) would be defined as getters:
  // Feed? get activeFeed;
  //
  // The `_pool`, `_sqlCache`, `_logger`, `_cacheManager`, `_tasks`, `_isProcessing`
  // are internal implementation details and thus not part of the public interface.
  //
  // Methods like `_updateTaskPriorities`, `_cancelAllPendingTasks`, `_processQueue`, `_executeTask`
  // are also internal and not part of the interface.
}
