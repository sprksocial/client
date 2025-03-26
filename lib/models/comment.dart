import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/bluesky.dart';

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
  final String? likeUri;
  final bool isSprk;
  final List<Comment> replies;

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
      final embedType = '${embed.runtimeType}';
      if (embedType.contains('EmbedImages')) {
        hasMedia = true;
        mediaType = 'image';
        mediaUrl = 'https://cdn.justdavi.dev/runnig.png';

        //mediaUrl = embed.images[0].fullsize;
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

    if (post['embed'] != null) {
      final embedType = post['embed']['\$type'] as String?;
      if (embedType == 'so.sprk.embed.images#view') {
        hasMedia = true;
        mediaType = 'image';
        mediaUrl = post['embed']['images'][0]['fullsize'] as String?;
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
    );
  }

  bool get isLiked => likeUri != null;
}