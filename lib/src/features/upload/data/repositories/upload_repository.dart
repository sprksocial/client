/// Interface for video-related API operations
abstract class UploadRepository {
  
  /// Register a new upload task
  /// 
  /// [type] The type of task
  /// Returns the task ID
  String registerTask(String type);
  
  /// Start an upload task
  /// 
  /// [id] The task ID
  void startTask(String id);
  
  /// Complete an upload task
  /// 
  /// [id] The task ID
  void completeTask(String id);
  
  /// Mark a task as failed
  /// 
  /// [id] The task ID
  /// [errorMessage] The error message
  void failTask(String id, String errorMessage);
  
  /// Check if any task is active
  bool get isAnyTaskActive;
  
  /// Check if any task is completed
  bool get isAnyTaskCompleted;
  
  /// Clear all completed tasks
  void clearCompletedTasks();
} 