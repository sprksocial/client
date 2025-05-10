import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_task.freezed.dart';
part 'upload_task.g.dart';

/// Enum representing the status of an upload task
enum UploadStatus { idle, uploading, completed, error }

/// Model representing an upload task
@freezed
class UploadTask with _$UploadTask {
  /// Creates a new upload task
  const factory UploadTask({
    /// Unique identifier for the task
    required String id,
    
    /// Type of upload task
    required String type,
    
    /// Current status of the task
    @Default(UploadStatus.idle) UploadStatus status,
    
    /// Error message if task failed
    String? errorMessage,
  }) = _UploadTask;

  /// Creates an UploadTask from JSON
  factory UploadTask.fromJson(Map<String, dynamic> json) => _$UploadTaskFromJson(json);
} 