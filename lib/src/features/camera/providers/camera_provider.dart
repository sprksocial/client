import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/camera/data/repositories/camera_repository.dart';

part 'camera_provider.g.dart';

@riverpod
class Camera extends _$Camera {
  @override
  CameraRepository build() {
    final repository = GetIt.instance<CameraRepository>();
    
    ref.onDispose(() {
      repository.dispose();
    });
    
    return repository;
  }
  
  Future<void> initialize() async {
    await state.initCamera();
  }
  
  Future<void> flipCamera() async {
    await state.flipCamera();
  }
  
  Future<XFile?> takePhoto() async {
    return state.takePhoto();
  }
  
  Future<bool> startVideoRecording() async {
    return state.startVideoRecording();
  }
  
  Future<XFile?> stopVideoRecording() async {
    return state.stopVideoRecording();
  }
} 