import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/bluesky.dart';

/// A unified model for handling feed posts from different sources
class FeedPost {
  final String username;
  final String authorDid;
  final String? profileImageUrl;
  final String description;
  final String? videoUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String> hashtags;
  final String uri; // Post URI for likes
  final String cid; // Post CID for likes
  final bool isSprk; // Whether the post is from Spark

  FeedPost({
    required this.username,
    required this.authorDid,
    this.profileImageUrl,
    required this.description,
    this.videoUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.hashtags = const [],
    required this.uri,
    required this.cid,
    this.isSprk = false,
  });

  /// Create a FeedPost from a Bluesky feed item
  static FeedPost fromBlueskyFeed(FeedView feedItem) {
    final post = feedItem.post;

    // Extract video URL if available
    String? videoUrl;
    if (post.embed?.data is EmbedVideoView) {
      videoUrl = (post.embed?.data as EmbedVideoView).playlist;
    }

    // Extract hashtags from description
    List<String> hashtags = ['spark'];
    final matches = RegExp(r'#(\w+)').allMatches(post.record.text);
    if (matches.isNotEmpty) {
      hashtags = matches.map((m) => m.group(1)!).toList();
    }

    return FeedPost(
      username: post.author.handle,
      authorDid: post.author.did,
      profileImageUrl: post.author.avatar,
      description: post.record.text,
      videoUrl: videoUrl,
      likeCount: post.likeCount,
      commentCount: post.replyCount,
      shareCount: post.repostCount,
      hashtags: hashtags,
      uri: post.uri.toString(),
      cid: post.cid,
      isSprk: false,
    );
  }

  /// Create a FeedPost from a Spark feed item
  static FeedPost fromSparkFeed(Map<String, dynamic> feedItem) {
    final post = feedItem['post'] as Map<String, dynamic>;
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;

    // Extract video URL if available
    String? videoUrl;
    if (post['embed'] != null && post['embed']['\$type'] == 'so.sprk.embed.video#view') {
      videoUrl = post['embed']['playlist'];
    }

    // Extract hashtags from description
    final description = record['text'] as String? ?? '';
    List<String> hashtags = ['spark'];
    final matches = RegExp(r'#(\w+)').allMatches(description);
    if (matches.isNotEmpty) {
      hashtags = matches.map((m) => m.group(1)!).toList();
    }

    return FeedPost(
      username: author['handle'] as String? ?? '',
      authorDid: author['did'] as String? ?? '',
      profileImageUrl: author['avatar'] as String?,
      description: description,
      videoUrl: videoUrl,
      likeCount: post['likeCount'] as int? ?? 0,
      commentCount: post['replyCount'] as int? ?? 0,
      shareCount: post['repostCount'] as int? ?? 0,
      hashtags: hashtags,
      uri: post['uri'] as String? ?? '',
      cid: post['cid'] as String? ?? '',
      isSprk: true,
    );
  }

  /// Create a FeedPost from any feed item (either Bluesky or Spark)
  static FeedPost fromAny(dynamic feedItem) {
    if (feedItem is Map<String, dynamic>) {
      return fromSparkFeed(feedItem);
    } else {
      return fromBlueskyFeed(feedItem);
    }
  }
}