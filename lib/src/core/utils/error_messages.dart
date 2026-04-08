import 'package:spark/src/core/utils/video_upload_exception.dart';

/// Utility for converting exceptions into user-friendly error messages.
/// This prevents exposing internal implementation details to users while still
/// providing helpful feedback.
class ErrorMessages {
  /// Convert an exception to a user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred';
    }

    if (error is VideoUploadException) {
      if (error.isPayloadTooLarge) {
        final uploadSize = error.uploadSizeBytes;
        final limit = error.limitBytes;
        if (uploadSize != null && limit != null) {
          return 'This video is too large to upload '
              '(${_formatBytes(uploadSize)}). Please trim or compress it under '
              '${_formatBytes(limit)} and try again.';
        }
        return 'This video is too large to upload. Please trim or compress it and try again.';
      }
      return 'Unable to upload video. Please try again';
    }

    final errorStr = error.toString().toLowerCase();

    // Upload size errors
    if (errorStr.contains('413') ||
        errorStr.contains('payload too large') ||
        errorStr.contains('too large')) {
      return 'This file is too large to upload. Please trim or compress it and try again.';
    }

    // Network errors
    if (errorStr.contains('socketexception') ||
        errorStr.contains('network') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('failed host lookup')) {
      return 'Unable to connect. Please check your internet connection';
    }

    // Timeout errors
    if (errorStr.contains('timeout')) {
      return 'The request timed out. Please try again';
    }

    // Authentication errors
    if (errorStr.contains('unauthorized') ||
        errorStr.contains('401') ||
        errorStr.contains('authentication') ||
        errorStr.contains('expired token')) {
      return 'Your session has expired. Please sign in again';
    }

    // Permission errors
    if (errorStr.contains('forbidden') || errorStr.contains('403')) {
      return "You don't have permission to perform this action";
    }

    // Not found errors
    if (errorStr.contains('not found') || errorStr.contains('404')) {
      return 'The requested content could not be found';
    }

    // Rate limiting
    if (errorStr.contains('rate limit') ||
        errorStr.contains('429') ||
        errorStr.contains('too many requests')) {
      return 'Too many requests. Please wait a moment and try again';
    }

    // Server errors
    if (errorStr.contains('500') ||
        errorStr.contains('502') ||
        errorStr.contains('503') ||
        errorStr.contains('server error') ||
        errorStr.contains('internal server')) {
      return 'A server error occurred. Please try again later';
    }

    // Format errors
    if (errorStr.contains('format') || errorStr.contains('invalid')) {
      return 'Invalid data format. Please check your input';
    }

    // File/Upload errors
    if (errorStr.contains('file') || errorStr.contains('upload')) {
      return 'Unable to upload file. Please try again';
    }

    // Video processing errors
    if (errorStr.contains('video') && errorStr.contains('processing')) {
      return 'Video processing failed. Please try a different file';
    }

    // Generic fallback - don't expose the raw error
    return 'Something went wrong. Please try again';
  }

  /// Get a user-friendly message for a specific operation failure
  static String getOperationErrorMessage(String operation, dynamic error) {
    // Try to get a specific error message first
    final baseMessage = getUserFriendlyMessage(error);

    // If it's a generic message, we can add operation context
    if (baseMessage == 'Something went wrong. Please try again') {
      switch (operation) {
        case 'follow':
        case 'unfollow':
          return 'Unable to update follow status. Please try again';
        case 'block':
        case 'unblock':
          return 'Unable to update block status. Please try again';
        case 'like':
        case 'unlike':
          return 'Unable to update like status. Please try again';
        case 'post':
          return 'Unable to create post. Please try again';
        case 'delete':
          return 'Unable to delete. Please try again';
        case 'share':
          return 'Unable to share. Please try again';
        case 'report':
          return 'Unable to submit report. Please try again';
        case 'load':
          return 'Unable to load content. Please try again';
        case 'update':
          return 'Unable to save changes. Please try again';
        default:
          return baseMessage;
      }
    }

    return baseMessage;
  }

  static String _formatBytes(int bytes) {
    const mb = 1024 * 1024;
    if (bytes >= mb) {
      final value = bytes / mb;
      final formatted = value >= 10
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);
      return '$formatted MB';
    }
    const kb = 1024;
    if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }
}
