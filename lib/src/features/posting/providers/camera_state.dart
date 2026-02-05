import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_state.freezed.dart';

@freezed
abstract class CameraState with _$CameraState {
  const factory CameraState({
    CameraController? controller,
    @Default([]) List<CameraDescription> cameras,
    @Default(0) int selectedCameraIndex,
    @Default(false) bool isInitialized,
    @Default(false) bool isRecording,
    @Default(false) bool isFlipping,
    @Default(0) int initAttempts,
    String? error,
  }) = _CameraState;
}
