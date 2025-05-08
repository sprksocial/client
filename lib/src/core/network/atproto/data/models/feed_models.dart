import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

@freezed
class PostThreadResponse with _$PostThreadResponse {
  const factory PostThreadResponse({
    required PostThread thread,
  }) = _PostThreadResponse;

  factory PostThreadResponse.fromJson(Map<String, dynamic> json) => _$PostThreadResponseFromJson(json);
}

@freezed
class PostThread with _$PostThread {
  const factory PostThread({
    required Post post,
    List<Post>? parent,
    List<Post>? replies,
  }) = _PostThread;

  factory PostThread.fromJson(Map<String, dynamic> json) => _$PostThreadFromJson(json);
}

@freezed
class Post with _$Post {
  const factory Post({
    required String uri,
    required String cid,
    required PostAuthor author,
    required Map<String, dynamic> record,
    @Default(false) bool isRepost,
    DateTime? indexedAt,
    Map<String, dynamic>? embed,
    @Default({}) Map<String, dynamic> viewer,
    List<PostAuthor>? likedBy,
    List<Label>? labels,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
class PostAuthor with _$PostAuthor {
  const factory PostAuthor({
    required String did,
    required String handle,
    String? displayName,
    String? avatar,
    @Default(false) bool isFollowing,
    @Default(false) bool isFollowedBy,
  }) = _PostAuthor;

  factory PostAuthor.fromJson(Map<String, dynamic> json) => _$PostAuthorFromJson(json);
}

@freezed
class Label with _$Label {
  const factory Label({
    required String val,
    String? src,
  }) = _Label;

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);
}

@freezed
class FeedSkeletonResponse with _$FeedSkeletonResponse {
  const factory FeedSkeletonResponse({
    required List<FeedItem> feed,
    String? cursor,
  }) = _FeedSkeletonResponse;

  factory FeedSkeletonResponse.fromJson(Map<String, dynamic> json) => _$FeedSkeletonResponseFromJson(json);
}

@freezed
class FeedItem with _$FeedItem {
  const factory FeedItem({
    required String post,
    String? reason,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) => _$FeedItemFromJson(json);
}

@freezed
class PostsResponse with _$PostsResponse {
  const factory PostsResponse({
    required List<Post> posts,
  }) = _PostsResponse;

  factory PostsResponse.fromJson(Map<String, dynamic> json) => _$PostsResponseFromJson(json);
}

@freezed
class AuthorFeedResponse with _$AuthorFeedResponse {
  const factory AuthorFeedResponse({
    required List<Post> feed,
    String? cursor,
  }) = _AuthorFeedResponse;

  factory AuthorFeedResponse.fromJson(Map<String, dynamic> json) => _$AuthorFeedResponseFromJson(json);
}

@freezed
class LikePostResponse with _$LikePostResponse {
  const factory LikePostResponse({
    required String uri,
    required String cid,
  }) = _LikePostResponse;

  factory LikePostResponse.fromJson(Map<String, dynamic> json) => _$LikePostResponseFromJson(json);
}

@freezed
class CommentPostResponse with _$CommentPostResponse {
  const factory CommentPostResponse({
    required String uri,
    required String cid,
  }) = _CommentPostResponse;

  factory CommentPostResponse.fromJson(Map<String, dynamic> json) => _$CommentPostResponseFromJson(json);
}

@freezed
class ImageUploadResult with _$ImageUploadResult {
  const factory ImageUploadResult({
    required String fullsize,
    required String alt,
    required Map<String, dynamic> image,
  }) = _ImageUploadResult;

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) => _$ImageUploadResultFromJson(json);
}

@freezed
class FeedPost with _$FeedPost {
  const factory FeedPost({
    required String username,
    required String authorDid,
    String? profileImageUrl,
    required String description,
    String? videoUrl,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int shareCount,
    @Default([]) List<String> hashtags,
    @Default([]) List<String> labels,
    @Default([]) List<String> imageUrls,
    required String uri,
    required String cid,
    @Default(false) bool isSprk,
    String? likeUri,
    @Default(false) bool hasMedia,
    @Default(false) bool isReply,
    @Default([]) List<String> imageAlts,
    String? videoAlt,
  }) = _FeedPost;

  factory FeedPost.fromJson(Map<String, dynamic> json) => _$FeedPostFromJson(json);
}

@freezed
class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String uri,
    required String cid,
    required String authorDid,
    required String username,
    String? profileImageUrl,
    required String text,
    required String createdAt,
    @Default(0) int likeCount,
    @Default(0) int replyCount,
    @Default([]) List<String> hashtags,
    @Default(false) bool hasMedia,
    String? mediaType,
    String? mediaUrl,
    String? likeUri,
    @Default(false) bool isSprk,
    @Default([]) List<Comment> replies,
    @Default([]) List<String> imageUrls,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  
  /// Create a Comment from a Bluesky comment
  factory Comment.fromBlueskyComment(Map<String, dynamic> post) {
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;
    
    // Extract hashtags from text
    final text = record['text'] as String? ?? '';
    final hashtags = _extractHashtags(text);

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
      createdAt: _formatTimeAgo(record['createdAt'] as String? ?? DateTime.now().toIso8601String()),
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
  factory Comment.fromSparkComment(Map<String, dynamic> post) {
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;

    // Extract hashtags from text
    final text = record['text'] as String? ?? '';
    final hashtags = _extractHashtags(text);

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
      createdAt: _formatTimeAgo(post['indexedAt'] as String? ?? DateTime.now().toIso8601String()),
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
  
  /// Helper method to check if a comment is liked based on whether there's a likeUri
  static bool isLiked(Comment comment) => comment.likeUri != null;
  
  /// Extract hashtags from text
  static List<String> _extractHashtags(String text) {
    final matches = RegExp(r'#(\w+)').allMatches(text);
    if (matches.isNotEmpty) {
      return matches.map((m) => m.group(1)!).toList();
    }
    return [];
  }
  
  /// Parse a relative datetime string like "2023-11-19T12:34:56.789Z" and return a user-friendly string
  static String _formatTimeAgo(String dateTimeString) {
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
} 