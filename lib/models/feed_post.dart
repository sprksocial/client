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
  final List<String> imageUrls;
  final String uri; // Post URI for likes
  final String cid; // Post CID for likes
  final bool isSprk; // Whether the post is from Spark
  final String? likeUri; // Store original like URI if needed
  final bool hasMedia; // Whether the post has media (image or video)
  final bool isReply; // Whether the post is a reply to another post
  final dynamic viewerState; // Use dynamic for viewerState for now

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
    this.imageUrls = const [],
    required this.uri,
    required this.cid,
    this.isSprk = false,
    this.likeUri,
    this.hasMedia = false,
    this.isReply = false,
    this.viewerState,
  });

  /// Create a FeedPost from a Bluesky feed item
  static FeedPost fromBlueskyFeed(dynamic feedItem) {
    final post = feedItem.post;

    String? videoUrl;
    List<String> imageUrls = [];
    bool hasMedia = false;
    String? embedType;

    final embedData = post.embed?.data?.toJson();

    if (embedData != null && embedData is Map<String, dynamic>) {
      embedType = embedData['\$type'] as String?;

      if (embedType == 'app.bsky.embed.images#view' || embedType == 'app.bsky.embed.images') {
        hasMedia = true;
        final imagesList = embedData['images'] as List<dynamic>?;
        if (imagesList != null) {
          imageUrls =
              imagesList
                  .map((img) => (img as Map<String, dynamic>?)?['fullsize'] as String? ?? '')
                  .where((url) => url.isNotEmpty)
                  .toList();
        }
      } else if (embedType == 'so.sprk.embed.video#view' || embedType == 'so.sprk.embed.video') {
        videoUrl = embedData['playlist'] as String?;
        hasMedia = videoUrl != null && videoUrl.isNotEmpty;
      } else if (embedType == 'app.bsky.embed.recordWithMedia#view' || embedType == 'app.bsky.embed.recordWithMedia') {
        final mediaData = embedData['media'] as Map<String, dynamic>?;
        if (mediaData != null) {
          final mediaType = mediaData['\$type'] as String?;
          if (mediaType == 'app.bsky.embed.images#view' || mediaType == 'app.bsky.embed.images') {
            hasMedia = true;
            final imagesList = mediaData['images'] as List<dynamic>?;
            if (imagesList != null) {
              imageUrls =
                  imagesList
                      .map((img) => (img as Map<String, dynamic>?)?['fullsize'] as String? ?? '')
                      .where((url) => url.isNotEmpty)
                      .toList();
            }
          }
        }
      }
    }

    bool isReply = feedItem.reply != null;
    final record = post.record?.toJson();
    final descriptionText = (record is Map<String, dynamic> ? record['text'] : null) as String? ?? '';

    List<String> hashtags = HashtagList.extractFromText(descriptionText);

    final derivedLikeUri = post.viewer?.like?.toString();

    return FeedPost(
      username: post.author.handle,
      authorDid: post.author.did,
      profileImageUrl: post.author.avatar,
      description: descriptionText,
      videoUrl: videoUrl,
      imageUrls: imageUrls,
      likeCount: post.likeCount ?? 0,
      commentCount: post.replyCount ?? 0,
      shareCount: post.repostCount ?? 0,
      hashtags: hashtags,
      uri: post.uri.toString(),
      cid: post.cid,
      isSprk: false,
      likeUri: derivedLikeUri,
      hasMedia: hasMedia,
      isReply: isReply,
      viewerState: post.viewer,
    );
  }

  static FeedPost fromSparkFeed(Map<String, dynamic> feedItem) {
    final post = feedItem['post'] as Map<String, dynamic>? ?? feedItem;
    final author = post['author'] as Map<String, dynamic>? ?? {};
    final record = post['record'] as Map<String, dynamic>? ?? {};
    final embed = post['embed'] as Map<String, dynamic>?;
    final viewer = post['viewer'] as Map<String, dynamic>?;

    String? videoUrl;
    List<String> imageUrls = [];
    bool hasMedia = false;

    if (embed != null) {
      final embedType = embed['\$type'] as String?;
      if (embedType == 'so.sprk.embed.video#view' || embedType == 'so.sprk.embed.video') {
        videoUrl = embed['playlist'] as String?;
        hasMedia = videoUrl != null && videoUrl.isNotEmpty;
      } else if (embedType == 'so.sprk.embed.images#view' || embedType == 'so.sprk.embed.images') {
        final imagesList = embed['images'] as List<dynamic>?;
        if (imagesList != null) {
          imageUrls =
              imagesList
                  .map((img) => (img as Map<String, dynamic>?)?['fullsize'] as String? ?? '')
                  .where((url) => url.isNotEmpty)
                  .toList();
          hasMedia = imageUrls.isNotEmpty;
        }
      }
    }

    bool isReply = record.containsKey('reply');
    final description = record['text'] as String? ?? '';
    List<String> hashtags = HashtagList.extractFromText(description);

    String? likeUriString = viewer?['like'] as String?;
    dynamic constructedViewerState = viewer;

    return FeedPost(
      username: author['handle'] as String? ?? '',
      authorDid: author['did'] as String? ?? '',
      profileImageUrl: author['avatar'] as String?,
      description: description,
      videoUrl: videoUrl,
      imageUrls: imageUrls,
      likeCount: post['likeCount'] as int? ?? 0,
      commentCount: post['replyCount'] as int? ?? 0,
      shareCount: post['repostCount'] as int? ?? 0,
      hashtags: hashtags,
      uri: post['uri'] as String? ?? '',
      cid: post['cid'] as String? ?? '',
      isSprk: true,
      likeUri: likeUriString,
      hasMedia: hasMedia,
      isReply: isReply,
      viewerState: constructedViewerState,
    );
  }

  /// Create a FeedPost from any feed item (either Bluesky or Spark)
  static FeedPost fromAny(dynamic feedItem) {
    if (feedItem is Map<String, dynamic>) {
      return fromSparkFeed(feedItem);
    } else {
      print("Info: Feed item is not a Map, attempting Bluesky parsing: ${feedItem.runtimeType}");
      try {
        return fromBlueskyFeed(feedItem);
      } catch (e) {
        print("Error parsing feed item as Bluesky object: $e");
        throw ArgumentError('Unsupported feed item type and failed Bluesky fallback: ${feedItem.runtimeType}');
      }
    }
  }

  /// Check if the post is liked based on the viewer state (dynamic access)
  bool get isLiked {
    if (viewerState is Map<String, dynamic>) {
      return viewerState?['like'] != null;
    } else {
      try {
        return viewerState?.like != null;
      } catch (_) {
        return false;
      }
    }
  }

  /// Check if this post is a duplicate of another post (basic check)
  bool isDuplicateOf(FeedPost other) {
    if (uri.isNotEmpty && uri == other.uri) return true;
    if (videoUrl != null && videoUrl == other.videoUrl) return true;
    return false;
  }
}
