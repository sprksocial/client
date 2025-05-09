import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/camera/data/repositories/camera_repository_interface.dart';

part 'camera_provider.g.dart';

@riverpod
class Camera extends _$Camera {
  @override
  CameraRepositoryInterface build() {
    final repository = GetIt.instance<CameraRepositoryInterface>();
    
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