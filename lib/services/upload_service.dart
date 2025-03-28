import 'dart:async';

import 'package:flutter/foundation.dart';

enum UploadStatus { idle, uploading, completed, error }

class UploadTask {
  final String id;
  final String type;
  UploadStatus status;
  String? errorMessage;

  UploadTask({required this.id, required this.type, this.status = UploadStatus.idle, this.errorMessage});
}

class UploadService extends ChangeNotifier {
  final Map<String, UploadTask> _tasks = {};
  bool _isAnyTaskActive = false;
  bool _isAnyTaskCompleted = false;
  Timer? _completedTasksTimer;

  bool get isAnyTaskActive => _isAnyTaskActive;
  bool get isAnyTaskCompleted => _isAnyTaskCompleted;

  // Register a new upload task
  String registerTask(String type) {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    _tasks[id] = UploadTask(id: id, type: type);
    return id;
  }

  // Start an upload task
  void startTask(String id) {
    if (_tasks.containsKey(id)) {
      _tasks[id]!.status = UploadStatus.uploading;
      _updateActiveStatus();
      notifyListeners();
    }
  }

  // Complete an upload task
  void completeTask(String id) {
    if (_tasks.containsKey(id)) {
      _tasks[id]!.status = UploadStatus.completed;
      _updateActiveStatus();
      _updateCompletedStatus();

      // Set up auto-cleanup for completed tasks after delay
      _setupCompletedTasksCleanup();
      notifyListeners();
    }
  }

  // Mark a task as failed
  void failTask(String id, String errorMessage) {
    if (_tasks.containsKey(id)) {
      _tasks[id]!.status = UploadStatus.error;
      _tasks[id]!.errorMessage = errorMessage;
      _updateActiveStatus();
      notifyListeners();
    }
  }

  // Clear all completed tasks
  void clearCompletedTasks() {
    _tasks.removeWhere((_, task) => task.status == UploadStatus.completed);
    _updateCompletedStatus();
    notifyListeners();
  }

  void _updateActiveStatus() {
    _isAnyTaskActive = _tasks.values.any((task) => task.status == UploadStatus.uploading);
  }

  void _updateCompletedStatus() {
    _isAnyTaskCompleted = _tasks.values.any((task) => task.status == UploadStatus.completed);
  }

  void _setupCompletedTasksCleanup() {
    // Cancel existing timer if there is one
    _completedTasksTimer?.cancel();

    // Set up new timer to clear completed tasks after 3 seconds
    _completedTasksTimer = Timer(const Duration(seconds: 3), () {
      clearCompletedTasks();
    });
  }

  @override
  void dispose() {
    _completedTasksTimer?.cancel();
    super.dispose();
  }
}
