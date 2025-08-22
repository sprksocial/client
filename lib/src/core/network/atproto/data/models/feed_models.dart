import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/utils/uri_converter.dart';

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

/// https://pub.dev/packages/freezed#union-types <= read this to know how to use pattern matching to know the type of the object

enum HardCodedFeedEnum {
  following('Following'), // posts from people you follow (bsky/sprk)
  mutuals('Mutuals'), // posts from people you follow who follow each other (bsky/sprk)
  forYou('For You'), // hardcoded algorithm for trending posts (bsky/sprk). for now, it's just the TheVids feed (bsky)
  latestSprk('Latest'), // latest sprk posts (sprk)
  shared('Shared'); // posts sent by friends in the dms (bsky/sprk)

  const HardCodedFeedEnum(this.name);
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
  @JsonSerializable(explicitToJson: true)
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
    @AtUriConverter() AtUri? uri,
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
/// HardCoded feeds are "fake" and completely generated in the frontend
@freezed
class Feed with _$Feed {
  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
  const Feed._();
  @JsonSerializable(explicitToJson: true)
  const factory Feed.custom({required String name, @AtUriConverter() required AtUri uri}) = FeedCustom;

  /// HardCoded feeds can be "fake", so they don't have a uri
  @JsonSerializable(explicitToJson: true)
  const factory Feed.hardCoded({required HardCodedFeedEnum hardCodedFeed}) = FeedHardCoded;

  String get name {
    return when(custom: (name, did) => name, hardCoded: (hardCodedFeed) => hardCodedFeed.name);
  }

  String get identifier =>
      when(custom: (name, uri) => uri.toString(), hardCoded: (hardCodedFeed) => 'hardcoded:${hardCodedFeed.name}');
}

/// Skeleton of a FeedView. Needs to be hydrated.
@freezed
class SkeletonFeedPost with _$SkeletonFeedPost {
  @JsonSerializable(explicitToJson: true)
  const factory SkeletonFeedPost({
    @AtUriConverter() required AtUri uri,
    // "reason": { "type": "union", "refs": ["#reasonRepost", "#reasonPin"] } i think we don't have to use this value for now
    // there's also a String feedContext "Context provided by feed generator that may be passed back alongside interactions."
  }) = _SkeletonFeedPost;

  factory SkeletonFeedPost.fromJson(Map<String, dynamic> json) => _$SkeletonFeedPostFromJson(json);
}

@freezed
sealed class HardcodedFeedExtraInfo with _$HardcodedFeedExtraInfo {
  const HardcodedFeedExtraInfo._();

  @JsonSerializable(explicitToJson: true)
  const factory HardcodedFeedExtraInfo.shared({required ProfileViewBasic from, String? message}) = HardcodedFeedExtraInfoShared;

  factory HardcodedFeedExtraInfo.fromJson(Map<String, dynamic> json) => _$HardcodedFeedExtraInfoFromJson(json);
}

/// GetTimeline returns a FeedViewPost array
@freezed
class FeedViewPost with _$FeedViewPost {
  @JsonSerializable(explicitToJson: true)
  const factory FeedViewPost({
    required PostView post,
    ReplyRef? reply,
    // "reason": { "type": "union", "refs": ["#reasonRepost", "#reasonPin"] } i think we don't have to use this value for now
    // there's also a String feedContext "Context provided by feed generator that may be passed back alongside interactions."
  }) = _FeedViewPostPost;
  const FeedViewPost._();

  factory FeedViewPost.fromJson(Map<String, dynamic> json) => _$FeedViewPostFromJson(json);
}

@freezed
class ReplyRef with _$ReplyRef {
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRef({
    required ReplyRefPostReference root, // post, not found or blocked
    required ReplyRefPostReference parent, // post, not found or blocked
    ProfileViewBasic? grandparentAuthor,
  }) = _ReplyRef;
  const ReplyRef._();

  factory ReplyRef.fromJson(Map<String, dynamic> json) => _$ReplyRefFromJson(json);
}

/// Can be a post, a not found post, or a blocked post
@Freezed(unionKey: r'$type')
sealed class ReplyRefPostReference with _$ReplyRefPostReference {
  const ReplyRefPostReference._();
  @FreezedUnionValue('so.sprk.feed.defs#post')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.post({required PostView post}) = ReplyRefPostReferencePost;

  @FreezedUnionValue('app.bsky.feed.defs#postView')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.bskyPost({required PostView post}) = ReplyRefPostReferenceBskyPost;

  @FreezedUnionValue('so.sprk.feed.defs#notFoundPost')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.notFoundPost({@AtUriConverter() required AtUri uri, required bool notFound}) =
      ReplyRefPostReferenceNotFoundPost;

  @FreezedUnionValue('so.sprk.feed.defs#blockedPost')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.blockedPost({
    @AtUriConverter() required AtUri uri,
    required bool blocked,
    required BlockedAuthor author,
  }) = ReplyRefPostReferenceBlockedPost;

  factory ReplyRefPostReference.fromJson(Map<String, dynamic> json) => _$ReplyRefPostReferenceFromJson(json);
}

@freezed
class BlockedAuthor with _$BlockedAuthor {
  @JsonSerializable(explicitToJson: true)
  const factory BlockedAuthor({required String did, Viewer? viewer}) = _BlockedAuthor;
  const BlockedAuthor._();

  factory BlockedAuthor.fromJson(Map<String, dynamic> json) => _$BlockedAuthorFromJson(json);
}

@freezed
class PostThread with _$PostThread {
  @JsonSerializable(explicitToJson: true)
  const factory PostThread({required PostView post, List<PostView>? parent, List<PostView>? replies}) = _PostThread;
  const PostThread._();

  factory PostThread.fromJson(Map<String, dynamic> json) => _$PostThreadFromJson(json);
}

@freezed
class Viewer with _$Viewer {
  @JsonSerializable(explicitToJson: true)
  const factory Viewer({
    @AtUriConverter() AtUri? repost,
    @AtUriConverter() AtUri? like,
    @AtUriConverter() AtUri? look,
    bool? threadMuted,
    bool? replyDisabled,
    bool? embeddingDisabled,
    bool? pinned,
  }) = _Viewer;
  const Viewer._();

  factory Viewer.fromJson(Map<String, dynamic> json) => _$ViewerFromJson(json);
}

@freezed
class PostView with _$PostView {
  @JsonSerializable(explicitToJson: true)
  const factory PostView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required PostRecord record,
    required DateTime indexedAt,
    @Default(false) bool isRepost,
    int? likeCount,
    int? replyCount,
    int? repostCount,
    int? quoteCount,
    List<Label>? labels,
    Viewer? viewer,
    AudioView? sound,
    EmbedView? embed, // aturi
  }) = _PostView;
  const PostView._();

  factory PostView.fromJson(Map<String, dynamic> json) => _$PostViewFromJson(json);

  bool get isSprk => RegExp(r'^at://[^/]+/so\.sprk\.feed\.post/[^/]+$').hasMatch(uri.toString());

  /// Returns true if this post has a video or image embed (content we want to show)
  bool get hasSupportedMedia {
    if (embed == null) return false;

    switch (embed) {
      case EmbedViewVideo():
      case EmbedViewBskyVideo():
      case EmbedViewImage():
      case EmbedViewBskyImages():
        return true;
      case EmbedViewBskyRecordWithMedia(:final media):
        // Check nested media in record with media
        switch (media) {
          case EmbedViewVideo():
          case EmbedViewBskyVideo():
          case EmbedViewImage():
          case EmbedViewBskyImages():
            return true;
          case _:
            return false;
        }
      case _:
        return false;
    }
  }

  /// Resolves AT Protocol blob URLs to HTTP URLs for display
  String _resolveAtUriToHttpUrl(Uri uri, {bool isFullsize = false}) {
    final uriString = uri.toString();

    // If it's already an HTTP URL, return as is
    if (uriString.startsWith('http://') || uriString.startsWith('https://')) {
      return uriString;
    }

    // If it's an AT Protocol blob URL, convert to Bluesky CDN URL
    if (uriString.startsWith('at://')) {
      // Parse AT URI format: at://did/collection/rkey
      final match = RegExp(r'^at://([^/]+)/([^/]+)/(.+)$').firstMatch(uriString);
      if (match != null) {
        final did = match.group(1)!;
        final collection = match.group(2)!;
        final rkey = match.group(3)!;

        // For blob collections, use Bluesky's CDN
        if (collection == 'blob') {
          if (isFullsize) {
            return 'https://cdn.bsky.app/img/feed_fullsize/plain/$did/$rkey@jpeg';
          } else {
            return 'https://cdn.bsky.app/img/feed_thumbnail/plain/$did/$rkey@jpeg';
          }
        }
      }
    }

    // Fallback to original string
    return uriString;
  }

  String get videoUrl {
    switch (embed) {
      case EmbedViewVideo(:final playlist):
        return playlist.toString();
      case EmbedViewBskyVideo(:final playlist):
        // For Bluesky videos, return the AT URI as-is for blob API handling
        return playlist.toString();
      case EmbedViewBskyRecordWithMedia(:final media):
        // Handle nested media in record with media
        switch (media) {
          case EmbedViewVideo(:final playlist):
            return playlist.toString();
          case EmbedViewBskyVideo(:final playlist):
            // For Bluesky videos, return the AT URI as-is for blob API handling
            return playlist.toString();
          case _:
            return '';
        }
      case _:
        return '';
    }
  }

  List<String> get imageUrls {
    switch (embed) {
      case EmbedViewImage(:final images):
        return images.map((img) => img.fullsize.toString()).toList();
      case EmbedViewBskyImages(:final images):
        return images.map((img) => _resolveAtUriToHttpUrl(img.fullsize, isFullsize: true)).toList();
      case EmbedViewBskyRecordWithMedia(:final media):
        // Handle nested media in record with media
        switch (media) {
          case EmbedViewImage(:final images):
            return images.map((img) => img.fullsize.toString()).toList();
          case EmbedViewBskyImages(:final images):
            return images.map((img) => _resolveAtUriToHttpUrl(img.fullsize, isFullsize: true)).toList();
          case _:
            return [];
        }
      case _:
        return [];
    }
  }

  String get thumbnailUrl {
    switch (embed) {
      case EmbedViewVideo(:final thumbnail):
        return thumbnail.toString();
      case EmbedViewBskyVideo(:final thumbnail):
        return _resolveAtUriToHttpUrl(thumbnail);
      case EmbedViewImage(:final images):
        return images.first.thumb.toString();
      case EmbedViewBskyImages(:final images):
        return _resolveAtUriToHttpUrl(images.first.thumb);
      case EmbedViewBskyRecordWithMedia(:final media):
        // Handle nested media in record with media
        switch (media) {
          case EmbedViewVideo(:final thumbnail):
            return thumbnail.toString();
          case EmbedViewBskyVideo(:final thumbnail):
            return _resolveAtUriToHttpUrl(thumbnail);
          case EmbedViewImage(:final images):
            return images.first.thumb.toString();
          case EmbedViewBskyImages(:final images):
            return _resolveAtUriToHttpUrl(images.first.thumb);
          case _:
            return '';
        }
      case _:
        return '';
    }
  }
}

@freezed
class AudioView with _$AudioView {
  @JsonSerializable(explicitToJson: true)
  const factory AudioView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required dynamic record,
    required String title,
    required String coverArt,
    required DateTime indexedAt,
    int? useCount,
    AudioDetails? details,
    @Default([]) List<Label> labels,
  }) = _AudioView;
  const AudioView._();

  factory AudioView.fromJson(Map<String, dynamic> json) => _$AudioViewFromJson(json);
}

@freezed
class AudioDetails with _$AudioDetails {
  @JsonSerializable(explicitToJson: true)
  const factory AudioDetails({
    String? artist,
    String? title,
  }) = _AudioDetails;

  factory AudioDetails.fromJson(Map<String, dynamic> json) => _$AudioDetailsFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class EmbedView with _$EmbedView {
  const EmbedView._();

  // Spark embed types
  @FreezedUnionValue('so.sprk.embed.video#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.video({
    required String cid,
    @AtUriConverter() required Uri playlist,
    @AtUriConverter() required Uri thumbnail,
    String? alt,
  }) = EmbedViewVideo;

  @FreezedUnionValue('so.sprk.embed.images#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.image({required List<ViewImage> images}) = EmbedViewImage;

  // Bluesky embed types
  @FreezedUnionValue('app.bsky.embed.video#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyVideo({
    required String cid,
    @AtUriConverter() required Uri playlist,
    @AtUriConverter() required Uri thumbnail,
    String? alt,
  }) = EmbedViewBskyVideo;

  @FreezedUnionValue('app.bsky.embed.images#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyImages({required List<ViewImage> images}) = EmbedViewBskyImages;

  @FreezedUnionValue('app.bsky.embed.record#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyRecord({required EmbedViewRecord record}) = EmbedViewBskyRecord;

  @FreezedUnionValue('app.bsky.embed.recordWithMedia#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyRecordWithMedia({required EmbedViewRecord record, required EmbedView media}) =
      EmbedViewBskyRecordWithMedia;

  @FreezedUnionValue('app.bsky.embed.external#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyExternal({required EmbedViewExternal external}) = EmbedViewBskyExternal;

  factory EmbedView.fromJson(Map<String, dynamic> json) => _$EmbedViewFromJson(json);
}

@freezed
class EmbedViewExternal with _$EmbedViewExternal {
  @JsonSerializable(explicitToJson: true)
  const factory EmbedViewExternal({
    required String uri,
    @Default('') String title,
    @Default('') String description,
    @UriConverter() Uri? thumb,
  }) = _EmbedViewExternal;
  const EmbedViewExternal._();

  factory EmbedViewExternal.fromJson(Map<String, dynamic> json) => _$EmbedViewExternalFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class EmbedViewRecord with _$EmbedViewRecord {
  const EmbedViewRecord._();

  /// A full, viewable record.
  @FreezedUnionValue('app.bsky.embed.record#viewRecord')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedViewRecord.record({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required dynamic value, // This is typically a PostRecord
    required DateTime indexedAt,
    @Default([]) List<Label> labels,
    int? replyCount,
    int? repostCount,
    int? likeCount,
    int? quoteCount,
    @Default([]) List<EmbedView> embeds,
  }) = EmbedViewRecord_Record;

  /// A placeholder for a record that could not be found.
  @FreezedUnionValue('app.bsky.embed.record#viewNotFound')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedViewRecord.notFound({
    @AtUriConverter() required AtUri uri,
    required bool notFound,
  }) = EmbedViewRecord_NotFound;

  /// A placeholder for a record that is blocked.
  @FreezedUnionValue('app.bsky.embed.record#viewBlocked')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedViewRecord.blocked({
    @AtUriConverter() required AtUri uri,
    required bool blocked,
    required BlockedAuthor author,
  }) = EmbedViewRecord_Blocked;

  factory EmbedViewRecord.fromJson(Map<String, dynamic> json) => _$EmbedViewRecordFromJson(json);
}

@freezed
class FeedSkeleton with _$FeedSkeleton {
  @JsonSerializable(explicitToJson: true)
  const factory FeedSkeleton({required List<SkeletonFeedPost> feed, String? cursor}) = _FeedSkeleton;
  const FeedSkeleton._();

  factory FeedSkeleton.fromJson(Map<String, dynamic> json) => _$FeedSkeletonFromJson(json);
}

@freezed
class ImageUploadResult with _$ImageUploadResult {
  @JsonSerializable(explicitToJson: true)
  const factory ImageUploadResult({required String fullsize, required String alt, required Map<String, dynamic> image}) =
      _ImageUploadResult;
  const ImageUploadResult._();

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) => _$ImageUploadResultFromJson(json);
}

/// Represents the index range for a facet in the text
@freezed
class FacetIndex with _$FacetIndex {
  @JsonSerializable(explicitToJson: true)
  const factory FacetIndex({
    /// Start index (inclusive)
    required int byteStart,

    /// End index (exclusive)
    required int byteEnd,
  }) = _FacetIndex;
  const FacetIndex._();

  /// Create a FacetIndex from JSON
  factory FacetIndex.fromJson(Map<String, dynamic> json) => _$FacetIndexFromJson(json);
}

/// Represents a feature of a facet (mention, link, hashtag, etc.)
@Freezed(unionKey: r'$type')
class FacetFeature with _$FacetFeature {
  const FacetFeature._();

  // Spark facet feature types
  /// Mention feature for referencing a user
  @FreezedUnionValue('#mention')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.mention({required String did}) = MentionFeature;

  /// Link feature for URLs
  @FreezedUnionValue('#link')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.link({@AtUriConverter() required Uri uri}) = LinkFeature;

  /// Tag feature for hashtags
  @FreezedUnionValue('#tag')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.tag({required String tag}) = TagFeature;

  // Bluesky facet feature types
  /// Bluesky mention feature for referencing a user
  @FreezedUnionValue('app.bsky.richtext.facet#mention')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.bskyMention({required String did}) = BskyMentionFeature;

  /// Bluesky link feature for URLs
  @FreezedUnionValue('app.bsky.richtext.facet#link')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.bskyLink({@AtUriConverter() required AtUri uri}) = BskyLinkFeature;

  /// Bluesky tag feature for hashtags
  @FreezedUnionValue('app.bsky.richtext.facet#tag')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.bskyTag({required String tag}) = BskyTagFeature;

  /// Create a FacetFeature from JSON
  factory FacetFeature.fromJson(Map<String, dynamic> json) => _$FacetFeatureFromJson(json);
}

/// Represents a richtext facet for text formatting, mentions, links, etc.
@freezed
class Facet with _$Facet {
  @JsonSerializable(explicitToJson: true)
  const factory Facet({
    /// Index range for the facet in the text
    required FacetIndex index,

    /// Features represented by this facet (mention, link, hashtag, etc.)
    required List<FacetFeature> features,
  }) = _Facet;
  const Facet._();

  /// Create a Facet from JSON
  factory Facet.fromJson(Map<String, dynamic> json) => _$FacetFromJson(json);
}

@freezed
class ViewImage with _$ViewImage {
  @JsonSerializable(explicitToJson: true)
  const factory ViewImage({
    @AtUriConverter() required Uri thumb,
    @AtUriConverter() required Uri fullsize,
    String? alt,
    // aspectRatio: {width: int, height: int}
  }) = _ViewImage;
  const ViewImage._();

  factory ViewImage.fromJson(Map<String, dynamic> json) => _$ViewImageFromJson(json);
}

@Freezed(unionKey: r'$type')
class Thread with _$Thread {
  const Thread._();

  // NORMAL POST
  @FreezedUnionValue('so.sprk.feed.defs#threadViewPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.threadViewPost({required PostView post, Thread? parent, List<Thread>? replies, ThreadContext? context}) =
      ThreadViewPost;

  // NOT FOUND POST
  @FreezedUnionValue('so.sprk.feed.defs#notFoundPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.notFoundPost({@AtUriConverter() required AtUri uri, required bool notFound}) = NotFoundPost;

  // BLOCKED POST
  @FreezedUnionValue('so.sprk.feed.defs#blockedPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.blockedPost({@AtUriConverter() required AtUri uri, required bool blocked, required BlockedAuthor author}) =
      BlockedPost;

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);

  factory Thread.fromBsky({required bsky.PostThreadView thread, required AtUri uri}) {
    switch (thread) {
      case bsky.UPostThreadViewRecord(:final data):
        try {
          var embed = data.post.embed;
          if (data.post.embed is bsky.UEmbedViewExternal) {
            embed = null;
          }
          final postJson = data.post.copyWith(embed: embed);

          // Create PostView with safer parsing
          final postViewJson = postJson.toJson();

          // Ensure required fields are not null
          if (postViewJson['cid'] == null) {
            throw Exception('Post cid is null');
          }
          if (postViewJson['uri'] == null) {
            throw Exception('Post uri is null');
          }
          if (postViewJson['author'] == null) {
            throw Exception('Post author is null');
          }
          if (postViewJson['record'] == null) {
            throw Exception('Post record is null');
          }
          if (postViewJson['indexedAt'] == null) {
            throw Exception('Post indexedAt is null');
          }

          // Ensure author required fields are not null
          final authorJson = postViewJson['author'] as Map<String, dynamic>;
          if (authorJson['did'] == null) {
            throw Exception('Author did is null');
          }
          if (authorJson['handle'] == null) {
            throw Exception('Author handle is null');
          }

          // Check embed data if present - this is where the error is occurring
          if (postViewJson['embed'] != null) {
            final embedJson = postViewJson['embed'] as Map<String, dynamic>;

            // Check for external embed without required cid
            if (embedJson[r'$type'] == 'app.bsky.embed.external#view') {
              if (embedJson['cid'] == null) {
                postViewJson.remove('embed');
              }
            }

            // If it's a record embed, check the record data
            if (embedJson[r'$type'] == 'app.bsky.embed.record#view' && embedJson['record'] != null) {
              final recordJson = embedJson['record'] as Map<String, dynamic>;

              // Check required fields for EmbedViewBskyRecordViewRecord
              if (recordJson[r'$type'] == 'app.bsky.embed.record#viewRecord') {
                if (recordJson['cid'] == null) {
                  postViewJson.remove('embed');
                }
                if (recordJson['uri'] == null) {
                  postViewJson.remove('embed');
                }
                if (recordJson['author'] == null) {
                  postViewJson.remove('embed');
                }
                if (recordJson['value'] == null) {
                  postViewJson.remove('embed');
                }
                if (recordJson['indexedAt'] == null) {
                  postViewJson.remove('embed');
                }

                // Check nested embeds array in the record value
                if (recordJson['embeds'] != null && recordJson['embeds'] is List) {
                  final embedsList = recordJson['embeds'] as List;
                  var shouldRemoveEmbed = false;

                  for (final nestedEmbed in embedsList) {
                    if (nestedEmbed is Map<String, dynamic>) {
                      // Check external embeds in the nested embeds
                      if (nestedEmbed[r'$type'] == 'app.bsky.embed.external#view' && nestedEmbed['cid'] == null) {
                        shouldRemoveEmbed = true;
                        break;
                      }
                    }
                  }

                  if (shouldRemoveEmbed) {
                    postViewJson.remove('embed');
                  }
                }
              }
            }

            // Enhanced check for recordWithMedia embeds
            if (embedJson[r'$type'] == 'app.bsky.embed.recordWithMedia#view') {
              // Check the record part
              if (embedJson['record'] != null) {
                final recordEmbedJson = embedJson['record'] as Map<String, dynamic>;
                if (recordEmbedJson['record'] != null) {
                  final recordJson = recordEmbedJson['record'] as Map<String, dynamic>;

                  // Check if it's a viewRecord and has required fields
                  if (recordJson[r'$type'] == 'app.bsky.embed.record#viewRecord') {
                    if (recordJson['uri'] == null ||
                        recordJson['cid'] == null ||
                        recordJson['author'] == null ||
                        recordJson['value'] == null ||
                        recordJson['indexedAt'] == null) {
                      postViewJson.remove('embed');
                    }
                  }
                }
              }
            }

            // Additional safety check - if we have any embed that might contain a record view, validate it
            void validateRecordViewInEmbed(Map<String, dynamic> embedData, String path) {
              if (embedData[r'$type'] == 'app.bsky.embed.record#viewRecord') {
                if (embedData['uri'] == null ||
                    embedData['cid'] == null ||
                    embedData['author'] == null ||
                    embedData['value'] == null ||
                    embedData['indexedAt'] == null) {
                  postViewJson.remove('embed');
                  return;
                }
              }

              // Recursively check nested structures
              embedData.forEach((key, value) {
                if (value is Map<String, dynamic>) {
                  validateRecordViewInEmbed(value, '$path.$key');
                } else if (value is List) {
                  for (var i = 0; i < value.length; i++) {
                    if (value[i] is Map<String, dynamic>) {
                      validateRecordViewInEmbed(value[i] as Map<String, dynamic>, '$path.$key[$i]');
                    }
                  }
                }
              });
            }

            // Run the validation on the entire embed structure
            if (postViewJson['embed'] != null) {
              validateRecordViewInEmbed(postViewJson['embed'] as Map<String, dynamic>, 'embed');
            }
          }

          final thread = Thread.threadViewPost(
            post: PostView.fromJson(postViewJson),
            parent: data.parent != null ? Thread.fromBsky(thread: data.parent!, uri: uri) : null,
            replies: data.replies
                ?.map((reply) {
                  switch (reply) {
                    case bsky.UPostThreadViewRecord(:final data):
                      return Thread.fromBsky(thread: reply, uri: data.post.uri);
                    case bsky.UPostThreadViewNotFound(:final data):
                      return Thread.notFoundPost(uri: data.uri, notFound: true);
                    case bsky.UPostThreadViewBlocked(:final data):
                      return Thread.blockedPost(
                        uri: data.uri,
                        blocked: true,
                        author: BlockedAuthor.fromJson(data.author.toJson()),
                      );
                    case bsky.UPostThreadViewUnknown():
                      // Skip unknown reply types by returning null
                      return null;
                  }
                })
                .whereType<Thread>()
                .toList(),
          );
          return thread;
        } catch (e) {
          rethrow;
        }
      case bsky.UPostThreadViewNotFound():
        return Thread.notFoundPost(uri: uri, notFound: true);
      case bsky.UPostThreadViewBlocked(:final data):
        return Thread.blockedPost(uri: uri, blocked: true, author: BlockedAuthor.fromJson(data.author.toJson()));
      default:
        throw Exception('Unsupported thread type: ${thread.runtimeType}');
    }
  }
}

@freezed
class ThreadContext with _$ThreadContext {
  @JsonSerializable(explicitToJson: true)
  const factory ThreadContext({@AtUriConverter() AtUri? rootAuthorLike}) = _ThreadContext;
  const ThreadContext._();

  factory ThreadContext.fromJson(Map<String, dynamic> json) => _$ThreadContextFromJson(json);
}

@freezed
class StoryView with _$StoryView {
  @JsonSerializable(explicitToJson: true)
  const factory StoryView({
    required String cid,
    @AtUriConverter() required AtUri uri,
    required ProfileViewBasic author,
    required StoryRecord record,
    required DateTime indexedAt,
    EmbedView? media,
    // viewer eventually i think
  }) = _StoryView;
  const StoryView._();

  factory StoryView.fromJson(Map<String, dynamic> json) => _$StoryViewFromJson(json);
}
