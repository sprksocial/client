import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;
  
  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  
  // Initialize camera
  Future<void> initCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras found');
        throw Exception('No cameras found');
      }
      
      // Initialize controller with the first camera
      await _initCameraController(_cameras![_selectedCameraIndex]);
    } catch (e) {
      _isInitialized = false;
      debugPrint('Error initializing camera: $e');
      // Don't rethrow here to allow graceful failure
    }
  }
  
  // Initialize controller with specified camera
  Future<void> _initCameraController(CameraDescription camera) async {
    // Dispose previous controller if exists
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
    
    try {
      // Create new controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Initialize controller
      if (_controller != null) {
        await _controller!.initialize();
        // Add a small delay to ensure camera is fully initialized
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Additional verification
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
      // Don't rethrow here to allow graceful failure
    }
  }
  
  // Switch camera
  Future<void> flipCamera() async {
    if (_cameras == null || _cameras!.length <= 1) {
      return;
    }
    
    try {
      // Toggle between front and back camera
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      await _initCameraController(_cameras![_selectedCameraIndex]);
    } catch (e) {
      debugPrint('Error flipping camera: $e');
    }
  }
  
  // Take photo
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
  
  // Start video recording
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
  
  // Stop video recording
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
  
  // Clean up resources
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