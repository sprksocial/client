import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/upload/data/models/upload_task.dart';
import 'package:sparksocial/src/features/upload/data/repositories/upload_repository.dart';

class UploadRepositoryImpl implements UploadRepository {
  final _logger = GetIt.instance<LogService>().getLogger('VideoRepository');
  
  // Task management
  final Map<String, UploadTask> _tasks = {};
  bool _isAnyTaskActive = false;
  bool _isAnyTaskCompleted = false;
  Timer? _completedTasksTimer;
  
  @override
  String registerTask(String type) {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    _tasks[id] = UploadTask(id: id, type: type);
    _logger.d('Registered upload task: $id, type: $type');
    return id;
  }

  @override
  void startTask(String id) {
    if (_tasks.containsKey(id)) {
      _logger.d('Starting upload task: $id');
      _tasks[id] = _tasks[id]!.copyWith(status: UploadStatus.uploading);
      _updateActiveStatus();
    } else {
      _logger.w('Attempted to start non-existent task: $id');
    }
  }

  @override
  void completeTask(String id) {
    if (_tasks.containsKey(id)) {
      _logger.d('Completing upload task: $id');
      _tasks[id] = _tasks[id]!.copyWith(status: UploadStatus.completed);
      _updateActiveStatus();
      _updateCompletedStatus();
      _setupCompletedTasksCleanup();
    } else {
      _logger.w('Attempted to complete non-existent task: $id');
    }
  }

  @override
  void failTask(String id, String errorMessage) {
    if (_tasks.containsKey(id)) {
      _logger.e('Failed upload task: $id, error: $errorMessage');
      _tasks[id] = _tasks[id]!.copyWith(
        status: UploadStatus.error,
        errorMessage: errorMessage
      );
      _updateActiveStatus();
    } else {
      _logger.w('Attempted to fail non-existent task: $id');
    }
  }

  @override
  void clearCompletedTasks() {
    _tasks.removeWhere((_, task) => task.status == UploadStatus.completed);
    _updateCompletedStatus();
    _logger.d('Cleared completed tasks');
  }

  @override
  bool get isAnyTaskActive => _isAnyTaskActive;

  @override
  bool get isAnyTaskCompleted => _isAnyTaskCompleted;

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
      _logger.d('Auto-clearing completed tasks');
      clearCompletedTasks();
    });
  }
  
  void dispose() {
    _completedTasksTimer?.cancel();
  }
} 