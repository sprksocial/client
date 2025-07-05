import 'package:atproto/core.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart'; // For PostView, Feed

const int activeFeedPriority = 1;
const int inactiveFeedPriority = 10;

enum DownloadTaskStatus { pending, submitted, active, completed, failed }

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

abstract class DownloadManagerInterface {
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

  bool get poolFull;
}
