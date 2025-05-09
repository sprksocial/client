import 'dart:async';

import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/camera/data/repositories/camera_repository_interface.dart';

class CameraRepository implements CameraRepositoryInterface {
  CameraRepository() {
    _logger = GetIt.instance<LogService>().getLogger('CameraRepository');
  }

  late final SparkLogger _logger;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;
  int _initAttempts = 0;
  static const int _maxInitAttempts = 3;

  @override
  CameraController? get controller => _controller;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<void> initCamera() async {
    _initAttempts++;

    try {
      if (_cameras == null || _cameras!.isEmpty) {
        _cameras = await availableCameras();
        if (_cameras == null || _cameras!.isEmpty) {
          _logger.w('No cameras found');
          throw Exception('No cameras found');
        }
      }

      await _initCameraController(_cameras![_selectedCameraIndex]);

      // Reset attempts counter on success
      _initAttempts = 0;
    } catch (e) {
      _isInitialized = false;
      _logger.e('Error initializing camera (attempt $_initAttempts)', error: e);

      // If we hit a permissions error, we need to propagate it so the UI can handle it
      final String errorMsg = e.toString().toLowerCase();
      final bool isPermissionError =
          errorMsg.contains('permission') || errorMsg.contains('denied') || errorMsg.contains('access');

      if (isPermissionError || _initAttempts >= _maxInitAttempts) {
        // Reset attempts counter and rethrow to let caller handle it
        _initAttempts = 0;
        rethrow;
      } else {
        // Try once more with a delay if it's not a permission error
        await Future.delayed(const Duration(milliseconds: 500));
        return initCamera();
      }
    }
  }

  Future<void> _initCameraController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }

    try {
      _controller = CameraController(
        camera, 
        ResolutionPreset.high, 
        enableAudio: true, 
        imageFormatGroup: ImageFormatGroup.jpeg
      );

      if (_controller != null) {
        // Wait for controller to initialize
        await _controller!.initialize();

        // Add a small delay to ensure everything is properly set up
        await Future.delayed(const Duration(milliseconds: 300));

        if (_controller != null && _controller!.value.isInitialized) {
          _isInitialized = true;
          _logger.d('Camera successfully initialized');
        } else {
          _isInitialized = false;
          _logger.w('Camera initialization incomplete');
          throw Exception('Camera controller initialized but camera not ready');
        }
      }
    } catch (e) {
      _isInitialized = false;
      _logger.e('Error initializing camera controller', error: e);
      rethrow;
    }
  }

  @override
  Future<void> flipCamera() async {
    if (_cameras == null || _cameras!.length <= 1) {
      return;
    }

    try {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      await _initCameraController(_cameras![_selectedCameraIndex]);
    } catch (e) {
      _logger.e('Error flipping camera', error: e);
    }
  }

  @override
  Future<XFile?> takePhoto() async {
    if (_controller == null || !_isInitialized) {
      return null;
    }

    try {
      final XFile file = await _controller!.takePicture();
      return file;
    } catch (e) {
      _logger.e('Error taking photo', error: e);
      return null;
    }
  }

  @override
  Future<bool> startVideoRecording() async {
    if (_controller == null || !_isInitialized || _isRecording) {
      return false;
    }

    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      return true;
    } catch (e) {
      _logger.e('Error starting video recording', error: e);
      return false;
    }
  }

  @override
  Future<XFile?> stopVideoRecording() async {
    if (_controller == null || !_isInitialized || !_isRecording) {
      return null;
    }

    try {
      final XFile file = await _controller!.stopVideoRecording();
      _isRecording = false;
      return file;
    } catch (e) {
      _logger.e('Error stopping video recording', error: e);
      _isRecording = false;
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      if (_controller != null) {
        if (_isRecording) {
          await stopVideoRecording();
        }
        await _controller!.dispose();
        _controller = null;
      }
      _isInitialized = false;
    } catch (e) {
      _logger.e('Error disposing camera', error: e);
    }
  }
} 