import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/upload/data/models/upload_task.dart';
import 'package:get_it/get_it.dart';

part 'upload_provider.g.dart';

/// Notifier for managing upload tasks
@Riverpod(keepAlive: true)
class UploadNotifier extends _$UploadNotifier {
  late final LogService _logService;
  final Map<String, UploadTask> _tasks = {};
  Timer? _completedTasksTimer;
  
  @override
  AsyncValue<void> build() {
    _logService = GetIt.instance<LogService>();
    final logger = _logService.getLogger('UploadNotifier');
    logger.d('UploadNotifier initialized');
    
    ref.onDispose(() {
      _completedTasksTimer?.cancel();
      logger.d('UploadNotifier disposed');
    });
    
    return const AsyncData(null);
  }
  
  /// Register a new upload task
  String registerTask(String type) {
    final logger = _logService.getLogger('UploadNotifier');
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    _tasks[id] = UploadTask(id: id, type: type);
    logger.d('Registered upload task: $id, type: $type');
    state = const AsyncData(null);
    return id;
  }

  /// Start an upload task
  void startTask(String id) {
    final logger = _logService.getLogger('UploadNotifier');
    if (_tasks.containsKey(id)) {
      logger.d('Starting upload task: $id');
      _tasks[id] = _tasks[id]!.copyWith(status: UploadStatus.uploading);
      state = const AsyncData(null);
    } else {
      logger.w('Attempted to start non-existent task: $id');
    }
  }

  /// Complete an upload task
  void completeTask(String id) {
    final logger = _logService.getLogger('UploadNotifier');
    if (_tasks.containsKey(id)) {
      logger.d('Completing upload task: $id');
      _tasks[id] = _tasks[id]!.copyWith(status: UploadStatus.completed);
      _setupCompletedTasksCleanup();
      state = const AsyncData(null);
    } else {
      logger.w('Attempted to complete non-existent task: $id');
    }
  }

  /// Mark a task as failed
  void failTask(String id, String errorMessage) {
    final logger = _logService.getLogger('UploadNotifier');
    if (_tasks.containsKey(id)) {
      logger.e('Failed upload task: $id, error: $errorMessage');
      _tasks[id] = _tasks[id]!.copyWith(
        status: UploadStatus.error,
        errorMessage: errorMessage
      );
      state = const AsyncData(null);
    } else {
      logger.w('Attempted to fail non-existent task: $id');
    }
  }

  /// Clear all completed tasks
  void clearCompletedTasks() {
    final logger = _logService.getLogger('UploadNotifier');
    _tasks.removeWhere((_, task) => task.status == UploadStatus.completed);
    logger.d('Cleared completed tasks');
    state = const AsyncData(null);
  }

  /// Check if any task is active
  bool get isAnyTaskActive => 
    _tasks.values.any((task) => task.status == UploadStatus.uploading);

  /// Check if any task is completed
  bool get isAnyTaskCompleted => 
    _tasks.values.any((task) => task.status == UploadStatus.completed);

  void _setupCompletedTasksCleanup() {
    final logger = _logService.getLogger('UploadNotifier');
    // Cancel existing timer if there is one
    _completedTasksTimer?.cancel();

    // Set up new timer to clear completed tasks after 3 seconds
    _completedTasksTimer = Timer(const Duration(seconds: 3), () {
      logger.d('Auto-clearing completed tasks');
      clearCompletedTasks();
    });
  }
} 