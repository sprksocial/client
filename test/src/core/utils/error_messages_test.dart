import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/utils/error_messages.dart';
import 'package:spark/src/core/utils/video_upload_exception.dart';

void main() {
  group('ErrorMessages', () {
    test('describes oversized video uploads with sizes', () {
      const error = VideoUploadException(
        'Video is too large to upload.',
        statusCode: 413,
        uploadSizeBytes: 120 * 1024 * 1024,
        limitBytes: 100 * 1024 * 1024,
      );

      final message = ErrorMessages.getOperationErrorMessage('post', error);

      expect(message, contains('This video is too large to upload'));
      expect(message, contains('120 MB'));
      expect(message, contains('under 100 MB'));
    });

    test('maps raw 413 payload errors to a safe upload message', () {
      final message = ErrorMessages.getOperationErrorMessage(
        'post',
        Exception('Failed to upload video: 413 Payload Too Large'),
      );

      expect(
        message,
        'This file is too large to upload. Please trim or compress it and try again.',
      );
    });
  });
}
