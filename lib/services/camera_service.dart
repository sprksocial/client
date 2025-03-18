import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras found');
        throw Exception('No cameras found');
      }

      await _initCameraController(_cameras![_selectedCameraIndex]);
    } catch (e) {
      _isInitialized = false;
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _initCameraController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }

    try {
      _controller = CameraController(camera, ResolutionPreset.high, enableAudio: true, imageFormatGroup: ImageFormatGroup.jpeg);

      if (_controller != null) {
        await _controller!.initialize();
        await Future.delayed(const Duration(milliseconds: 200));

        if (_controller != null && _controller!.value.isInitialized) {
          _isInitialized = true;
          debugPrint('Camera successfully initialized');
        } else {
          _isInitialized = false;
          debugPrint('Camera initialization incomplete');
        }
      }
    } catch (e) {
      _isInitialized = false;
      debugPrint('Error initializing camera controller: $e');
    }
  }

  Future<void> flipCamera() async {
    if (_cameras == null || _cameras!.length <= 1) {
      return;
    }

    try {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      await _initCameraController(_cameras![_selectedCameraIndex]);
    } catch (e) {
      debugPrint('Error flipping camera: $e');
    }
  }

  Future<XFile?> takePhoto() async {
    if (_controller == null || !_isInitialized) {
      return null;
    }

    try {
      final XFile file = await _controller!.takePicture();
      return file;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  Future<bool> startVideoRecording() async {
    if (_controller == null || !_isInitialized || _isRecording) {
      return false;
    }

    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      return true;
    } catch (e) {
      debugPrint('Error starting video recording: $e');
      return false;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (_controller == null || !_isInitialized || !_isRecording) {
      return null;
    }

    try {
      final XFile file = await _controller!.stopVideoRecording();
      _isRecording = false;
      return file;
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      _isRecording = false;
      return null;
    }
  }

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
      debugPrint('Error disposing camera: $e');
    }
  }
}
