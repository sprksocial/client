import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/features/auth/data/repositories/identity_repository.dart';

import 'actor_models.dart';

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

/// yes this file has 820 lines of code. it's because of the comment model. this needs to be fixed.

enum HardCodedFeed {
  following('Following'), // posts from people you follow (bsky/sprk)
  forYou('For You'), // hardcoded algorithm for trending posts (bsky/sprk). for now, it's just the TheVids feed (bsky)
  latestSprk('Latest'), // latest sprk posts (sprk)
  shared('Shared'); // posts sent by friends in the dms (bsky/sprk)

  const HardCodedFeed(this.name);
  final String name;
}

/// This model will be used in:
/// - Creating a custom feed
/// - Editing a custom feed
///
/// The CustomFeedCreatorPage will create a CustomFeed and send it to the API.
///
/// The CustomFeedPage will need a CustomFeed and will display it.
///
/// The CustomFeedEditorPage will edit a CustomFeed and send the changes to the API.
///
/// TODO: make this the same as the lexicon (not implemented yet)
@freezed
class CustomFeed with _$CustomFeed {
  const factory CustomFeed({
    required ProfileViewBasic? creator,
    @Default('Custom Feed') String name,
    @Default('Your custom feed') String description,
    @Default([]) List<Facet> descriptionFacets,
    @Default([]) List<Label> labels,
    @Default(0) int likeCount,
    @Default('') String imageUrl,
    @Default(true) bool isDraft,
    @Default(false) bool videosOnly,
    String? did,
    String? uri,
    String? cid,

    @Default({})
    Map<String, bool> hashtagPreferences, // hashtag: only show posts with this hashtag || never show posts with this hashtag

    @Default({})
    Map<String, Map<String, bool>>
    labelPreferences, // labeler: {label: only show posts with this label || never show posts with this label}
  }) = _CustomFeed;

  factory CustomFeed.fromJson(Map<String, dynamic> json) => _$CustomFeedFromJson(json);
}

/// The feeds that are actually used in the app
///
/// Custom Feeds just need a uri, the rest is fetched from the API (if the custom feed is finished, it will be saved in the backend)
///
/// HardCoded feeds are "fake" and completely handled in the frontend
@freezed
class Feed with _$Feed {
  const Feed._();
  const factory Feed.custom({required String name, required String uri}) = _Feed;

  /// HardCoded feeds can be "fake", so they don't have a uri
  const factory Feed.hardCoded({required HardCodedFeed hardCodedFeed}) = _HardCodedFeed;

  String get name {
    return when(custom: (name, did) => name, hardCoded: (hardCodedFeed) => hardCodedFeed.name);
  }
}

@freezed
class PostThread with _$PostThread {
  const factory PostThread({required PostView post, List<PostView>? parent, List<PostView>? replies}) = _PostThread;

  factory PostThread.fromJson(Map<String, dynamic> json) => _$PostThreadFromJson(json);
}

@freezed
class ReplyRef with _$ReplyRef {
  const factory ReplyRef({required StrongRef root, required StrongRef parent}) = _ReplyRef;

  factory ReplyRef.fromJson(Map<String, dynamic> json) => _$ReplyRefFromJson(json);
}

@freezed
class SelfLabel with _$SelfLabel {
  const factory SelfLabel({required String val}) = _SelfLabel;

  factory SelfLabel.fromJson(Map<String, dynamic> json) => _$SelfLabelFromJson(json);
}

@freezed
class PostRecord with _$PostRecord {
  const PostRecord._();
  const factory PostRecord.video({
    required DateTime createdAt,
    @JsonKey(defaultValue: '') String? text,
    @JsonKey(defaultValue: []) List<Facet>? facets,
    ReplyRef? reply,
    StrongRef? sound,
    List<String>? langs,
    List<String>? tags,
    List<SelfLabel>? selfLabels,
    VideoEmbed? embed,
    // threadgate
  }) = _PostRecordVideo;

  const factory PostRecord.image({
    required DateTime createdAt,
    @JsonKey(defaultValue: '') String? text,
    @JsonKey(defaultValue: []) List<Facet>? facets,
    ReplyRef? reply,
    StrongRef? sound,
    List<String>? langs,
    List<String>? tags,
    List<SelfLabel>? selfLabels,
    ImageEmbed? embed,
    // threadgate
  }) = _PostRecordImage;


  factory PostRecord.fromJson(Map<String, dynamic> json) => _$PostRecordFromJson(json);
}

/// https://pub.dev/packages/freezed#union-types read this to understand what the hell is going on here
///
/// TL;DR:
/// - posts can be either a video or an image, you can use pattern matching to check which one it is
/// switch (post) {
///   case VideoPost(:final VideoEmbed embed): ...
///   case ImagePost(:final ImageEmbed embed): ...
/// }
@freezed
sealed class PostView with _$PostView {
  const factory PostView.video({
    @AtUriConverter() required AtUri uri,
    @JsonKey(defaultValue: '') required String cid,
    required ProfileViewBasic author,
    required PostRecord record,
    @Default(false) bool isRepost,
    required DateTime indexedAt,
    List<Label>? labels,
    SoundView? sound,
    VideoView? embed,
  }) = VideoPostView;

  const factory PostView.image({
    @AtUriConverter() required AtUri uri,
    @JsonKey(defaultValue: '') required String cid,
    required ProfileViewBasic author,
    required PostRecord record,
    @Default(false) bool isRepost,
    required DateTime indexedAt,
    List<Label>? labels,
    SoundView? sound,
    int? replyCount,
    int? repostCount,
    int? likeCount,
    int? lookCount,
    Viewer? viewer,
    ImageView? embed,
  }) = ImagePostView;

  factory PostView.fromJson(Map<String, dynamic> json) => _$PostViewFromJson(json);

}

@freezed
class FeedSkeleton with _$FeedSkeleton {
  const factory FeedSkeleton({required List<FeedItem> feed, String? cursor}) = _FeedSkeleton;

  factory FeedSkeleton.fromJson(Map<String, dynamic> json) => _$FeedSkeletonFromJson(json);
}

@freezed
class FeedItem with _$FeedItem {
  const factory FeedItem({@AtUriConverter() required AtUri postUri, String? reason}) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) => _$FeedItemFromJson(json);
}

@freezed
class PostsResponse with _$PostsResponse {
  const factory PostsResponse({required List<PostView> posts}) = _PostsResponse;

  factory PostsResponse.fromJson(Map<String, dynamic> json) => _$PostsResponseFromJson(json);
}

@freezed
class AuthorFeedResponse with _$AuthorFeedResponse {
  const factory AuthorFeedResponse({required List<PostView> feed, String? cursor}) = _AuthorFeedResponse;

  factory AuthorFeedResponse.fromJson(Map<String, dynamic> json) => _$AuthorFeedResponseFromJson(json);
}

@freezed
class ImageUploadResult with _$ImageUploadResult {
  const factory ImageUploadResult({required String fullsize, required String alt, required Map<String, dynamic> image}) =
      _ImageUploadResult;

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) => _$ImageUploadResultFromJson(json);
}

/// TODO: make this better
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
      _ => (<String, dynamic>{}, <String, dynamic>{}),
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
        _ => '',
      },
      username: switch (authorData) {
        {'handle': String handle} => handle,
        _ => '',
      },
      profileImageUrl: authorData['avatar'] as String?,
      text: text,
      createdAt: _formatTimeAgo(switch (recordData) {
        {'createdAt': String date} => date,
        _ => DateTime.now().toIso8601String(),
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
    final {'author': Map<String, dynamic> authorData, 'record': Map<String, dynamic> recordData} = post;
    final {'text': String text} = recordData;
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
        _ => '',
      },
      username: switch (authorData) {
        {'handle': String handle} => handle,
        _ => '',
      },
      profileImageUrl: authorData['avatar'] as String?,
      text: text,
      createdAt: _formatTimeAgo(switch (post) {
        {'indexedAt': String date} => date,
        _ => DateTime.now().toIso8601String(),
      }),
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
      profileImageUrl: profileResponse.avatar.toString(),
      text: text,
      createdAt: _formatTimeAgo(switch (record) {
        {'indexedAt': String date} => date,
        {'createdAt': String date} => date,
        _ => DateTime.now().toIso8601String(),
      }),
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
      profileImageUrl: profileResponse.avatar.toString(),
      text: text,
      createdAt: _formatTimeAgo(switch (record) {
        {'indexedAt': String date} => date,
        {'createdAt': String date} => date,
        _ => DateTime.now().toIso8601String(),
      }),
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
  factory FacetIndex.fromJson(Map<String, dynamic> json) => _$FacetIndexFromJson(json);
}

/// Represents a feature of a facet (mention, link, hashtag, etc.)
@freezed
class FacetFeature with _$FacetFeature {
  const FacetFeature._();

  /// Mention feature for referencing a user
  const factory FacetFeature.mention({required String did}) = _MentionFeature;

  /// Link feature for URLs
  const factory FacetFeature.link({required String uri}) = _LinkFeature;

  /// Tag feature for hashtags
  const factory FacetFeature.tag({required String tag}) = _TagFeature;

  /// Create a FacetFeature from JSON
  factory FacetFeature.fromJson(Map<String, dynamic> json) => _$FacetFeatureFromJson(json);
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
  factory Facet.fromJson(Map<String, dynamic> json) => _$FacetFromJson(json);
}

/// Represents a video embed in a post
@freezed
class VideoEmbed with _$VideoEmbed {
  const VideoEmbed._();

  const factory VideoEmbed({
    /// The type of embed, typically 'so.sprk.embed.video'
    @JsonKey(name: '\$type') required String type,

    /// The video blob reference
    required Blob video,

    // remaining fields that are in the json
    // List<Caption> captions,
    // AspectRatio aspectRatio, {width: int, height: int}

    /// Optional alt text for accessibility
    String? alt,
  }) = _VideoEmbed;

  /// Create a VideoEmbed from JSON
  factory VideoEmbed.fromJson(Map<String, dynamic> json) => _$VideoEmbedFromJson(json);
}

@freezed
class VideoView with _$VideoView {
  const VideoView._();
  const factory VideoView({
    required String cid,
    @AtUriConverter() required AtUri playlist,
    @AtUriConverter() required AtUri thumbnail,
    String? alt,
    // aspectRatio: {width: int, height: int}
  }) = _VideoView;

  factory VideoView.fromJson(Map<String, dynamic> json) => _$VideoViewFromJson(json);
}

@freezed
class ImageEmbed with _$ImageEmbed {
  const ImageEmbed._();

  const factory ImageEmbed({@JsonKey(name: '\$type') required String type, required List<Image> images}) = _ImageEmbed;

  factory ImageEmbed.fromJson(Map<String, dynamic> json) => _$ImageEmbedFromJson(json);
}

@freezed
class Image with _$Image {
  const Image._();

  const factory Image({
    required Blob image,
    String? alt,
    // aspectRatio: {width: int, height: int}
  }) = _Image;

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}

@freezed
class ImageView with _$ImageView {
  const ImageView._();
  const factory ImageView({required List<ViewImage> images}) = _ImageView;

  factory ImageView.fromJson(Map<String, dynamic> json) => _$ImageViewFromJson(json);
}

// yes. this is different than ImageView. thanks paulinho!
@freezed
class ViewImage with _$ViewImage {
  const ViewImage._();
  const factory ViewImage({
    @AtUriConverter() required AtUri thumb,
    @AtUriConverter() required AtUri fullsize,
    String? alt,
    // aspectRatio: {width: int, height: int}
  }) = _ViewImage;

  factory ViewImage.fromJson(Map<String, dynamic> json) => _$ViewImageFromJson(json);
}

@freezed
class SoundView with _$SoundView {
  const SoundView._();
  const factory SoundView.audio({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required Audio record,
    int? useCount,
    int? likeCount,
    required DateTime indexedAt,
    List<Label>? labels,
  }) = _SoundViewAudio;

  const factory SoundView.music({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required Music record,
    int? useCount,
    int? likeCount,
    required DateTime indexedAt,
    List<Label>? labels,
  }) = _SoundViewMusic;


  factory SoundView.fromJson(Map<String, dynamic> json) => _$SoundViewFromJson(json);
}

@freezed
class Audio with _$Audio {
  const Audio._();
  const factory Audio({
    required Blob sound,
    required StrongRef origin,
    String? title,
    String? text,
    List<SelfLabel>? labels,
    required DateTime createdAt,
  }) = _Audio;


  factory Audio.fromJson(Map<String, dynamic> json) => _$AudioFromJson(json);
}

@freezed
class Music with _$Music {
  const Music._();
  const factory Music({
    required Blob sound,
    required String title,
    required DateTime releaseDate,
    String? album,
    String? recordLabel,
    Blob? cover,
    required String author, // the artist
    String? text,
    List<String>? copyright,
    List<Facet>? facets,
    List<SelfLabel>? labels,
    List<String>? tags,
    required DateTime createdAt,
  }) = _Music;


  factory Music.fromJson(Map<String, dynamic> json) => _$MusicFromJson(json);
}
