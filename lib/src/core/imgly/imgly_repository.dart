import 'package:imgly_camera/imgly_camera.dart';
import 'package:imgly_editor/imgly_editor.dart';

abstract class IMGLYRepository {
  Future<CameraResult?> openCamera({String? userID});

  Future<CameraResult?> openCameraReaction({required String url, String? userID});

  Future<EditorResult?> openVideoEditor({String? handle, String? userID, Source? source});

  Future<EditorResult?> openImageEditor({String? userID, Source? source});
}
