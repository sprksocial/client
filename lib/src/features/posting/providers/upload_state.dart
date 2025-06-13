import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_state.freezed.dart';

enum UploadStatus { idle, uploading, completed, error }

@freezed
class UploadTask with _$UploadTask {
  const factory UploadTask({
    required String id,
    required String type,
    @Default(UploadStatus.idle) UploadStatus status,
    String? errorMessage,
  }) = _UploadTask;
}

@freezed
class UploadState with _$UploadState {
  const factory UploadState({
    @Default({}) Map<String, UploadTask> tasks,
    @Default(false) bool isAnyTaskActive,
    @Default(false) bool isAnyTaskCompleted,
  }) = _UploadState;
} 