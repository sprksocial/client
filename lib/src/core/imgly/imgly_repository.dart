import 'package:imgly_camera/imgly_camera.dart';
import 'package:imgly_editor/imgly_editor.dart';

abstract class IMGLYRepository {
  Future<CameraResult?> openCamera({String? userID, Map<String, dynamic>? metadata});

  Future<CameraResult?> openCameraReaction({required String url, String? userID, Map<String, dynamic>? metadata});

  Future<EditorResult?> openVideoEditor({String? handle, String? userID, Source? source, Map<String, dynamic>? metadata});

  Future<EditorResult?> openImageEditor({String? userID, Source? source, Map<String, dynamic>? metadata});
}
