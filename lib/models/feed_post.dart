import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/bluesky.dart';
import 'package:sparksocial/widgets/video_info/hashtag_list.dart';

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
  final String? likeUri; // URI of the user's like if the post is liked
  final bool hasMedia; // Whether the post has media (image or video)
  final bool isReply; // Whether the post is a reply to another post

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
    this.likeUri,
    this.hasMedia = false,
    this.isReply = false,
  });

  /// Create a FeedPost from a Bluesky feed item
  static FeedPost fromBlueskyFeed(FeedView feedItem) {
    final post = feedItem.post;

    // Extract video URL if available
    String? videoUrl;
    bool hasMedia = false;

    if (post.embed?.data is EmbedVideoView) {
      videoUrl = (post.embed?.data as EmbedVideoView).playlist;
      hasMedia = true;
    } else if (post.embed?.data is EmbedViewImages) {
      hasMedia = true;
    }
    if (!hasMedia) {
    }

    // Check if the post is a reply
    bool isReply = post.record.reply != null;

    // Extract hashtags from description
    List<String> hashtags = HashtagList.extractFromText(post.record.text);

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
      likeUri: post.viewer.like?.toString(),
      hasMedia: hasMedia,
      isReply: isReply,
    );
  }

  /// Create a FeedPost from a Spark feed item
  static FeedPost fromSparkFeed(Map<String, dynamic> feedItem) {
    final post = feedItem['post'] as Map<String, dynamic>;
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;

    // Extract video URL if available and check for media
    String? videoUrl;
    bool hasMedia = false;

    if (post['embed'] != null) {
      final embedType = post['embed']['\$type'] as String?;
      if (embedType == 'so.sprk.embed.video#view') {
        videoUrl = post['embed']['playlist'];
        hasMedia = true;
      } else if (embedType == 'so.sprk.embed.images#view') {
        hasMedia = true;
      }
    }

    // Check if the post is a reply
    bool isReply = record.containsKey('reply');

    // Extract description
    final description = record['text'] as String? ?? '';
    
    // Extract hashtags
    List<String> hashtags = HashtagList.extractFromText(description);

    // Extract like URI from viewer object if available
    String? likeUri;
    if (post.containsKey('viewer') && post['viewer'] is Map<String, dynamic>) {
      likeUri = (post['viewer'] as Map<String, dynamic>)['like'] as String?;
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
      likeUri: likeUri,
      hasMedia: hasMedia,
      isReply: isReply,
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

  /// Check if the post is liked based on whether there's a likeUri
  bool get isLiked => likeUri != null;
}