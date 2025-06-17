import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

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

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
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
  const FeedViewPost._();
  @JsonSerializable(explicitToJson: true)
  const factory FeedViewPost({
    required PostView post,
    ReplyRef? reply,
    // "reason": { "type": "union", "refs": ["#reasonRepost", "#reasonPin"] } i think we don't have to use this value for now
    // there's also a String feedContext "Context provided by feed generator that may be passed back alongside interactions."
  }) = _FeedViewPostPost;

  factory FeedViewPost.fromJson(Map<String, dynamic> json) => _$FeedViewPostFromJson(json);
}

@freezed
class ReplyRef with _$ReplyRef {
  const ReplyRef._();
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRef({
    required ReplyRefPostReference root, // post, not found or blocked
    required ReplyRefPostReference parent, // post, not found or blocked
    ProfileViewBasic? grandparentAuthor,
  }) = _ReplyRef;

  factory ReplyRef.fromJson(Map<String, dynamic> json) => _$ReplyRefFromJson(json);
}

/// Can be a post, a not found post, or a blocked post
@Freezed(unionKey: r'$type')
sealed class ReplyRefPostReference with _$ReplyRefPostReference {
  const ReplyRefPostReference._();
  @FreezedUnionValue('so.sprk.feed.defs#post')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.post({required PostView post}) = ReplyRefPostReferencePost;

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
  const BlockedAuthor._();
  @JsonSerializable(explicitToJson: true)
  const factory BlockedAuthor({required String did, Viewer? viewer}) = _BlockedAuthor;

  factory BlockedAuthor.fromJson(Map<String, dynamic> json) => _$BlockedAuthorFromJson(json);
}

@freezed
class PostThread with _$PostThread {
  const PostThread._();
  @JsonSerializable(explicitToJson: true)
  const factory PostThread({required PostView post, List<PostView>? parent, List<PostView>? replies}) = _PostThread;

  factory PostThread.fromJson(Map<String, dynamic> json) => _$PostThreadFromJson(json);
}

@freezed
class Viewer with _$Viewer {
  const Viewer._();
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

  factory Viewer.fromJson(Map<String, dynamic> json) => _$ViewerFromJson(json);
}

@freezed
class PostView with _$PostView {
  const PostView._();
  @JsonSerializable(explicitToJson: true)
  const factory PostView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required PostRecord record,
    @Default(false) bool isRepost,
    required DateTime indexedAt,
    int? likeCount,
    int? replyCount,
    int? repostCount,
    int? quoteCount,
    List<Label>? labels,
    Viewer? viewer,
    //SoundView? sound,
    EmbedView? embed, // aturi
  }) = _PostView;

  factory PostView.fromJson(Map<String, dynamic> json) => _$PostViewFromJson(json);

  bool get isSprk => RegExp(r'^at://[^/]+/so\.sprk\.feed\.post/[^/]+$').hasMatch(uri.toString());

    /// Resolves AT Protocol blob URLs to HTTP URLs for display
  String _resolveAtUriToHttpUrl(AtUri atUri, {bool isFullsize = false}) {
    final uriString = atUri.toString();

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

@Freezed(unionKey: r'$type')
sealed class EmbedView with _$EmbedView {
  const EmbedView._();

  // Spark embed types
  @FreezedUnionValue('so.sprk.embed.video#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.video({
    required String cid,
    @AtUriConverter() required AtUri playlist,
    @AtUriConverter() required AtUri thumbnail,
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
    @AtUriConverter() required AtUri playlist,
    @AtUriConverter() required AtUri thumbnail,
    String? alt,
  }) = EmbedViewBskyVideo;

  @FreezedUnionValue('app.bsky.embed.images#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyImages({required List<ViewImage> images}) = EmbedViewBskyImages;

  @FreezedUnionValue('app.bsky.embed.record#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyRecord({required StrongRef record, required String cid}) = EmbedViewBskyRecord;

  @FreezedUnionValue('app.bsky.embed.recordWithMedia#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyRecordWithMedia({required StrongRef record, required EmbedView media, required String cid}) =
      EmbedViewBskyRecordWithMedia;

  @FreezedUnionValue('app.bsky.embed.external#view')
  @JsonSerializable(explicitToJson: true)
  const factory EmbedView.bskyExternal({
    required EmbedViewExternal external,
    required String cid,
  }) = EmbedViewBskyExternal;

  factory EmbedView.fromJson(Map<String, dynamic> json) => _$EmbedViewFromJson(json);
}

@freezed
class EmbedViewExternal with _$EmbedViewExternal {
  const EmbedViewExternal._();

  @JsonSerializable(explicitToJson: true)
  const factory EmbedViewExternal({
    required String uri,
    required String title,
    required String description,
    @AtUriConverter() AtUri? thumb,
  }) = _EmbedViewExternal;

  factory EmbedViewExternal.fromJson(Map<String, dynamic> json) => _$EmbedViewExternalFromJson(json);
}

@freezed
class FeedSkeleton with _$FeedSkeleton {
  const FeedSkeleton._();
  @JsonSerializable(explicitToJson: true)
  const factory FeedSkeleton({required List<SkeletonFeedPost> feed, String? cursor}) = _FeedSkeleton;

  factory FeedSkeleton.fromJson(Map<String, dynamic> json) => _$FeedSkeletonFromJson(json);
}

@freezed
class ImageUploadResult with _$ImageUploadResult {
  const ImageUploadResult._();
  @JsonSerializable(explicitToJson: true)
  const factory ImageUploadResult({required String fullsize, required String alt, required Map<String, dynamic> image}) =
      _ImageUploadResult;

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) => _$ImageUploadResultFromJson(json);
}

/// Represents the index range for a facet in the text
@freezed
class FacetIndex with _$FacetIndex {
  const FacetIndex._();

  @JsonSerializable(explicitToJson: true)
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
  const factory FacetFeature.link({@AtUriConverter() required AtUri uri}) = LinkFeature;

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
  const Facet._();

  @JsonSerializable(explicitToJson: true)
  const factory Facet({
    /// Index range for the facet in the text
    required FacetIndex index,

    /// Features represented by this facet (mention, link, hashtag, etc.)
    required List<FacetFeature> features,
  }) = _Facet;

  /// Create a Facet from JSON
  factory Facet.fromJson(Map<String, dynamic> json) => _$FacetFromJson(json);
}

@freezed
class ViewImage with _$ViewImage {
  const ViewImage._();

  @JsonSerializable(explicitToJson: true)
  const factory ViewImage({
    @AtUriConverter() required AtUri thumb,
    @AtUriConverter() required AtUri fullsize,
    String? alt,
    // aspectRatio: {width: int, height: int}
  }) = _ViewImage;

  factory ViewImage.fromJson(Map<String, dynamic> json) => _$ViewImageFromJson(json);
}

@Freezed(unionKey: r'$type')
class Thread with _$Thread {
  const Thread._();

  @FreezedUnionValue('so.sprk.feed.defs#threadViewPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.threadViewPost({required PostView post, Thread? parent, List<Thread>? replies, ThreadContext? context}) =
      ThreadViewPost;

  @FreezedUnionValue('so.sprk.feed.defs#notFoundPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.notFoundPost({@AtUriConverter() required AtUri uri, required bool notFound}) = NotFoundPost;

  @FreezedUnionValue('so.sprk.feed.defs#blockedPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.blockedPost({@AtUriConverter() required AtUri uri, required bool blocked, required BlockedAuthor author}) =
      BlockedPost;

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);
}

@freezed
class ThreadContext with _$ThreadContext {
  const ThreadContext._();
  @JsonSerializable(explicitToJson: true)
  const factory ThreadContext({@AtUriConverter() AtUri? rootAuthorLike}) = _ThreadContext;

  factory ThreadContext.fromJson(Map<String, dynamic> json) => _$ThreadContextFromJson(json);
}

@freezed
class StoryView with _$StoryView {
  const StoryView._();
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

  factory StoryView.fromJson(Map<String, dynamic> json) => _$StoryViewFromJson(json);
}
