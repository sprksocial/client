import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/features/upload/ui/widgets/camera/models/camera_mode.dart';

part 'create_video_state.freezed.dart';

/// State for video creation screen
@freezed
class CreateVideoState with _$CreateVideoState {
  const factory CreateVideoState({
    /// Current camera mode (photo or video)
    @Default(CameraMode.video) CameraMode mode,
    
    /// Whether video recording is in progress
    @Default(false) bool isRecording,
    
    /// Current recording progress (0.0 to 1.0)
    @Default(0.0) double recordingProgress,
    
    /// Current recording time display text
    @Default('00:00 / 03:00') String recordingTimeText,
    
    /// Recording time in seconds
    @Default(0) int recordingSeconds,
    
    /// Max recording time in seconds
    @Default(180) int maxRecordingSeconds,  // 3 minutes
    
    /// Whether camera permission is denied
    @Default(false) bool cameraPermissionDenied,
    
    /// Whether to show auth prompt
    @Default(false) bool showAuthPrompt,
    
    /// Error message, if any
    String? error,
  }) = _CreateVideoState;
  
  /// Factory for initial state
  factory CreateVideoState.initial() => const CreateVideoState();
} 