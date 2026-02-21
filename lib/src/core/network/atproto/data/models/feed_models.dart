import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_feed_getpostthread.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/adapters/bsky/feed_adapter.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/utils/uri_converter.dart';

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

PostRecord _postRecordFromJson(dynamic json) {
  if (json is! Map<String, dynamic>) {
    throw Exception(
      'Expected Map<String, dynamic> but got ${json.runtimeType}',
    );
  }
  final record = Record.fromJson(json);
  if (record is PostRecord) {
    return record;
  }
  throw Exception('Expected PostRecord but got ${record.runtimeType}');
}

Map<String, dynamic> _postRecordToJson(PostRecord record) => record.toJson();

StoryRecord _storyRecordFromJson(dynamic json) {
  if (json is! Map<String, dynamic>) {
    throw Exception(
      'Expected Map<String, dynamic> but got ${json.runtimeType}',
    );
  }
  final record = Record.fromJson(json);
  if (record is StoryRecord) {
    return record;
  }
  throw Exception('Expected StoryRecord but got ${record.runtimeType}');
}

Map<String, dynamic> _storyRecordToJson(StoryRecord record) => record.toJson();

/// https://pub.dev/packages/freezed#union-types <= read this to know how to use pattern matching to know the type of the object
@freezed
abstract class GeneratorViewerState with _$GeneratorViewerState {
  @JsonSerializable(explicitToJson: true)
  const factory GeneratorViewerState({
    @AtUriConverter() AtUri? like,
  }) = _GeneratorViewerState;
  const GeneratorViewerState._();

  factory GeneratorViewerState.fromJson(Map<String, dynamic> json) =>
      _$GeneratorViewerStateFromJson(json);
}

@freezed
abstract class GeneratorView with _$GeneratorView {
  @JsonSerializable(explicitToJson: true)
  const factory GeneratorView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required String did,
    required ProfileViewBasic creator,
    required String displayName,
    required DateTime indexedAt,
    String? description,
    @Default([]) List<Facet> descriptionFacets,
    @UriConverter() Uri? avatar,
    @Default(0) int likeCount,
    @Default(true) bool acceptsInteractions,
    @Default([]) List<Label> labels,
    GeneratorViewerState? viewer,
  }) = _GeneratorView;
  const GeneratorView._();

  factory GeneratorView.fromJson(Map<String, dynamic> json) =>
      _$GeneratorViewFromJson(json);
}

/// The feeds that are actually used in the app
@freezed
abstract class Feed with _$Feed {
  @JsonSerializable(explicitToJson: true)
  factory Feed({
    required String type,
    required SavedFeed config,
    GeneratorView? view,
  }) = _Feed;
  const Feed._();

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
}

/// Skeleton of a FeedView. Needs to be hydrated.
@freezed
abstract class SkeletonFeedPost with _$SkeletonFeedPost {
  @JsonSerializable(explicitToJson: true)
  const factory SkeletonFeedPost({
    @AtUriConverter() required AtUri uri,
  }) = _SkeletonFeedPost;

  factory SkeletonFeedPost.fromJson(Map<String, dynamic> json) =>
      _$SkeletonFeedPostFromJson(json);
}

@freezed
sealed class HardcodedFeedExtraInfo with _$HardcodedFeedExtraInfo {
  const HardcodedFeedExtraInfo._();

  @JsonSerializable(explicitToJson: true)
  const factory HardcodedFeedExtraInfo.shared({
    required ProfileViewBasic from,
    String? message,
  }) = HardcodedFeedExtraInfoShared;

  factory HardcodedFeedExtraInfo.fromJson(Map<String, dynamic> json) =>
      _$HardcodedFeedExtraInfoFromJson(json);
}

/// GetTimeline returns a FeedViewPost array
@Freezed(unionKey: r'$type')
sealed class FeedViewPost with _$FeedViewPost {
  const FeedViewPost._();

  @FreezedUnionValue('so.sprk.feed.defs#feedPostView')
  @JsonSerializable(explicitToJson: true)
  const factory FeedViewPost.post({
    required PostView post,
    ReplyRef? reply,
  }) = FeedViewPostPost;

  @FreezedUnionValue('so.sprk.feed.defs#feedReplyView')
  @JsonSerializable(explicitToJson: true)
  const factory FeedViewPost.reply({
    required ReplyView reply,
    ReplyRef? replyRef,
  }) = FeedViewPostReply;

  factory FeedViewPost.fromJson(Map<String, dynamic> json) =>
      _$FeedViewPostFromJson(json);

  PostView? get asPost => mapOrNull(post: (p) => p.post);
  ReplyView? get asReply => mapOrNull(reply: (r) => r.reply);

  ProfileViewBasic get author => map(
    post: (p) => p.post.author,
    reply: (r) => r.reply.author,
  );

  AtUri get uri => map(
    post: (p) => p.post.uri,
    reply: (r) => r.reply.uri,
  );

  String get cid => map(
    post: (p) => p.post.cid,
    reply: (r) => r.reply.cid,
  );

  MediaView? get media => map(
    post: (p) => p.post.displayMedia,
    reply: (r) => r.reply.media,
  );

  ViewerState? get viewerState => mapOrNull(post: (p) => p.post.viewer);
  ReplyViewerState? get replyViewerState =>
      mapOrNull(reply: (r) => r.reply.viewer);

  String get displayText => map(
    post: (p) => p.post.displayText,
    reply: (r) => r.reply.displayText,
  );

  List<Facet> get displayFacets => map(
    post: (p) => p.post.displayFacets,
    reply: (r) => r.reply.displayFacets,
  );
}

@freezed
abstract class FeedView with _$FeedView {
  @JsonSerializable(explicitToJson: true)
  const factory FeedView({
    required List<FeedViewPost> feed,
    String? cursor,
  }) = _FeedView;
  const FeedView._();

  factory FeedView.fromJson(Map<String, dynamic> json) =>
      _$FeedViewFromJson(json);
}

@freezed
abstract class ReplyRef with _$ReplyRef {
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRef({
    required ReplyRefPostReference root, // post, not found or blocked
    required ReplyRefPostReference parent, // post, not found or blocked
    ProfileViewBasic? grandparentAuthor,
  }) = _ReplyRef;
  const ReplyRef._();

  factory ReplyRef.fromJson(Map<String, dynamic> json) =>
      _$ReplyRefFromJson(json);
}

/// Can be a post, a not found post, or a blocked post
@Freezed(unionKey: r'$type')
sealed class ReplyRefPostReference with _$ReplyRefPostReference {
  const ReplyRefPostReference._();
  @FreezedUnionValue('so.sprk.feed.defs#post')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.post({required PostView post}) =
      ReplyRefPostReferencePost;

  @FreezedUnionValue('app.bsky.feed.defs#postView')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.bskyPost({required PostView post}) =
      ReplyRefPostReferenceBskyPost;

  @FreezedUnionValue('so.sprk.feed.defs#replyView')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.reply({required ReplyView reply}) =
      ReplyRefPostReferenceReply;

  @FreezedUnionValue('so.sprk.feed.defs#notFoundPost')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.notFoundPost({
    @AtUriConverter() required AtUri uri,
    required bool notFound,
  }) = ReplyRefPostReferenceNotFoundPost;

  @FreezedUnionValue('so.sprk.feed.defs#blockedPost')
  @JsonSerializable(explicitToJson: true)
  const factory ReplyRefPostReference.blockedPost({
    @AtUriConverter() required AtUri uri,
    required bool blocked,
    required BlockedAuthor author,
  }) = ReplyRefPostReferenceBlockedPost;

  factory ReplyRefPostReference.fromJson(Map<String, dynamic> json) =>
      _$ReplyRefPostReferenceFromJson(json);
}

@freezed
abstract class BlockedAuthor with _$BlockedAuthor {
  @JsonSerializable(explicitToJson: true)
  const factory BlockedAuthor({required String did, ViewerState? viewer}) =
      _BlockedAuthor;
  const BlockedAuthor._();

  factory BlockedAuthor.fromJson(Map<String, dynamic> json) =>
      _$BlockedAuthorFromJson(json);
}

@freezed
abstract class PostThread with _$PostThread {
  @JsonSerializable(explicitToJson: true)
  const factory PostThread({
    required PostView post,
    List<PostView>? parent,
    List<PostView>? replies,
  }) = _PostThread;
  const PostThread._();

  factory PostThread.fromJson(Map<String, dynamic> json) =>
      _$PostThreadFromJson(json);
}

/// Metadata about the requesting account's relationship with the subject.
/// Only has meaningful content for authed requests.
@freezed
abstract class ViewerState with _$ViewerState {
  @JsonSerializable(explicitToJson: true)
  const factory ViewerState({
    @AtUriConverter() AtUri? repost,
    @AtUriConverter() AtUri? like,
    bool? threadMuted,
    bool? replyDisabled,
    bool? embeddingDisabled,
    List<KnownInteraction>? knownInteractions,
  }) = _ViewerState;
  const ViewerState._();

  factory ViewerState.fromJson(Map<String, dynamic> json) =>
      _$ViewerStateFromJson(json);
}

/// Metadata about the requesting account's relationship with reply content.
/// Only has meaningful content for authed requests.
@freezed
abstract class ReplyViewerState with _$ReplyViewerState {
  @JsonSerializable(explicitToJson: true)
  const factory ReplyViewerState({
    @AtUriConverter() AtUri? like,
    bool? threadMuted,
    bool? replyDisabled,
    bool? embeddingDisabled,
  }) = _ReplyViewerState;
  const ReplyViewerState._();

  factory ReplyViewerState.fromJson(Map<String, dynamic> json) =>
      _$ReplyViewerStateFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class KnownInteraction with _$KnownInteraction {
  const KnownInteraction._();

  @FreezedUnionValue('so.sprk.feed.defs#knownRepost')
  @JsonSerializable(explicitToJson: true)
  const factory KnownInteraction.repost({
    required ProfileViewBasic by,
    required DateTime indexedAt,
    @AtUriConverter() AtUri? uri,
    String? cid,
  }) = KnownRepost;

  @FreezedUnionValue('so.sprk.feed.defs#knownLike')
  @JsonSerializable(explicitToJson: true)
  const factory KnownInteraction.like({
    required ProfileViewBasic by,
    required DateTime indexedAt,
    @AtUriConverter() AtUri? uri,
    String? cid,
  }) = KnownLike;

  @FreezedUnionValue('so.sprk.feed.defs#knownReply')
  @JsonSerializable(explicitToJson: true)
  const factory KnownInteraction.reply({
    required ProfileViewBasic by,
    required DateTime indexedAt,
    @AtUriConverter() AtUri? uri,
    String? cid,
    String? text,
  }) = KnownReply;

  factory KnownInteraction.fromJson(Map<String, dynamic> json) =>
      _$KnownInteractionFromJson(json);
}

@freezed
abstract class PostView with _$PostView {
  @JsonSerializable(explicitToJson: true)
  const factory PostView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    @JsonKey(fromJson: _postRecordFromJson, toJson: _postRecordToJson)
    required PostRecord record,
    required DateTime indexedAt,
    @Default(false) bool isRepost,
    int? likeCount,
    int? replyCount,
    int? repostCount,
    List<Label>? labels,
    ViewerState? viewer,
    MediaView? media,
    AudioView? sound,
  }) = _PostView;
  const PostView._();

  factory PostView.fromJson(Map<String, dynamic> json) =>
      _$PostViewFromJson(json);

  bool get isSprk => RegExp(
    r'^at://[^/]+/so\.sprk\.feed\.post/[^/]+$',
  ).hasMatch(uri.toString());

  MediaView? get displayMedia => media;

  String get displayText => record.caption.text;

  List<Facet> get displayFacets => record.caption.facets;

  /// Returns true if post has a video or image embed (content we want to show)
  bool get hasSupportedMedia {
    final mediaToCheck = displayMedia;
    if (mediaToCheck == null) return false;

    switch (mediaToCheck) {
      case MediaViewVideo():
      case MediaViewBskyVideo():
      case MediaViewBskyImages():
      case MediaViewImage():
      case MediaViewImages():
        return true;
      case MediaViewBskyRecordWithMedia(:final media):
        // Check nested media in record with media
        switch (media) {
          case MediaViewVideo():
          case MediaViewBskyVideo():
          case MediaViewBskyImages():
          case MediaViewImage():
          case MediaViewImages():
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
      final match = RegExp(
        r'^at://([^/]+)/([^/]+)/(.+)$',
      ).firstMatch(uriString);
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

    // Return empty string for unrecognized URI schemes (e.g., file://)
    // to prevent invalid URLs from being passed to image loaders
    return '';
  }

  String get videoUrl {
    final mediaToCheck = displayMedia;
    switch (mediaToCheck) {
      case MediaViewVideo(:final playlist):
        return playlist.toString();
      case MediaViewBskyVideo(:final playlist):
        // For Bluesky videos, return the AT URI as-is for blob API handling
        return playlist.toString();
      case MediaViewBskyRecordWithMedia(:final media):
        // Handle nested media in record with media
        switch (media) {
          case MediaViewVideo(:final playlist):
            return playlist.toString();
          case MediaViewBskyVideo(:final playlist):
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
    final mediaToCheck = displayMedia;
    final List<String> urls;
    switch (mediaToCheck) {
      case MediaViewImage(:final image):
        urls = [image.fullsize.toString()];
      case MediaViewImages(:final images):
        urls = images.map((img) => img.fullsize.toString()).toList();
      case MediaViewBskyImages(:final images):
        urls = images
            .map(
              (img) => _resolveAtUriToHttpUrl(img.fullsize, isFullsize: true),
            )
            .toList();
      case MediaViewBskyRecordWithMedia(:final media):
        // Handle nested media in record with media
        switch (media) {
          case MediaViewImage(:final image):
            urls = [image.fullsize.toString()];
          case MediaViewImages(:final images):
            urls = images.map((img) => img.fullsize.toString()).toList();
          case MediaViewBskyImages(:final images):
            urls = images
                .map(
                  (img) =>
                      _resolveAtUriToHttpUrl(img.fullsize, isFullsize: true),
                )
                .toList();
          case _:
            urls = [];
        }
      case _:
        urls = [];
    }
    // Filter out invalid URLs (must be http/https)
    return urls
        .where((url) => url.startsWith('http://') || url.startsWith('https://'))
        .toList();
  }

  String get thumbnailUrl {
    final mediaToCheck = displayMedia;
    switch (mediaToCheck) {
      case MediaViewVideo(:final thumbnail):
        return thumbnail.toString();
      case MediaViewBskyVideo(:final thumbnail):
        return _resolveAtUriToHttpUrl(thumbnail);
      case MediaViewImage(:final image):
        return image.thumb.toString();
      case MediaViewImages(:final images):
        return images.first.thumb.toString();
      case MediaViewBskyImages(:final images):
        return _resolveAtUriToHttpUrl(images.first.thumb);
      case MediaViewBskyRecordWithMedia(:final media):
        // Handle nested media in record with media
        switch (media) {
          case MediaViewVideo(:final thumbnail):
            return thumbnail.toString();
          case MediaViewBskyVideo(:final thumbnail):
            return _resolveAtUriToHttpUrl(thumbnail);
          case MediaViewImage(:final image):
            return image.thumb.toString();
          case MediaViewImages(:final images):
            return images.first.thumb.toString();
          case MediaViewBskyImages(:final images):
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
sealed class MediaView with _$MediaView {
  const MediaView._();

  @FreezedUnionValue('so.sprk.media.video#view')
  @JsonSerializable(explicitToJson: true)
  const factory MediaView.video({
    required String cid,
    @AtUriConverter() required Uri playlist,
    @AtUriConverter() required Uri thumbnail,
    String? alt,
  }) = MediaViewVideo;

  @FreezedUnionValue('so.sprk.media.image#view')
  @JsonSerializable(explicitToJson: true)
  const factory MediaView.image({required ViewImage image}) = MediaViewImage;

  @FreezedUnionValue('so.sprk.media.images#view')
  @JsonSerializable(explicitToJson: true)
  const factory MediaView.images({required List<ViewImage> images}) =
      MediaViewImages;

  // Bluesky embed types
  @FreezedUnionValue('app.bsky.embed.video#view')
  @JsonSerializable(explicitToJson: true)
  const factory MediaView.bskyVideo({
    required String cid,
    @AtUriConverter() required Uri playlist,
    @AtUriConverter() required Uri thumbnail,
    String? alt,
  }) = MediaViewBskyVideo;

  @FreezedUnionValue('app.bsky.embed.images#view')
  @JsonSerializable(explicitToJson: true)
  const factory MediaView.bskyImages({required List<ViewImage> images}) =
      MediaViewBskyImages;

  @FreezedUnionValue('app.bsky.embed.record#view')
  @JsonSerializable(explicitToJson: true)
  const factory MediaView.bskyRecord({required EmbedViewRecord record}) =
      MediaViewBskyRecord;

  @FreezedUnionValue('app.bsky.embed.recordWithMedia#view')
  @JsonSerializable(explicitToJson: true)
  const factory MediaView.bskyRecordWithMedia({
    required EmbedViewRecord record,
    required MediaView media,
  }) = MediaViewBskyRecordWithMedia;

  @FreezedUnionValue('app.bsky.embed.external#view')
  @JsonSerializable(explicitToJson: true)
  const factory MediaView.bskyExternal({required EmbedViewExternal external}) =
      MediaViewBskyExternal;

  factory MediaView.fromJson(Map<String, dynamic> json) =>
      _$MediaViewFromJson(json);
}

@freezed
abstract class EmbedViewExternal with _$EmbedViewExternal {
  @JsonSerializable(explicitToJson: true)
  const factory EmbedViewExternal({
    required String uri,
    @Default('') String title,
    @Default('') String description,
    @UriConverter() Uri? thumb,
  }) = _EmbedViewExternal;
  const EmbedViewExternal._();

  factory EmbedViewExternal.fromJson(Map<String, dynamic> json) =>
      _$EmbedViewExternalFromJson(json);
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
    @Default([]) List<MediaView> embeds,
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

  factory EmbedViewRecord.fromJson(Map<String, dynamic> json) {
    final type = json[r'$type'] as String?;
    // Handle unsupported record embed types by returning notFound
    if (BskyFeedAdapter.isUnsupportedEmbedType(type)) {
      return EmbedViewRecord.notFound(
        uri: AtUri.parse(json['uri'] as String? ?? 'at://unknown'),
        notFound: true,
      );
    }
    // Route to appropriate subtype based on $type
    return switch (type) {
      'app.bsky.embed.record#viewRecord' => _$EmbedViewRecord_RecordFromJson(
        json,
      ),
      'app.bsky.embed.record#viewNotFound' =>
        _$EmbedViewRecord_NotFoundFromJson(json),
      'app.bsky.embed.record#viewBlocked' => _$EmbedViewRecord_BlockedFromJson(
        json,
      ),
      _ => EmbedViewRecord.notFound(
        uri: AtUri.parse(json['uri'] as String? ?? 'at://unknown'),
        notFound: true,
      ),
    };
  }

  Map<String, dynamic> toJson() => switch (this) {
    EmbedViewRecord_Record() => (this as EmbedViewRecord_Record).toJson(),
    EmbedViewRecord_NotFound() => (this as EmbedViewRecord_NotFound).toJson(),
    EmbedViewRecord_Blocked() => (this as EmbedViewRecord_Blocked).toJson(),
  };
}

@freezed
abstract class FeedSkeleton with _$FeedSkeleton {
  @JsonSerializable(explicitToJson: true)
  const factory FeedSkeleton({
    required List<SkeletonFeedPost> feed,
    String? cursor,
  }) = _FeedSkeleton;
  const FeedSkeleton._();

  factory FeedSkeleton.fromJson(Map<String, dynamic> json) =>
      _$FeedSkeletonFromJson(json);
}

@freezed
abstract class ImageUploadResult with _$ImageUploadResult {
  @JsonSerializable(explicitToJson: true)
  const factory ImageUploadResult({
    required String fullsize,
    required String alt,
    required Map<String, dynamic> image,
  }) = _ImageUploadResult;
  const ImageUploadResult._();

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResultFromJson(json);
}

@freezed
abstract class CaptionRef with _$CaptionRef {
  @JsonSerializable(explicitToJson: true)
  const factory CaptionRef({
    required String text,
    @Default([]) List<Facet> facets,
  }) = _CaptionRef;
  const CaptionRef._();

  factory CaptionRef.fromJson(Map<String, dynamic> json) =>
      _$CaptionRefFromJson(json);
}

/// Represents the index range for a facet in the text
@freezed
abstract class FacetIndex with _$FacetIndex {
  @JsonSerializable(explicitToJson: true)
  const factory FacetIndex({
    /// Start index (inclusive)
    required int byteStart,

    /// End index (exclusive)
    required int byteEnd,
  }) = _FacetIndex;
  const FacetIndex._();

  /// Create a FacetIndex from JSON
  factory FacetIndex.fromJson(Map<String, dynamic> json) =>
      _$FacetIndexFromJson(json);
}

/// Represents a feature of a facet (mention, link, hashtag, etc.)
@Freezed(unionKey: r'$type')
abstract class FacetFeature with _$FacetFeature {
  const FacetFeature._();

  // Spark facet feature types
  /// Mention feature for referencing a user
  @FreezedUnionValue('#mention')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.mention({required String did}) = MentionFeature;

  /// Link feature for URLs
  @FreezedUnionValue('#link')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.link({@AtUriConverter() required Uri uri}) =
      LinkFeature;

  /// Tag feature for hashtags
  @FreezedUnionValue('#tag')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.tag({required String tag}) = TagFeature;

  // Bluesky facet feature types
  /// Bluesky mention feature for referencing a user
  @FreezedUnionValue('app.bsky.richtext.facet#mention')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.bskyMention({required String did}) =
      BskyMentionFeature;

  /// Bluesky link feature for URLs
  @FreezedUnionValue('app.bsky.richtext.facet#link')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.bskyLink({@AtUriConverter() required AtUri uri}) =
      BskyLinkFeature;

  /// Bluesky tag feature for hashtags
  @FreezedUnionValue('app.bsky.richtext.facet#tag')
  @JsonSerializable(explicitToJson: true)
  const factory FacetFeature.bskyTag({required String tag}) = BskyTagFeature;

  /// Create a FacetFeature from JSON
  factory FacetFeature.fromJson(Map<String, dynamic> json) =>
      _$FacetFeatureFromJson(json);
}

/// Represents a richtext facet for text formatting, mentions, links, etc.
@freezed
abstract class Facet with _$Facet {
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
abstract class ViewImage with _$ViewImage {
  @JsonSerializable(explicitToJson: true)
  const factory ViewImage({
    @AtUriConverter() required Uri thumb,
    @AtUriConverter() required Uri fullsize,
    String? alt,
    // aspectRatio: {width: int, height: int}
  }) = _ViewImage;
  const ViewImage._();

  factory ViewImage.fromJson(Map<String, dynamic> json) =>
      _$ViewImageFromJson(json);
}

@Freezed(unionKey: r'$type')
sealed class ThreadPost with _$ThreadPost {
  const ThreadPost._();

  @FreezedUnionValue('so.sprk.feed.defs#postView')
  @JsonSerializable(explicitToJson: true)
  const factory ThreadPost.post({required PostView post}) = ThreadPostView;

  @FreezedUnionValue('so.sprk.feed.defs#replyView')
  @JsonSerializable(explicitToJson: true)
  const factory ThreadPost.reply({required ReplyView reply}) = ThreadReplyView;

  factory ThreadPost.fromJson(Map<String, dynamic> json) =>
      _$ThreadPostFromJson(json);

  // Common getters for both PostView and ReplyView
  AtUri get uri => switch (this) {
    ThreadPostView(:final post) => post.uri,
    ThreadReplyView(:final reply) => reply.uri,
  };

  String get cid => switch (this) {
    ThreadPostView(:final post) => post.cid,
    ThreadReplyView(:final reply) => reply.cid,
  };

  ViewerState? get viewer => switch (this) {
    ThreadPostView(:final post) => post.viewer,
    ThreadReplyView(:final reply) => ViewerState(
      like: reply.viewer?.like,
      threadMuted: reply.viewer?.threadMuted,
      replyDisabled: reply.viewer?.replyDisabled,
      embeddingDisabled: reply.viewer?.embeddingDisabled,
    ),
  };

  int? get likeCount => switch (this) {
    ThreadPostView(:final post) => post.likeCount,
    ThreadReplyView(:final reply) => reply.likeCount,
  };

  int? get replyCount => switch (this) {
    ThreadPostView(:final post) => post.replyCount,
    ThreadReplyView(:final reply) => reply.replyCount,
  };

  List<String> get imageUrls => switch (this) {
    ThreadPostView(:final post) => post.imageUrls,
    ThreadReplyView(:final reply) => switch (reply.hydratedMedia) {
      // Replies/comments only support a single image (EmbedViewMediaImage)
      MediaViewImage(:final image) => [image.fullsize.toString()],
      MediaViewImages(:final images) =>
        images.map((img) => img.fullsize.toString()).toList(),
      MediaViewBskyImages(:final images) =>
        images.map((img) => img.fullsize.toString()).toList(),
      _ => <String>[],
    },
  };

  bool get isSprk => switch (this) {
    ThreadPostView(:final post) => post.isSprk,
    ThreadReplyView(:final reply) => () {
      final rec = reply.record;
      if (rec is Map<String, dynamic>) {
        final type = rec[r'$type'] as String?;
        return type == 'so.sprk.feed.reply' || type == 'so.sprk.feed.post';
      }
      return false;
    }(),
  };

  ProfileViewBasic get author => switch (this) {
    ThreadPostView(:final post) => post.author,
    ThreadReplyView(:final reply) => reply.author,
  };

  MediaView? get media => switch (this) {
    ThreadPostView(:final post) => post.media,
    ThreadReplyView(:final reply) => reply.hydratedMedia,
  };

  String get displayText => switch (this) {
    ThreadPostView(:final post) => post.displayText,
    ThreadReplyView(:final reply) => reply.displayText,
  };

  DateTime get indexedAt => switch (this) {
    ThreadPostView(:final post) => post.indexedAt,
    ThreadReplyView(:final reply) => reply.indexedAt,
  };

  String get videoUrl => switch (this) {
    ThreadPostView(:final post) => post.videoUrl,
    ThreadReplyView() => '', // Replies cannot have videos
  };
}

@Freezed(unionKey: r'$type')
sealed class Thread with _$Thread {
  const Thread._();

  // NORMAL POST
  @FreezedUnionValue('so.sprk.feed.defs#threadViewPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.threadViewPost({
    required ThreadPost post,
    Thread? parent,
    List<Thread>? replies,
    ThreadContext? context,
  }) = ThreadViewPost;

  // NOT FOUND POST
  @FreezedUnionValue('so.sprk.feed.defs#notFoundPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.notFoundPost({
    @AtUriConverter() required AtUri uri,
    required bool notFound,
  }) = NotFoundPost;

  // BLOCKED POST
  @FreezedUnionValue('so.sprk.feed.defs#blockedPost')
  @JsonSerializable(explicitToJson: true)
  const factory Thread.blockedPost({
    @AtUriConverter() required AtUri uri,
    required bool blocked,
    required BlockedAuthor author,
  }) = BlockedPost;

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);

  /// Convert a Bluesky thread to Spark Thread format
  ///
  /// Delegates to [bskyFeedAdapter.convertBskyThreadToSparkThread] which
  /// handles all Bluesky-specific conversion logic.
  factory Thread.fromBsky({
    required UFeedGetPostThreadThread thread,
    required AtUri uri,
  }) {
    return bskyFeedAdapter.convertBskyThreadToSparkThread(
      thread: thread,
      uri: uri,
    );
  }

  factory Thread.fromSparkFlatList({
    required List<dynamic> threadItems,
    bool isCrosspostThread = false,
  }) {
    if (threadItems.isEmpty) {
      throw Exception('Thread items list is empty');
    }

    void ensureRecordType(
      Map<String, dynamic> postPayload,
      String postUnionType,
    ) {
      final record = postPayload['record'];
      if (record is! Map<String, dynamic>) return;

      final currentType = record[r'$type'] as String?;
      if (currentType != null && currentType.isNotEmpty) return;

      final inferredType = switch (postUnionType) {
        'so.sprk.feed.defs#postView' => 'so.sprk.feed.post',
        'so.sprk.feed.defs#replyView' =>
          (record.containsKey('text') ||
                  record.containsKey('facets') ||
                  record.containsKey('embed'))
              ? 'app.bsky.feed.post'
              : 'so.sprk.feed.reply',
        _ => null,
      };

      if (inferredType != null) {
        record[r'$type'] = inferredType;
      }
    }

    String? inferThreadPostViewType(Map<String, dynamic> postPayload) {
      final record = postPayload['record'];
      if (record is Map<String, dynamic>) {
        final recordType = record[r'$type'] as String?;
        if (recordType == 'so.sprk.feed.reply' ||
            recordType == 'app.bsky.feed.post') {
          return 'so.sprk.feed.defs#replyView';
        }
        if (recordType == 'so.sprk.feed.post') {
          return 'so.sprk.feed.defs#postView';
        }
      }

      final uri = postPayload['uri'] as String?;
      if (uri != null) {
        if (uri.contains('/so.sprk.feed.reply/')) {
          return 'so.sprk.feed.defs#replyView';
        }
        if (uri.contains('/so.sprk.feed.post/')) {
          return 'so.sprk.feed.defs#postView';
        }
      }

      return null;
    }

    // Parse all thread items with their indices
    final items = <({int index, int depth, String uri, Thread thread})>[];
    for (var i = 0; i < threadItems.length; i++) {
      try {
        final itemMap = threadItems[i] as Map<String, dynamic>;
        final depth = itemMap['depth'] as int;
        final uri = itemMap['uri'] as String;
        final value = itemMap['value'] as Map<String, dynamic>;

        final itemType = itemMap[r'$type'] as String?;
        final isCrosspostItem =
            itemType == 'so.sprk.feed.getCrosspostThread#threadItem';
        final allowCrosspostNormalization =
            isCrosspostThread || isCrosspostItem;

        var valueType = value[r'$type'] as String?;

        // Defensive fallback: some thread payloads can omit value.$type.
        // Preserve prior behavior for standard getPostThread responses.
        if (valueType == null) {
          if (value['post'] != null) {
            value[r'$type'] = 'so.sprk.feed.defs#threadViewPost';
          } else if (value['notFound'] == true) {
            value[r'$type'] = 'so.sprk.feed.defs#notFoundPost';
          } else if (value['blocked'] == true) {
            value[r'$type'] = 'so.sprk.feed.defs#blockedPost';
          }
          valueType = value[r'$type'] as String?;
        }

        // Crosspost endpoint can return bare post/reply values.
        if (allowCrosspostNormalization &&
            (valueType == null ||
                valueType == 'so.sprk.feed.defs#postView' ||
                valueType == 'so.sprk.feed.defs#replyView')) {
          final normalizedPostType = valueType == 'so.sprk.feed.defs#replyView'
              ? 'so.sprk.feed.defs#replyView'
              : 'so.sprk.feed.defs#postView';
          final raw = Map<String, dynamic>.from(value)..remove(r'$type');
          value
            ..clear()
            ..[r'$type'] = 'so.sprk.feed.defs#threadViewPost'
            ..['post'] = <String, dynamic>{
              r'$type': normalizedPostType,
              normalizedPostType == 'so.sprk.feed.defs#replyView'
                      ? 'reply'
                      : 'post':
                  raw,
            };
        }

        final normalizedValueType = value[r'$type'] as String?;
        final isAllowedValueType =
            normalizedValueType == 'so.sprk.feed.defs#threadViewPost' ||
            normalizedValueType == 'so.sprk.feed.defs#notFoundPost' ||
            normalizedValueType == 'so.sprk.feed.defs#blockedPost';
        if (!isAllowedValueType) {
          throw Exception(
            'Invalid thread item value type: $normalizedValueType',
          );
        }

        if (normalizedValueType == 'so.sprk.feed.defs#threadViewPost') {
          if (value['post'] is! Map<String, dynamic>) {
            throw Exception('Invalid threadViewPost: missing post map');
          }

          var postContainer = value['post'] as Map<String, dynamic>;
          var postContainerType = postContainer[r'$type'] as String?;
          var postPayload =
              (postContainer['post'] ?? postContainer['reply'])
                  as Map<String, dynamic>?;

          // Canonicalize standard thread payloads where post/reply union type
          // is present, but payload is not wrapped under post/reply key yet.
          if (postContainerType == 'so.sprk.feed.defs#postView' &&
              postContainer['post'] is! Map<String, dynamic>) {
            final rawPost = Map<String, dynamic>.from(postContainer)
              ..remove(r'$type');
            value['post'] = <String, dynamic>{
              r'$type': 'so.sprk.feed.defs#postView',
              'post': rawPost,
            };
            postPayload = rawPost;
          } else if (postContainerType == 'so.sprk.feed.defs#replyView' &&
              postContainer['reply'] is! Map<String, dynamic>) {
            final rawReply = Map<String, dynamic>.from(postContainer)
              ..remove(r'$type');
            value['post'] = <String, dynamic>{
              r'$type': 'so.sprk.feed.defs#replyView',
              'reply': rawReply,
            };
            postPayload = rawReply;
          }

          postContainer = value['post'] as Map<String, dynamic>;
          postContainerType = postContainer[r'$type'] as String?;
          postPayload =
              (postContainer['post'] ?? postContainer['reply'])
                  as Map<String, dynamic>?;

          final inferredFromPayload = postPayload != null
              ? inferThreadPostViewType(postPayload)
              : null;
          if (inferredFromPayload != null &&
              postContainerType != inferredFromPayload) {
            value['post'] = <String, dynamic>{
              r'$type': inferredFromPayload,
              inferredFromPayload == 'so.sprk.feed.defs#replyView'
                      ? 'reply'
                      : 'post':
                  postPayload,
            };
            postContainer = value['post'] as Map<String, dynamic>;
            postContainerType = postContainer[r'$type'] as String?;
            postPayload =
                (postContainer['post'] ?? postContainer['reply'])
                    as Map<String, dynamic>?;
          }

          final isValidWrappedPost =
              postContainerType == 'so.sprk.feed.defs#postView' &&
              postContainer['post'] is Map<String, dynamic>;
          final isValidWrappedReply =
              postContainerType == 'so.sprk.feed.defs#replyView' &&
              postContainer['reply'] is Map<String, dynamic>;

          // Crosspost-only normalization for legacy/raw post container shapes.
          if (!(isValidWrappedPost || isValidWrappedReply) &&
              allowCrosspostNormalization) {
            final rawPost = Map<String, dynamic>.from(postContainer)
              ..remove(r'$type');
            final inferredPostType =
                inferThreadPostViewType(rawPost) ??
                'so.sprk.feed.defs#postView';

            value['post'] = <String, dynamic>{
              r'$type': inferredPostType,
              inferredPostType == 'so.sprk.feed.defs#replyView'
                      ? 'reply'
                      : 'post':
                  rawPost,
            };
            postContainer = value['post'] as Map<String, dynamic>;
            postContainerType = postContainer[r'$type'] as String?;
            postPayload =
                (postContainer['post'] ?? postContainer['reply'])
                    as Map<String, dynamic>?;
          }

          final isValidAfterNormalization =
              (postContainerType == 'so.sprk.feed.defs#postView' &&
                  value['post'] is Map<String, dynamic> &&
                  (value['post'] as Map<String, dynamic>)['post']
                      is Map<String, dynamic>) ||
              (postContainerType == 'so.sprk.feed.defs#replyView' &&
                  value['post'] is Map<String, dynamic> &&
                  (value['post'] as Map<String, dynamic>)['reply']
                      is Map<String, dynamic>);

          if (!isValidAfterNormalization) {
            throw Exception(
              'Invalid threadViewPost.post union shape: '
              'type=$postContainerType',
            );
          }

          if (allowCrosspostNormalization &&
              postPayload != null &&
              postContainerType != null) {
            ensureRecordType(postPayload, postContainerType);
          }
        }

        // Handle threadContext field - ensure it has data or remove it
        if (value.containsKey('threadContext')) {
          final contextValue = value['threadContext'];
          if (contextValue == null || contextValue is! Map<String, dynamic>) {
            value.remove('threadContext');
          } else {
            // If threadContext only has $type and no actual data, remove it
            if (contextValue.length == 1 &&
                contextValue.containsKey(r'$type')) {
              value.remove('threadContext');
            }
          }
        }

        Thread thread;
        try {
          thread = Thread.fromJson(value);
        } catch (e) {
          // Try to identify which field is failing
          final postMap = value['post'] as Map<String, dynamic>?;
          final postPayload =
              (postMap?['post'] ?? postMap?['reply']) as Map<String, dynamic>?;
          final recordMap = postPayload?['record'] as Map<String, dynamic>?;
          throw Exception(
            'Failed to parse Thread.fromJson: $e\n'
            'Value keys: ${value.keys.join(", ")}\n'
            'Post keys: ${postMap?.keys.join(", ")}\n'
            'Post payload keys: ${postPayload?.keys.join(", ")}\n'
            'Record keys: ${recordMap?.keys.join(", ")}',
          );
        }
        items.add((index: i, depth: depth, uri: uri, thread: thread));
      } catch (e, stackTrace) {
        throw Exception(
          'Error parsing thread item at index $i: $e\n'
          'Item: ${threadItems[i]}\n'
          'StackTrace: $stackTrace',
        );
      }
    }

    // Find the anchor (depth 0)
    final anchorIndex = items.indexWhere((item) => item.depth == 0);
    if (anchorIndex == -1) {
      throw Exception('Anchor post not found in thread items');
    }

    // Build nested structure: find each item's direct children (next depth lvl)
    Thread buildWithReplies(int startIndex) {
      final currentItem = items[startIndex];
      final currentDepth = currentItem.depth;
      final replies = <Thread>[];

      // Find all direct children (depth = currentDepth + 1) until we hit same
      // or lower depth
      var i = startIndex + 1;
      while (i < items.length) {
        final item = items[i];

        if (item.depth <= currentDepth) {
          final isRepeatedAnchorBoundary =
              currentDepth == 0 &&
              item.depth == 0 &&
              item.uri == currentItem.uri;
          if (isRepeatedAnchorBoundary) {
            i++;
            continue;
          }

          // We've moved to a sibling or back up the tree
          break;
        }

        if (item.depth == currentDepth + 1) {
          // This is a direct child, recursively build it
          replies.add(buildWithReplies(i));
          // Skip past this subtree
          i++;
          while (i < items.length && items[i].depth > currentDepth + 1) {
            i++;
          }
        } else {
          i++;
        }
      }

      if (replies.isEmpty) {
        return currentItem.thread;
      }

      return currentItem.thread.map(
        threadViewPost: (threadPost) => Thread.threadViewPost(
          post: threadPost.post,
          parent: threadPost.parent,
          replies: replies,
          context: threadPost.context,
        ),
        notFoundPost: (notFound) => notFound,
        blockedPost: (blocked) => blocked,
      );
    }

    return buildWithReplies(anchorIndex);
  }
}

@freezed
abstract class ThreadContext with _$ThreadContext {
  @JsonSerializable(explicitToJson: true)
  const factory ThreadContext({@AtUriConverter() AtUri? rootAuthorLike}) =
      _ThreadContext;
  const ThreadContext._();

  factory ThreadContext.fromJson(Map<String, dynamic> json) =>
      _$ThreadContextFromJson(json);
}

@freezed
abstract class ReplyView with _$ReplyView {
  @JsonSerializable(explicitToJson: true)
  const factory ReplyView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileViewBasic author,
    required dynamic record,
    required DateTime indexedAt,
    MediaView? media,
    int? replyCount,
    int? likeCount,
    List<Label>? labels,
    ReplyViewerState? viewer,
  }) = _ReplyView;
  const ReplyView._();

  factory ReplyView.fromJson(Map<String, dynamic> json) =>
      _$ReplyViewFromJson(json);

  String get displayText {
    final rec = record;
    if (rec is Map<String, dynamic>) {
      final caption = rec['caption'];
      if (caption is Map<String, dynamic>) {
        return caption['text'] as String? ?? '';
      }
      return rec['text'] as String? ?? '';
    }
    return '';
  }

  List<Facet> get displayFacets {
    final rec = record;
    if (rec is Map<String, dynamic>) {
      final caption = rec['caption'];
      if (caption is Map<String, dynamic>) {
        final facets = caption['facets'] as List?;
        return facets
                ?.map((f) => Facet.fromJson(f as Map<String, dynamic>))
                .toList() ??
            [];
      }
      final facets = rec['facets'] as List?;
      return facets
              ?.map((f) => Facet.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [];
    }
    return [];
  }

  /// Hydrates media from the record into a view format
  /// Necessary because API doesn't always return media field at the post level
  MediaView? get hydratedMedia {
    // If media is already present, use it
    if (media != null) return media;

    // Otherwise, try to hydrate from record
    final rec = record;
    if (rec is! Map<String, dynamic>) return null;

    final mediaRecord = rec['media'];
    if (mediaRecord is! Map<String, dynamic>) return null;

    final type = mediaRecord[r'$type'] as String?;

    try {
      switch (type) {
        case 'so.sprk.media.image':
          // Single image - convert to view format
          final imageData = mediaRecord['image'] as Map<String, dynamic>?;
          if (imageData == null) return null;

          // Extract the blob ref (CID)
          final ref = imageData['ref'] as Map<String, dynamic>?;
          final cid = ref?[r'$link'] as String?;
          if (cid == null) return null;

          final alt = mediaRecord['alt'] as String? ?? '';
          final authorDid = author.did;

          // Construct URLs using the same pattern as the server
          const baseUrl = 'https://media.sprk.so/img';
          final thumbUrl = '$baseUrl/medium/$authorDid/$cid/webp';
          final fullsizeUrl = '$baseUrl/full/$authorDid/$cid/webp';

          return MediaView.image(
            image: ViewImage(
              thumb: Uri.parse(thumbUrl),
              fullsize: Uri.parse(fullsizeUrl),
              alt: alt,
            ),
          );

        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}

@freezed
abstract class StoryView with _$StoryView {
  @JsonSerializable(explicitToJson: true)
  const factory StoryView({
    required String cid,
    @AtUriConverter() required AtUri uri,
    required ProfileViewBasic author,
    @JsonKey(fromJson: _storyRecordFromJson, toJson: _storyRecordToJson)
    required StoryRecord record,
    required DateTime indexedAt,
    MediaView? media,
    // viewer eventually i think
  }) = _StoryView;
  const StoryView._();

  factory StoryView.fromJson(Map<String, dynamic> json) =>
      _$StoryViewFromJson(json);
}
