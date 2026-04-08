/// Error raised when the video processing service rejects an upload.
class VideoUploadException implements Exception {
  const VideoUploadException(
    this.message, {
    this.statusCode,
    this.uploadSizeBytes,
    this.limitBytes,
    this.responseBody,
  });

  final String message;
  final int? statusCode;
  final int? uploadSizeBytes;
  final int? limitBytes;
  final String? responseBody;

  bool get isPayloadTooLarge =>
      statusCode == 413 ||
      (uploadSizeBytes != null &&
          limitBytes != null &&
          uploadSizeBytes! > limitBytes!);

  @override
  String toString() => message;
}
