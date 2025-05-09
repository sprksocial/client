import 'package:camera/camera.dart';

/// Interface defining camera operations
abstract interface class CameraRepositoryInterface {
  /// Get the camera controller
  CameraController? get controller;
  
  /// Check if camera is initialized
  bool get isInitialized;
  
  /// Check if camera is recording
  bool get isRecording;
  
  /// Initialize the camera
  Future<void> initCamera();
  
  /// Switch between front and back camera
  Future<void> flipCamera();
  
  /// Take a photo
  Future<XFile?> takePhoto();
  
  /// Start video recording
  Future<bool> startVideoRecording();
  
  /// Stop video recording
  Future<XFile?> stopVideoRecording();
  
  /// Dispose camera resources
  Future<void> dispose();
} 