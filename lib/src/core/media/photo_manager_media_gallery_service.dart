import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:spark/src/core/media/media_gallery_service.dart';

final class PhotoManagerMediaGalleryService implements MediaGalleryService {
  const PhotoManagerMediaGalleryService();

  @override
  Future<void> saveImages(List<String> imagePaths) async {
    await _requestSaveAccess();
    for (final imagePath in imagePaths) {
      await PhotoManager.editor.saveImageWithPath(imagePath);
    }
  }

  @override
  Future<void> saveVideo(String videoPath) async {
    await _requestSaveAccess();
    await PhotoManager.editor.saveVideo(File(videoPath), title: null);
  }

  Future<void> _requestSaveAccess() async {
    if (Platform.isAndroid) {
      final sdkVersion = int.tryParse(await PhotoManager.systemVersion());
      if (sdkVersion == null || sdkVersion >= 29) return;

      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        throw const MediaGalleryPermissionDeniedException();
      }
      return;
    }

    if (!Platform.isIOS) return;

    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        // The editor reads back the saved asset to return an AssetEntity.
        iosAccessLevel: IosAccessLevel.readWrite,
      ),
    );
    if (!permission.hasAccess) {
      throw const MediaGalleryPermissionDeniedException();
    }
  }
}
