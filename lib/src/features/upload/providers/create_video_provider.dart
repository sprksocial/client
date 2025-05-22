import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/upload/data/models/create_video_state.dart';
import 'package:sparksocial/src/features/upload/data/repositories/camera_repository.dart';
import 'package:sparksocial/src/features/upload/ui/widgets/camera/models/camera_mode.dart';

part 'create_video_provider.g.dart';

/// Provider for the create video page
@riverpod
class CreateVideoNotifier extends _$CreateVideoNotifier {
  late final CameraRepository _cameraRepository;
  late final SparkLogger _logger;

  @override
  CreateVideoState build() {
    _cameraRepository = GetIt.instance<CameraRepository>();
    _logger = GetIt.instance<LogService>().getLogger('CreateVideoNotifier');

    return CreateVideoState.initial();
  }

  /// Initialize the camera
  Future<void> initializeCamera() async {
    try {
      await _cameraRepository.initCamera();

      // Reset camera permission denied flag if successful
      if (state.cameraPermissionDenied) {
        state = state.copyWith(cameraPermissionDenied: false);
      }
    } catch (e) {
      _logger.e('Error initializing camera', error: e);

      // Check if it's a permission error
      final String errorMsg = e.toString().toLowerCase();
      final bool isPermissionError =
          errorMsg.contains('permission') || errorMsg.contains('denied') || errorMsg.contains('access');

      state = state.copyWith(
        cameraPermissionDenied: isPermissionError,
        error: isPermissionError ? null : 'Camera initialization failed: ${e.toString()}',
      );
    }
  }

  /// Set camera mode (photo or video)
  void setMode(CameraMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Take a photo
  Future<XFile?> takePhoto() async {
    try {
      final photo = await _cameraRepository.takePhoto();
      return photo;
    } catch (e) {
      _logger.e('Error taking photo', error: e);
      state = state.copyWith(error: 'Failed to take photo: ${e.toString()}');
      return null;
    }
  }

  /// Start video recording
  Future<bool> startVideoRecording() async {
    try {
      final success = await _cameraRepository.startVideoRecording();
      if (success) {
        state = state.copyWith(
          isRecording: true,
          recordingProgress: 0.0,
          recordingTimeText: '00:00 / 03:00',
          recordingSeconds: 0,
        );
      }
      return success;
    } catch (e) {
      _logger.e('Error starting video recording', error: e);
      state = state.copyWith(error: 'Failed to start recording: ${e.toString()}');
      return false;
    }
  }

  /// Stop video recording
  Future<XFile?> stopVideoRecording() async {
    try {
      final video = await _cameraRepository.stopVideoRecording();
      state = state.copyWith(isRecording: false, recordingProgress: 0.0, recordingTimeText: '00:00 / 03:00', recordingSeconds: 0);
      return video;
    } catch (e) {
      _logger.e('Error stopping video recording', error: e);
      state = state.copyWith(isRecording: false, error: 'Failed to stop recording: ${e.toString()}');
      return null;
    }
  }

  /// Increment recording time
  void incrementRecordingTime() {
    final int recordingSeconds = state.recordingSeconds + 1;
    final int maxRecordingSeconds = state.maxRecordingSeconds;
    final double progress = recordingSeconds / maxRecordingSeconds;

    final int minutes = recordingSeconds ~/ 60;
    final int seconds = recordingSeconds % 60;
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    state = state.copyWith(
      recordingSeconds: recordingSeconds,
      recordingProgress: progress,
      recordingTimeText: '$minutesStr:$secondsStr / 03:00',
    );
  }

  /// Reset recording time
  void resetRecordingTime() {
    state = state.copyWith(recordingSeconds: 0, recordingProgress: 0.0, recordingTimeText: '00:00 / 03:00');
  }
}
