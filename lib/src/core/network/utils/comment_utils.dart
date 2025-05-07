import 'package:sparksocial/src/core/network/models/feed_models.dart';

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

  /// Create a Comment from a Bluesky comment
  static Comment fromBlueskyComment(Map<String, dynamic> post) {
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;
    
    // Extract hashtags from text
    final text = record['text'] as String? ?? '';
    final hashtags = extractHashtags(text);

    // Extract media if available
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;
    List<String> imageUrls = [];

    if (post['embed'] != null) {
      final embed = post['embed'] as Map<String, dynamic>;
      final embedType = embed['\$type'] as String?;

      if (embedType == 'app.bsky.embed.images#view') {
        hasMedia = true;
        mediaType = 'image';
        
        final embedImages = embed['images'] as List<dynamic>?;
        if (embedImages != null && embedImages.isNotEmpty) {
          mediaUrl = embedImages[0]['thumbnail'] as String?;
          
          for (final image in embedImages) {
            final fullsize = image['fullsize'] as String?;
            if (fullsize != null) {
              imageUrls.add(fullsize);
            }
          }
        }
      } else if (embedType == 'app.bsky.embed.video#view') {
        hasMedia = true;
        mediaType = 'video';
        mediaUrl = embed['playlist'] as String?;
      }
    }

    // Extract like URI from viewer object if available
    String? likeUri;
    if (post.containsKey('viewer') && post['viewer'] is Map<String, dynamic>) {
      likeUri = (post['viewer'] as Map<String, dynamic>)['like'] as String?;
    }

    return Comment(
      id: post['uri'] as String? ?? '',
      uri: post['uri'] as String? ?? '',
      cid: post['cid'] as String? ?? '',
      authorDid: author['did'] as String? ?? '',
      username: author['handle'] as String? ?? '',
      profileImageUrl: author['avatar'] as String?,
      text: text,
      createdAt: formatTimeAgo(record['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      likeCount: post['likeCount'] as int? ?? 0,
      replyCount: post['replyCount'] as int? ?? 0,
      hashtags: hashtags,
      hasMedia: hasMedia,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      likeUri: likeUri,
      isSprk: false,
      imageUrls: imageUrls,
    );
  }

  /// Create a Comment from a Spark comment
  static Comment fromSparkComment(Map<String, dynamic> post) {
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;

    // Extract hashtags from text
    final text = record['text'] as String? ?? '';
    final hashtags = extractHashtags(text);

    // Extract media if available
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;
    List<String> imageUrls = [];

    if (post['embed'] != null) {
      final embedType = post['embed']['\$type'] as String?;
      if (embedType == 'so.sprk.embed.images#view') {
        hasMedia = true;
        mediaType = 'image';

        // Extract all image URLs
        final images = post['embed']['images'] as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          mediaUrl = images[0]['thumb'] as String?;

          // Add all fullsize images to imageUrls
          for (final image in images) {
            final fullsize = image['fullsize'] as String?;
            if (fullsize != null) {
              imageUrls.add(fullsize);
            }
          }
        }
      } else if (embedType == 'so.sprk.embed.video#view') {
        hasMedia = true;
        mediaType = 'video';
        mediaUrl = post['embed']['playlist'] as String?;
      }
    }

    // Extract like URI from viewer object if available
    String? likeUri;
    if (post.containsKey('viewer') && post['viewer'] is Map<String, dynamic>) {
      likeUri = (post['viewer'] as Map<String, dynamic>)['like'] as String?;
    }
    
    return Comment(
      id: post['uri'] as String? ?? '',
      uri: post['uri'] as String? ?? '',
      cid: post['cid'] as String? ?? '',
      authorDid: author['did'] as String? ?? '',
      username: author['handle'] as String? ?? '',
      profileImageUrl: author['avatar'] as String?,
      text: text,
      createdAt: formatTimeAgo(post['indexedAt'] as String? ?? DateTime.now().toIso8601String()),
      likeCount: post['likeCount'] as int? ?? 0,
      replyCount: post['replyCount'] as int? ?? 0,
      hashtags: hashtags,
      hasMedia: hasMedia,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      likeUri: likeUri,
      isSprk: true,
      imageUrls: imageUrls,
    );
  }
  
  /// Check if a comment is liked based on whether there's a likeUri
  static bool isLiked(Comment comment) => comment.likeUri != null;
} 