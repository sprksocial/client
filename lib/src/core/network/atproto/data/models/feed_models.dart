import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/network/auth/data/repositories/identity_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/label_models.dart';

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

enum FeedType {
  following(0, 'Following'),
  forYou(1, 'For You'),
  latest(2, 'Latest');

  final int value;
  final String name;

  const FeedType(this.value, this.name);

  static FeedType fromValue(int value) {
    return FeedType.values.firstWhere((feedType) => feedType.value == value, orElse: () => FeedType.forYou);
  }
}

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
    // Use pattern matching to extract author and record data
    final (authorData, recordData) = switch (post) {
      {'author': Map<String, dynamic> author, 'record': Map<String, dynamic> record} => (author, record),
      _ => (<String, dynamic>{}, <String, dynamic>{})
    };
    
    // Extract text and hashtags using pattern matching
    final text = recordData['text'] as String? ?? '';
    final hashtags = _extractHashtags(text);

    // Extract media information using pattern matching
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;
    List<String> imageUrls = [];

    // Pattern match the embed structure
    if (post case {'embed': Map<String, dynamic> embed}) {
      // Match the embed type
      switch (embed) {
        case {r'$type': 'app.bsky.embed.images#view', 'images': List images} when images.isNotEmpty:
          hasMedia = true;
          mediaType = 'image';
          
          // Extract thumbnail for the first image
          if (images.first case {'thumbnail': String thumb}) {
            mediaUrl = thumb;
          }
          
          // Extract all fullsize images
          for (final image in images) {
            if (image case {'fullsize': String fullsize}) {
              imageUrls.add(fullsize);
            }
          }
          
        case {r'$type': 'app.bsky.embed.video#view', 'playlist': String playlist}:
          hasMedia = true;
          mediaType = 'video';
          mediaUrl = playlist;
      }
    }

    // Extract like URI using pattern matching
    String? likeUri;
    if (post case {'viewer': {'like': String like}}) {
      likeUri = like;
    }

    return Comment(
      id: post['uri'] as String? ?? '',
      uri: post['uri'] as String? ?? '',
      cid: post['cid'] as String? ?? '',
      authorDid: switch (authorData) {
        {'did': String did} => did,
        _ => ''
      },
      username: switch (authorData) {
        {'handle': String handle} => handle,
        _ => ''
      },
      profileImageUrl: authorData['avatar'] as String?,
      text: text,
      createdAt: _formatTimeAgo(switch (recordData) {
        {'createdAt': String date} => date,
        _ => DateTime.now().toIso8601String()
      }),
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
    // Use pattern matching to extract author and record data
    final (authorData, recordData) = switch (post) {
      {'author': Map<String, dynamic> author, 'record': Map<String, dynamic> record} => (author, record),
      _ => (<String, dynamic>{}, <String, dynamic>{})
    };
    
    // Extract text and hashtags using pattern matching
    final text = recordData['text'] as String? ?? '';
    final hashtags = _extractHashtags(text);

    // Extract media information using pattern matching
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;
    List<String> imageUrls = [];

    // Pattern match the embed structure
    if (post case {'embed': Map<String, dynamic> embed}) {
      // Match the embed type
      switch (embed) {
        case {r'$type': 'so.sprk.embed.images#view', 'images': List images} when images.isNotEmpty:
          hasMedia = true;
          mediaType = 'image';
          
          // Extract thumb for the first image
          if (images.first case {'thumb': String thumb}) {
            mediaUrl = thumb;
          }
          
          // Extract all fullsize images
          for (final image in images) {
            if (image case {'fullsize': String fullsize}) {
              imageUrls.add(fullsize);
            }
          }
          
        case {r'$type': 'so.sprk.embed.video#view', 'playlist': String playlist}:
          hasMedia = true;
          mediaType = 'video';
          mediaUrl = playlist;
      }
    }

    // Extract like URI using pattern matching
    String? likeUri;
    if (post case {'viewer': {'like': String like}}) {
      likeUri = like;
    }
    
    return Comment(
      id: post['uri'] as String? ?? '',
      uri: post['uri'] as String? ?? '',
      cid: post['cid'] as String? ?? '',
      authorDid: switch (authorData) {
        {'did': String did} => did,
        _ => ''
      },
      username: switch (authorData) {
        {'handle': String handle} => handle,
        _ => ''
      },
      profileImageUrl: authorData['avatar'] as String?,
      text: text,
      createdAt: _formatTimeAgo(
        switch (post) {
          {'indexedAt': String date} => date,
          _ => DateTime.now().toIso8601String()
        }
      ),
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
  
  /// Create a Comment from a Spark record (not a full post object)
  static Future<Comment> fromSparkCommentRecord(Map<String, dynamic> record, String uri) async {
    // Use pattern matching to extract data from record
    final text = record['text'] as String? ?? '';
    final hashtags = _extractHashtags(text);

    // Extract media information using pattern matching
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;
    List<String> imageUrls = [];

    // Pattern match the embed structure
    if (record case {'embed': Map<String, dynamic> embed}) {
      // Match the embed type
      switch (embed) {
        case {r'$type': 'so.sprk.embed.images#view', 'images': List images} when images.isNotEmpty:
          hasMedia = true;
          mediaType = 'image';
          
          // Extract thumb for the first image
          if (images.first case {'thumb': String thumb}) {
            mediaUrl = thumb;
          }
          
          // Extract all fullsize images
          for (final image in images) {
            if (image case {'fullsize': String fullsize}) {
              imageUrls.add(fullsize);
            }
          }
          
        case {r'$type': 'so.sprk.embed.video#view', 'playlist': String playlist}:
          hasMedia = true;
          mediaType = 'video';
          mediaUrl = playlist;
      }
    }

    // Extract like URI using pattern matching
    String? likeUri;
    if (record case {'viewer': {'like': String like}}) {
      likeUri = like;
    }

    // Extract authorDid from uri
    String authorDid = '';
    if (uri case String uri when RegExp(r'at://([^/]+)/').hasMatch(uri)) {
      final match = RegExp(r'at://([^/]+)/').firstMatch(uri);
      if (match != null && match.groupCount >= 1) {
        authorDid = match.group(1)!;
      }
    }
    
    // Get repositories from service locator
    final identityRepository = GetIt.instance<IdentityRepository>();
    final actorRepository = GetIt.instance<ActorRepository>();
    
    // Get handle from identity repository
    final handle = await identityRepository.resolveDidToHandle(authorDid);
    if (handle == null) {
      throw Exception('No handle found for author did: $authorDid');
    }

    // Get profile information
    final profileResponse = await actorRepository.getProfile(authorDid);

    // Create comment with extracted data
    return Comment(
      id: uri,
      uri: uri,
      cid: record['cid'] as String? ?? '',
      authorDid: authorDid,
      username: profileResponse.displayName ?? profileResponse.handle,
      profileImageUrl: profileResponse.avatar,
      text: text,
      createdAt: _formatTimeAgo(
        switch (record) {
          {'indexedAt': String date} => date,
          {'createdAt': String date} => date,
          _ => DateTime.now().toIso8601String()
        },
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
  static Future<Comment> fromBlueskyCommentRecord(Map<String, dynamic> record, String uri) async {
    // Use pattern matching to extract data from record
    final text = record['text'] as String? ?? '';
    final hashtags = _extractHashtags(text);

    // Extract media information using pattern matching
    bool hasMedia = false;
    String? mediaType;
    String? mediaUrl;
    List<String> imageUrls = [];

    // Pattern match the embed structure
    if (record case {'embed': Map<String, dynamic> embed}) {
      // Match the embed type
      switch (embed) {
        case {r'$type': 'app.bsky.embed.images#view', 'images': List images} when images.isNotEmpty:
          hasMedia = true;
          mediaType = 'image';
          
          // Extract thumbnail for the first image
          if (images.first case {'thumbnail': String thumb}) {
            mediaUrl = thumb;
          }
          
          // Extract all fullsize images
          for (final image in images) {
            if (image case {'fullsize': String fullsize}) {
              imageUrls.add(fullsize);
            }
          }
          
        case {r'$type': 'app.bsky.embed.video#view', 'playlist': String playlist}:
          hasMedia = true;
          mediaType = 'video';
          mediaUrl = playlist;
      }
    }

    // Extract like URI using pattern matching
    String? likeUri;
    if (record case {'viewer': {'like': String like}}) {
      likeUri = like;
    }

    // Extract authorDid from uri
    String authorDid = '';
    if (uri case String uri when RegExp(r'at://([^/]+)/').hasMatch(uri)) {
      final match = RegExp(r'at://([^/]+)/').firstMatch(uri);
      if (match != null && match.groupCount >= 1) {
        authorDid = match.group(1)!;
      }
    }

    // Get repositories from service locator
    final actorRepository = GetIt.instance<ActorRepository>();
    
    // Get profile information
    final profileResponse = await actorRepository.getProfile(authorDid);
    
    // Create comment with extracted data
    return Comment(
      id: uri,
      uri: uri,
      cid: record['cid'] as String? ?? '',
      authorDid: authorDid,
      username: profileResponse.displayName ?? profileResponse.handle,
      profileImageUrl: profileResponse.avatar,
      text: text,
      createdAt: _formatTimeAgo(
        switch (record) {
          {'indexedAt': String date} => date,
          {'createdAt': String date} => date,
          _ => DateTime.now().toIso8601String()
        },
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

/// Represents a blob reference in the AT Protocol
@freezed
class BlobReference with _$BlobReference {
  const BlobReference._();
  
  const factory BlobReference({
    /// The type of the blob, usually 'blob'
    @JsonKey(name: '\$type') required String type,
    
    /// The MIME type of the blob
    required String mimeType,
    
    /// Size of the blob in bytes
    required int size,
    
    /// Content reference (CID)
    required String ref,
    
    /// Creation time in ISO 8601 format
    String? createdAt,
  }) = _BlobReference;
  
  /// Create a BlobReference from JSON
  factory BlobReference.fromJson(Map<String, dynamic> json) => 
      _$BlobReferenceFromJson(json);
      
  /// Create an empty BlobReference
  factory BlobReference.empty() => const BlobReference(
    type: 'blob',
    mimeType: 'video/mp4',
    size: 0,
    ref: '',
  );
}

/// Represents the index range for a facet in the text
@freezed
class FacetIndex with _$FacetIndex {
  const FacetIndex._();
  
  const factory FacetIndex({
    /// Start index (inclusive)
    required int byteStart,
    
    /// End index (exclusive)
    required int byteEnd,
  }) = _FacetIndex;
  
  /// Create a FacetIndex from JSON
  factory FacetIndex.fromJson(Map<String, dynamic> json) => 
      _$FacetIndexFromJson(json);
}

/// Represents a feature of a facet (mention, link, hashtag, etc.)
@freezed
class FacetFeature with _$FacetFeature {
  const FacetFeature._();
  
  /// Mention feature for referencing a user
  const factory FacetFeature.mention({
    required String did,
  }) = _MentionFeature;
  
  /// Link feature for URLs
  const factory FacetFeature.link({
    required String uri,
  }) = _LinkFeature;
  
  /// Tag feature for hashtags
  const factory FacetFeature.tag({
    required String tag,
  }) = _TagFeature;
  
  /// Create a FacetFeature from JSON
  factory FacetFeature.fromJson(Map<String, dynamic> json) => 
      _$FacetFeatureFromJson(json);
}

/// Represents a richtext facet for text formatting, mentions, links, etc.
@freezed
class Facet with _$Facet {
  const Facet._();
  
  const factory Facet({
    /// Index range for the facet in the text
    required FacetIndex index,
    
    /// Features represented by this facet (mention, link, hashtag, etc.)
    required List<FacetFeature> features,
  }) = _Facet;
  
  /// Create a Facet from JSON
  factory Facet.fromJson(Map<String, dynamic> json) => 
      _$FacetFromJson(json);
}

/// Represents a video embed in a post
@freezed
class VideoEmbed with _$VideoEmbed {
  const VideoEmbed._();
  
  const factory VideoEmbed({
    /// The type of embed, typically 'so.sprk.embed.video'
    @JsonKey(name: '\$type') required String type,
    
    /// The video blob reference
    required BlobReference video,
    
    /// Optional alt text for accessibility
    String? alt,
  }) = _VideoEmbed;
  
  /// Create a VideoEmbed from JSON
  factory VideoEmbed.fromJson(Map<String, dynamic> json) => 
      _$VideoEmbedFromJson(json);
      
  /// Create an empty VideoEmbed
  factory VideoEmbed.empty() => VideoEmbed(
    type: 'so.sprk.embed.video',
    video: BlobReference.empty(),
  );
}

/// Represents a post containing a video
@freezed
class VideoPost with _$VideoPost {
  const VideoPost._();
  
  const factory VideoPost({
    /// The type of post, typically 'so.sprk.feed.post'
    @JsonKey(name: r'$type') required String type,
    
    /// Post text/description
    @Default('') String text,
    
    /// Video embed containing the actual video data
    required VideoEmbed embed,
    
    /// When the post was created (ISO 8601 format)
    required String createdAt,
    
    /// Optional language tags
    List<String>? langs,
    
    /// Optional content warning labels
    @JsonKey(name: 'labels') List<LabelDetail>? labels,
    
    /// Optional tags for discovery
    List<String>? tags,
    
    /// Optional facets for rich text formatting
    List<Facet>? facets,
  }) = _VideoPost;
  
  /// Create a VideoPost from JSON
  factory VideoPost.fromJson(Map<String, dynamic> json) => 
      _$VideoPostFromJson(json);
  
  /// Create a new empty VideoPost
  factory VideoPost.create({
    required String text,
    required Map<String, dynamic> videoData,
    String? videoAltText,
    List<String>? tags,
    List<LabelDetail>? labels,
    List<Facet>? facets,
  }) {
    final videoEmbed = {
      r'$type': 'so.sprk.embed.video',
      'video': videoData,
    };
    
    // Add alt text if provided
    if (videoAltText != null && videoAltText.isNotEmpty) {
      videoEmbed['alt'] = videoAltText;
    }
    
    return VideoPost(
      type: 'so.sprk.feed.post',
      text: text,
      embed: VideoEmbed.fromJson(videoEmbed),
      createdAt: DateTime.now().toUtc().toIso8601String(),
      tags: tags,
      labels: labels,
      facets: facets,
    );
  }
} 