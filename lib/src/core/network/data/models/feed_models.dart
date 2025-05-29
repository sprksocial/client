import 'dart:io';

import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'actor_models.dart';

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

/// https://pub.dev/packages/freezed#union-types <= read this to know how to use pattern matching to know the type of the object

enum HardCodedFeed {
  following('Following'), // posts from people you follow (bsky/sprk)
  mutuals('Mutuals'), // posts from people you follow who follow each other (bsky/sprk)
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
    @AtUriConverter() AtUri? uri,
    CID? cid,

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
  const factory Feed.custom({required String name, @AtUriConverter() required AtUri uri}) = FeedCustom;

  /// HardCoded feeds can be "fake", so they don't have a uri
  const factory Feed.hardCoded({required HardCodedFeed hardCodedFeed}) = FeedHardCoded;

  String get name {
    return when(custom: (name, did) => name, hardCoded: (hardCodedFeed) => hardCodedFeed.name);
  }

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
}

@freezed
class SkeletonFeedPost with _$SkeletonFeedPost {
  const factory SkeletonFeedPost({
    @AtUriConverter() required AtUri uri,
    // "reason": { "type": "union", "refs": ["#reasonRepost", "#reasonPin"] } i think we don't have to use this value for now
    // there's also a String feedContext "Context provided by feed generator that may be passed back alongside interactions."
  }) = _SkeletonFeedPost;

  factory SkeletonFeedPost.fromJson(Map<String, dynamic> json) => _$SkeletonFeedPostFromJson(json);
}

/// GetTimeline returns a FeedViewPost array
@freezed
class FeedViewPost with _$FeedViewPost {
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
  const factory ReplyRefPostReference.post({required PostView post}) = ReplyRefPostReferencePost;

  @FreezedUnionValue('so.sprk.feed.defs#notFoundPost')
  const factory ReplyRefPostReference.notFoundPost({@AtUriConverter() required AtUri uri, required bool notFound}) =
      ReplyRefPostReferenceNotFoundPost;

  @FreezedUnionValue('so.sprk.feed.defs#blockedPost')
  const factory ReplyRefPostReference.blockedPost({
    @AtUriConverter() required AtUri uri,
    required bool blocked,
    required BlockedAuthor author,
  }) = ReplyRefPostReferenceBlockedPost;

  factory ReplyRefPostReference.fromJson(Map<String, dynamic> json) => _$ReplyRefPostReferenceFromJson(json);
}

@freezed
class BlockedAuthor with _$BlockedAuthor {
  const factory BlockedAuthor({required String did, Viewer? viewer}) = _BlockedAuthor;

  factory BlockedAuthor.fromJson(Map<String, dynamic> json) => _$BlockedAuthorFromJson(json);
}

@freezed
class PostThread with _$PostThread {
  const factory PostThread({required PostView post, List<PostView>? parent, List<PostView>? replies}) = _PostThread;

  factory PostThread.fromJson(Map<String, dynamic> json) => _$PostThreadFromJson(json);
}

/// Skeleton of a ReplyRef. Needs to be hydrated.
@freezed
class RecordReplyRef with _$RecordReplyRef {
  const factory RecordReplyRef({required StrongRef root, required StrongRef parent}) = _RecordReplyRef;

  factory RecordReplyRef.fromJson(Map<String, dynamic> json) => _$RecordReplyRefFromJson(json);
}

@freezed
class Viewer with _$Viewer {
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
class PostRecord with _$PostRecord {
  const PostRecord._();
  const factory PostRecord({
    required DateTime createdAt,
    @JsonKey(defaultValue: '') String? text,
    @JsonKey(defaultValue: []) List<Facet>? facets,
    RecordReplyRef? reply,
    List<String>? langs,
    List<String>? tags,
    List<SelfLabel>? selfLabels,
    Embed? embed, // blob
    // threadgate
  }) = _PostRecordVideo;

  factory PostRecord.fromJson(Map<String, dynamic> json) => _$PostRecordFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class Embed with _$Embed {
  const Embed._();
  @FreezedUnionValue('so.sprk.embed.video')
  const factory Embed.video({required VideoEmbed video}) = EmbedVideo;
  @FreezedUnionValue('so.sprk.embed.images')
  const factory Embed.image({required ImageEmbed image}) = EmbedImage;

  factory Embed.fromJson(Map<String, dynamic> json) => _$EmbedFromJson(json);
}

@freezed
class PostView with _$PostView {
  const PostView._();
  const factory PostView({
    @AtUriConverter() required AtUri uri,
    required CID cid,
    required ProfileViewBasic author,
    required PostRecord record,
    @Default(false) bool isRepost,
    required DateTime indexedAt,
    int? likeCount,
    int? replyCount,
    int? repostCount,
    int? quoteCount,
    List<Label>? labels,
    //SoundView? sound,
    EmbedView? embed, // aturi
    String? cachedEmbedFile
  }) = VideoPostView;

  factory PostView.fromJson(Map<String, dynamic> json) => _$PostViewFromJson(json);

  bool get isSprk => RegExp(r'^at://[^/]+/so\.sprk\.feed\.post/[^/]+$').hasMatch(uri.toString());

  String get videoUrl {
    if (isSprk) {
      // extract DID from uri
      final did = uri.hostname;
      return 'media.sprk.so/video/$did/$cid';
    } else {
      if (embed case EmbedViewVideo(:final video)) {
        return video.playlist.toString();
      }
    }
    return '';
  }
}

@Freezed(unionKey: r'$type')
sealed class EmbedView with _$EmbedView {
  const EmbedView._();
  @FreezedUnionValue('so.sprk.embed.video#view')
  const factory EmbedView.video({required VideoView video}) = EmbedViewVideo;
  @FreezedUnionValue('so.sprk.embed.images#view')
  const factory EmbedView.image({required ImageView image}) = EmbedViewImage;

  factory EmbedView.fromJson(Map<String, dynamic> json) => _$EmbedViewFromJson(json);
}

@freezed
class FeedSkeleton with _$FeedSkeleton {
  const factory FeedSkeleton({required List<SkeletonFeedPost> feed, String? cursor}) = _FeedSkeleton;

  factory FeedSkeleton.fromJson(Map<String, dynamic> json) => _$FeedSkeletonFromJson(json);
}

@freezed
class ImageUploadResult with _$ImageUploadResult {
  const factory ImageUploadResult({required String fullsize, required String alt, required Map<String, dynamic> image}) =
      _ImageUploadResult;

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) => _$ImageUploadResultFromJson(json);
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
@Freezed(unionKey: r'$type')
class FacetFeature with _$FacetFeature {
  const FacetFeature._();

  /// Mention feature for referencing a user
  @FreezedUnionValue('#mention')
  const factory FacetFeature.mention({required String did}) = MentionFeature;

  /// Link feature for URLs
  @FreezedUnionValue('#link')
  const factory FacetFeature.link({@AtUriConverter() required AtUri uri}) = LinkFeature;

  /// Tag feature for hashtags
  @FreezedUnionValue('#tag')
  const factory FacetFeature.tag({required String tag}) = TagFeature;

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
    required Blob video,

    // remaining fields that are in the json
    // List<Caption> captions,
    // AspectRatio aspectRatio, {width: int, height: int}
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

  const factory ImageEmbed({required List<Image> images}) = _ImageEmbed;

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

@Freezed(unionKey: r'$type')
class Thread with _$Thread {
  const Thread._();

  @FreezedUnionValue('so.sprk.feed.defs#threadViewPost')
  const factory Thread.threadViewPost({required PostView post, Thread? parent, List<Thread>? replies, ThreadContext? context}) =
      ThreadViewPost;

  @FreezedUnionValue('so.sprk.feed.defs#notFoundPost')
  const factory Thread.notFoundPost({@AtUriConverter() required AtUri uri, required bool notFound}) = NotFoundPost;

  @FreezedUnionValue('so.sprk.feed.defs#blockedPost')
  const factory Thread.blockedPost({@AtUriConverter() required AtUri uri, required bool blocked, required BlockedAuthor author}) =
      BlockedPost;

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);
}

@freezed
class ThreadContext with _$ThreadContext {
  const factory ThreadContext({@AtUriConverter() AtUri? rootAuthorLike}) = _ThreadContext;

  factory ThreadContext.fromJson(Map<String, dynamic> json) => _$ThreadContextFromJson(json);
}
