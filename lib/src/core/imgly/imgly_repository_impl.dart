import 'package:imgly_camera/imgly_camera.dart';
import 'package:imgly_editor/imgly_editor.dart';
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/imgly/imgly_repository.dart';

/// Android UI: android\app\src\main\kotlin\so\sprk\app\MainActivity.kt
/// iOS UI: ios\Runner\AppDelegate.swift
class IMGLYRepositoryImpl implements IMGLYRepository {
  @override
  Future<CameraResult?> openCamera({String? userID, Map<String, dynamic>? metadata}) async {
    final settings = CameraSettings(license: AppConfig.license, userId: userID);

    return IMGLYCamera.openCamera(settings, metadata: metadata);
  }

  @override
  Future<CameraResult?> openCameraReaction({required String url, String? userID, Map<String, dynamic>? metadata}) async {
    final settings = CameraSettings(license: AppConfig.license, userId: userID);

    return IMGLYCamera.openCamera(settings, video: url, metadata: metadata);
  }

  @override
  Future<EditorResult?> openVideoEditor({String? handle, String? userID, Source? source, Map<String, dynamic>? metadata}) async {
    final settings = EditorSettings(license: AppConfig.license, userId: userID);

    return IMGLYEditor.openEditor(settings: settings, source: source, preset: EditorPreset.video, metadata: metadata);
  }

  @override
  Future<EditorResult?> openImageEditor({String? userID, Source? source, Map<String, dynamic>? metadata}) async {
    final settings = EditorSettings(license: AppConfig.license, userId: userID);

    return IMGLYEditor.openEditor(settings: settings, preset: EditorPreset.photo, source: source, metadata: metadata);
  }
}
