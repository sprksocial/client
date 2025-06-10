import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'upload_state.dart';

part 'upload_provider.g.dart';

@riverpod
class Upload extends _$Upload {
  Timer? _completedTasksTimer;

  @override
  UploadState build() {
    ref.onDispose(() {
      _completedTasksTimer?.cancel();
    });
    
    return const UploadState();
  }

  // Register a new upload task
  String registerTask(String type) {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final UploadTask newTask = UploadTask(id: id, type: type);
    
    state = state.copyWith(
      tasks: {...state.tasks, id: newTask},
    );
    
    return id;
  }

  // Start an upload task
  void startTask(String id) {
    if (state.tasks.containsKey(id)) {
      final UploadTask updatedTask = state.tasks[id]!.copyWith(
        status: UploadStatus.uploading,
      );
      
      state = state.copyWith(
        tasks: {...state.tasks, id: updatedTask},
      );
      
      _updateActiveStatus();
    }
  }

  // Complete an upload task
  void completeTask(String id) {
    if (state.tasks.containsKey(id)) {
      final UploadTask updatedTask = state.tasks[id]!.copyWith(
        status: UploadStatus.completed,
      );
      
      state = state.copyWith(
        tasks: {...state.tasks, id: updatedTask},
      );
      
      _updateActiveStatus();
      _updateCompletedStatus();
      _setupCompletedTasksCleanup();
    }
  }

  // Mark a task as failed
  void failTask(String id, String errorMessage) {
    if (state.tasks.containsKey(id)) {
      final UploadTask updatedTask = state.tasks[id]!.copyWith(
        status: UploadStatus.error,
        errorMessage: errorMessage,
      );
      
      state = state.copyWith(
        tasks: {...state.tasks, id: updatedTask},
      );
      
      _updateActiveStatus();
    }
  }

  // Clear all completed tasks
  void clearCompletedTasks() {
    final Map<String, UploadTask> filteredTasks = Map.fromEntries(
      state.tasks.entries.where((entry) => entry.value.status != UploadStatus.completed),
    );
    
    state = state.copyWith(tasks: filteredTasks);
    _updateCompletedStatus();
  }

  void _updateActiveStatus() {
    final bool isAnyTaskActive = state.tasks.values.any(
      (task) => task.status == UploadStatus.uploading,
    );
    
    state = state.copyWith(isAnyTaskActive: isAnyTaskActive);
  }

  void _updateCompletedStatus() {
    final bool isAnyTaskCompleted = state.tasks.values.any(
      (task) => task.status == UploadStatus.completed,
    );
    
    state = state.copyWith(isAnyTaskCompleted: isAnyTaskCompleted);
  }

  void _setupCompletedTasksCleanup() {
    // Cancel existing timer if there is one
    _completedTasksTimer?.cancel();

    // Set up new timer to clear completed tasks after 3 seconds
    _completedTasksTimer = Timer(const Duration(seconds: 3), () {
      clearCompletedTasks();
    });
  }
} 