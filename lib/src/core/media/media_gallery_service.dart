abstract interface class MediaGalleryService {
  Future<void> saveImages(List<String> imagePaths);

  Future<void> saveVideo(String videoPath);
}

final class MediaGalleryPermissionDeniedException implements Exception {
  const MediaGalleryPermissionDeniedException();
}
