import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

/// Helper functions for working with comments
class CommentUtils {
  /// Parse a relative datetime string like "2023-11-19T12:34:56.789Z" and return a user-friendly string
  static String formatTimeAgo(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  /// Extract hashtags from text
  static List<String> extractHashtags(String text) {
    final matches = RegExp(r'#(\w+)').allMatches(text);
    if (matches.isNotEmpty) {
      return matches.map((m) => m.group(1)!).toList();
    }
    return [];
  }
  
  /// Check if a comment is liked based on whether there's a likeUri
  static bool isLiked(Comment comment) => comment.likeUri != null;
} 