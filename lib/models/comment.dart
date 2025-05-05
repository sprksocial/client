import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/services/identity_service.dart';
import 'package:sparksocial/services/profile_service.dart';

class Comment {
  final String id;
  final String uri;
  final String cid;
  final String authorDid;
  final String username;
  final String? profileImageUrl;
  final String text;
  final String createdAt;
  final int likeCount;
  final int replyCount;
  final List<String> hashtags;
  final bool hasMedia;
  final String? mediaType;
  final String? mediaUrl;
  String? likeUri;
  final bool isSprk;
  final List<Comment> replies;
  final List<String> imageUrls;

  Comment({
    required this.id,
    required this.uri,
    required this.cid,
    required this.authorDid,
    required this.username,
    this.profileImageUrl,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.replyCount = 0,
    this.hashtags = const [],
    this.hasMedia = false,
    this.mediaType,
    this.mediaUrl,
    this.likeUri,
    this.isSprk = false,
    this.replies = const [],
    this.imageUrls = const [],
  });

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

  /// Create a Comment from a Bluesky comment (from app.bsky.feed.getPostThread)
  static Comment fromBlueskyComment(Post post) {
    // Extract hashtags from text
    final text = post.record.text;
    List<String> hashtags = [];
    final matches = RegExp(r'#(\w+)').allMatches(text);
    if (matches.isNotEmpty) {
      hashtags = matches.map((m) => m.group(1)!).toList();
    }

    // Extract media if available
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;

    final embed = post.embed?.data;
    if (embed != null) {
      if (embed is EmbedViewImages) {
        hasMedia = true;
        mediaType = 'image';
        mediaUrl = embed.images[0].thumbnail;
      } else if (embed is EmbedVideoView) {
        hasMedia = true;
        mediaType = 'video';
        mediaUrl = embed.playlist;
      }
    }

    return Comment(
      id: post.uri.toString(),
      uri: post.uri.toString(),
      cid: post.cid,
      authorDid: post.author.did,
      username: post.author.handle,
      profileImageUrl: post.author.avatar,
      text: text,
      createdAt: formatTimeAgo(post.record.createdAt.toString()),
      likeCount: post.likeCount,
      replyCount: post.replyCount,
      hashtags: hashtags,
      hasMedia: hasMedia,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      likeUri: post.viewer.like?.toString(),
      isSprk: false,
      replies: [],
      imageUrls: [],
    );
  }

  /// Create a Comment from a Spark comment
  static Comment fromSparkComment(Map<String, dynamic> post) {
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;

    // Extract hashtags from text
    final text = record['text'] as String? ?? '';
    List<String> hashtags = [];
    final matches = RegExp(r'#(\w+)').allMatches(text);
    if (matches.isNotEmpty) {
      hashtags = matches.map((m) => m.group(1)!).toList();
    }

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
      replies: [],
      imageUrls: imageUrls,
    );
  }

  /// Create a Comment from a Spark record (not a full post object)
  static Future<Comment> fromSparkCommentRecord(Map<String, dynamic> record, String uri, ProfileService profileService) async {
    // Extract hashtags from text
    final text = record['text'] as String? ?? '';
    List<String> hashtags = [];
    final matches = RegExp(r'#(\w+)').allMatches(text);
    if (matches.isNotEmpty) {
      hashtags = matches.map((m) => m.group(1)!).toList();
    }

    // Extract media if available
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;
    List<String> imageUrls = [];

    if (record['embed'] != null && record['embed'] is Map<String, dynamic>) {
      final embedType = record['embed']['\$type'] as String?;
      if (embedType == 'so.sprk.embed.images#view') {
        hasMedia = true;
        mediaType = 'image';

        // Extract all image URLs
        final images = record['embed']['images'] as List<dynamic>?;
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
        mediaUrl = record['embed']['playlist'] as String?;
      }
    }

    // Extract like URI from viewer object if available
    String? likeUri;
    if (record.containsKey('viewer') && record['viewer'] is Map<String, dynamic>) {
      likeUri = (record['viewer'] as Map<String, dynamic>)['like'] as String?;
    }

    // Extract authorDid from record or from uri
    String authorDid = '';
    final match = RegExp(r'at://([^/]+)/').firstMatch(uri);
    if (match != null && match.groupCount >= 1) {
      authorDid = match.group(1)!;
    }
    final identityService = CachedIdentityService();
    final handle = await identityService.resolveDidToHandle(authorDid);
    if (handle == null) {
      throw Exception('No handle found for author did: $authorDid');
    }

    // Get profile information for avatar
    final profile = await profileService.getProfile(authorDid);
    final avatarUrl = profile?.avatarUrl;

    return Comment(
      id: record['uri'] as String? ?? '',
      uri: record['uri'] as String? ?? '',
      cid: record['cid'] as String? ?? '',
      authorDid: authorDid,
      username: profile!.displayName ?? profile.did,
      profileImageUrl: avatarUrl,
      text: text,
      createdAt: formatTimeAgo(
        record['indexedAt'] as String? ?? record['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      likeCount: record['likeCount'] as int? ?? 0,
      replyCount: record['replyCount'] as int? ?? 0,
      hashtags: hashtags,
      hasMedia: hasMedia,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      likeUri: likeUri,
      isSprk: true,
      replies: [],
      imageUrls: imageUrls,
    );
  }

  /// Create a Comment from a Bluesky record (not a full post object)
  static Future<Comment> fromBlueskyCommentRecord(Map<String, dynamic> record, String uri, ProfileService profileService) async {
    // Extract hashtags from text
    final text = record['text'] as String? ?? '';
    List<String> hashtags = [];
    final matches = RegExp(r'#(\w+)').allMatches(text);
    if (matches.isNotEmpty) {
      hashtags = matches.map((m) => m.group(1)!).toList();
    }

    // Extract media if available
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;
    List<String> imageUrls = [];

    if (record['embed'] != null && record['embed'] is Map<String, dynamic>) {
      final embedType = record['embed']['\$type'] as String?;
      if (embedType == 'app.bsky.embed.images#view') {
        hasMedia = true;
        mediaType = 'image';
        final images = record['embed']['images'] as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          mediaUrl = images[0]['thumb'] as String?;
          for (final image in images) {
            final fullsize = image['fullsize'] as String?;
            if (fullsize != null) {
              imageUrls.add(fullsize);
            }
          }
        }
      } else if (embedType == 'app.bsky.embed.video#view') {
        hasMedia = true;
        mediaType = 'video';
        mediaUrl = record['embed']['playlist'] as String?;
      }
    }

    // Extract like URI from viewer object if available
    String? likeUri;
    if (record.containsKey('viewer') && record['viewer'] is Map<String, dynamic>) {
      likeUri = (record['viewer'] as Map<String, dynamic>)['like'] as String?;
    }

    // Extract authorDid from record or from uri
    String authorDid = '';
    final match = RegExp(r'at://([^/]+)/').firstMatch(uri);
    if (match != null && match.groupCount >= 1) {
      authorDid = match.group(1)!;
    }

    // Get profile information
    final profile = await profileService.getProfile(authorDid);
    if (profile == null) {
      throw Exception('No profile found for author did: $authorDid');
    }

    return Comment(
      id: uri,
      uri: uri,
      cid: record['cid'] as String? ?? '',
      authorDid: authorDid,
      username: profile.displayName ?? profile.did,
      profileImageUrl: profile.avatarUrl,
      text: text,
      createdAt: formatTimeAgo(
        record['indexedAt'] as String? ?? record['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      likeCount: record['likeCount'] as int? ?? 0,
      replyCount: record['replyCount'] as int? ?? 0,
      hashtags: hashtags,
      hasMedia: hasMedia,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      likeUri: likeUri,
      isSprk: false,
      replies: [],
      imageUrls: imageUrls,
    );
  }

  bool get isLiked => likeUri != null;
}
