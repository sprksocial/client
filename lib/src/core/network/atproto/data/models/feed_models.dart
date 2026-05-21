import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_post_thread.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/adapters/bsky/feed_adapter.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart';
import 'package:spark/src/core/network/atproto/data/models/sound_models.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';

import 'package:sprk_poptart/so/sprk/actor/defs.dart'
    show $ProfileViewBasicCopyWith, ProfileViewBasic;
import 'package:sprk_poptart/so/sprk/feed/defs.dart' as sprk_feed_defs;
import 'package:sprk_poptart/so/sprk/feed/defs/generator_view.dart'
    show $GeneratorViewCopyWith;

import 'package:sprk_poptart/so/sprk/feed/get_feed/output.dart'
    as sprk_get_feed;
import 'package:sprk_poptart/so/sprk/feed/get_feed_skeleton/output.dart'
    as sprk_get_feed_skeleton;
import 'package:sprk_poptart/so/sprk/media/image/view.dart'
    as sprk_media_image_view;
import 'package:sprk_poptart/so/sprk/story/defs.dart' as sprk_story_defs;

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

typedef FeedViewPost = sprk_feed_defs.FeedViewPost;
typedef GeneratorViewerState = sprk_feed_defs.GeneratorViewerState;
typedef GeneratorView = sprk_feed_defs.GeneratorView;
typedef SkeletonFeedPost = sprk_feed_defs.SkeletonFeedPost;
typedef BlockedAuthor = sprk_feed_defs.BlockedAuthor;
typedef FeedView = sprk_get_feed.FeedGetFeedOutput;
typedef FeedSkeleton = sprk_get_feed_skeleton.FeedGetFeedSkeletonOutput;
typedef ReplyRef = sprk_feed_defs.ReplyRef;
typedef ReplyRefPostReference = sprk_feed_defs.UReplyRefParent;
typedef PostView = sprk_feed_defs.PostView;
typedef ViewerState = sprk_feed_defs.ViewerState;
typedef KnownInteraction = sprk_feed_defs.UViewerStateKnownInteractions;
typedef KnownRepost = sprk_feed_defs.KnownRepost;
typedef KnownLike = sprk_feed_defs.KnownLike;
typedef KnownReply = sprk_feed_defs.KnownReply;
typedef ReplyViewerState = sprk_feed_defs.ReplyViewerState;
typedef ReplyView = sprk_feed_defs.ReplyView;
typedef StoryView = sprk_story_defs.StoryView;
typedef ThreadContext = sprk_feed_defs.ThreadContext;

/// The feeds that are actually used in the app
@freezed
abstract class Feed with _$Feed {
  factory Feed({
    required String type,
    required SavedFeed config,
    GeneratorView? view,
  }) = _Feed;
  const Feed._();

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
}

@freezed
sealed class HardcodedFeedExtraInfo with _$HardcodedFeedExtraInfo {
  const HardcodedFeedExtraInfo._();

  const factory HardcodedFeedExtraInfo.shared({
    required ProfileViewBasic from,
    String? message,
  }) = HardcodedFeedExtraInfoShared;

  factory HardcodedFeedExtraInfo.fromJson(Map<String, dynamic> json) =>
      _$HardcodedFeedExtraInfoFromJson(json);
}

FeedViewPost feedViewPostFromPost(PostView post, {String? feedContext}) {
  return FeedViewPost(
    post: sprk_feed_defs.PostView.fromJson(post.toJson()),
    feedContext: feedContext,
  );
}

extension FeedViewPostConvenience on FeedViewPost {
  PostView get localPost => post;
  PostView? get asPost => localPost;
  ReplyView? get asReply => null;
  ProfileViewBasic get author => post.author;
  AtUri get uri => post.uri;
  String get cid => post.cid;
  sprk_feed_defs.UPostViewMedia? get media => post.media;
  ViewerState? get viewerState => post.viewer;
  ReplyViewerState? get replyViewerState => null;
  String get displayText => localPost.displayText;
  List<Facet> get displayFacets => localPost.displayFacets;
}

extension KnownInteractionConvenience on KnownInteraction {
  KnownRepost? get knownRepost => switch (this) {
    sprk_feed_defs.UViewerStateKnownInteractionsKnownRepost(:final data) =>
      data,
    _ => null,
  };

  KnownLike? get knownLike => switch (this) {
    sprk_feed_defs.UViewerStateKnownInteractionsKnownLike(:final data) => data,
    _ => null,
  };

  KnownReply? get knownReply => switch (this) {
    sprk_feed_defs.UViewerStateKnownInteractionsKnownReply(:final data) => data,
    _ => null,
  };
}

extension ReplyViewConvenience on ReplyView {
  String get displayText {
    final caption = record['caption'];
    if (caption is Map<String, dynamic>) {
      return caption['text'] as String? ?? '';
    }
    return record['text'] as String? ?? '';
  }

  List<Facet> get displayFacets {
    final caption = record['caption'];
    final facets = caption is Map<String, dynamic>
        ? caption['facets'] as List?
        : record['facets'] as List?;
    return facets
            ?.whereType<Map<String, dynamic>>()
            .map(Facet.fromJson)
            .toList() ??
        const [];
  }

  List<String> get imageUrls {
    final mediaToCheck = media ?? _hydratedMediaFromRecord;
    switch (mediaToCheck) {
      case sprk_feed_defs.UReplyViewMediaMediaImageView(:final data):
        return [data.fullsize]
            .where(
              (url) => url.startsWith('http://') || url.startsWith('https://'),
            )
            .toList();
      case sprk_feed_defs.UReplyViewMediaUnknown(:final data):
        if (data[r'$type'] == 'so.sprk.media.image#view') {
          final image = data['image'];
          final fullsize = image is Map<String, dynamic>
              ? image['fullsize'] as String? ?? ''
              : data['fullsize'] as String? ?? '';
          return [fullsize]
              .where(
                (url) =>
                    url.startsWith('http://') || url.startsWith('https://'),
              )
              .toList();
        }
        return const [];
      case _:
        return const [];
    }
  }

  sprk_feed_defs.UReplyViewMedia? get hydratedMedia =>
      media ?? _hydratedMediaFromRecord;

  sprk_feed_defs.UReplyViewMedia? get _hydratedMediaFromRecord {
    final mediaRecord = record['media'];
    if (mediaRecord is! Map<String, dynamic>) return null;
    final type = mediaRecord[r'$type'] as String?;
    if (type != 'so.sprk.media.image') return null;

    final imageData = mediaRecord['image'] as Map<String, dynamic>?;
    final ref = imageData?['ref'] as Map<String, dynamic>?;
    final cid = ref?[r'$link'] as String?;
    if (cid == null) return null;

    final alt = mediaRecord['alt'] as String? ?? '';
    final authorDid = author.did;
    const baseUrl = 'https://media.sprk.so/img';
    return sprk_feed_defs.UReplyViewMedia.mediaImageView(
      data: sprk_media_image_view.MediaImageView(
        thumb: '$baseUrl/medium/$authorDid/$cid/webp',
        fullsize: '$baseUrl/full/$authorDid/$cid/webp',
        alt: alt,
      ),
    );
  }
}

extension StoryViewConvenience on StoryView {
  StoryRecord? get localRecord {
    try {
      return StoryRecord.fromJson(record);
    } catch (_) {
      return null;
    }
  }

  List<StoryEmbedView>? get localEmbeds {
    final storyEmbeds = embeds;
    if (storyEmbeds == null || storyEmbeds.isEmpty) return const [];
    return storyEmbeds
        .map((embed) {
          try {
            return StoryEmbedView.fromJson(embed.toJson());
          } catch (_) {
            return null;
          }
        })
        .whereType<StoryEmbedView>()
        .toList();
  }

  bool get isVideoStory => videoUrl.isNotEmpty;

  String get videoUrl {
    final mediaToCheck = media;
    switch (mediaToCheck) {
      case sprk_story_defs.UStoryViewMediaMediaVideoView(:final data):
        return data.playlist;
      case sprk_story_defs.UStoryViewMediaUnknown(:final data):
        if (data[r'$type'] == 'so.sprk.media.video#view') {
          return data['playlist'] as String? ?? '';
        }
        return '';
      case _:
        return '';
    }
  }

  String get imageUrl {
    final mediaToCheck = media;
    switch (mediaToCheck) {
      case sprk_story_defs.UStoryViewMediaMediaImageView(:final data):
        return data.fullsize;
      case sprk_story_defs.UStoryViewMediaUnknown(:final data):
        if (data[r'$type'] == 'so.sprk.media.image#view') {
          final image = data['image'];
          return image is Map<String, dynamic>
              ? image['fullsize'] as String? ?? ''
              : data['fullsize'] as String? ?? '';
        }
        return '';
      case _:
        return author.avatar?.toString() ?? '';
    }
  }

  String get thumbnailUrl {
    final mediaToCheck = media;
    switch (mediaToCheck) {
      case sprk_story_defs.UStoryViewMediaMediaVideoView(:final data):
        return data.thumbnail ?? author.avatar?.toString() ?? '';
      case sprk_story_defs.UStoryViewMediaMediaImageView(:final data):
        return data.thumb;
      case sprk_story_defs.UStoryViewMediaUnknown(:final data):
        if (data[r'$type'] == 'so.sprk.media.image#view') {
          final image = data['image'];
          return image is Map<String, dynamic>
              ? image['thumb'] as String? ?? ''
              : data['thumb'] as String? ?? '';
        }
        if (data[r'$type'] == 'so.sprk.media.video#view') {
          return data['thumbnail'] as String? ??
              author.avatar?.toString() ??
              '';
        }
        return author.avatar?.toString() ?? '';
      case _:
        return author.avatar?.toString() ?? '';
    }
  }
}

extension PostViewConvenience on PostView {
  bool get isSprk => RegExp(
    r'^at://[^/]+/so\.sprk\.feed\.post/[^/]+$',
  ).hasMatch(uri.toString());

  sprk_feed_defs.UPostViewMedia? get displayMedia => media;

  PostRecord? get localRecord {
    try {
      final parsed = Record.fromJson(record);
      return parsed is PostRecord ? parsed : null;
    } catch (_) {
      return null;
    }
  }

  CaptionRef get caption {
    final local = localRecord;
    if (local != null) return local.caption;

    final captionJson = record['caption'];
    if (captionJson is Map<String, dynamic>) {
      return CaptionRef.fromJson(captionJson);
    }

    final text = record['text'] as String? ?? '';
    final facets = record['facets'];
    return CaptionRef(
      text: text,
      facets: facets is List
          ? facets
                .whereType<Map<String, dynamic>>()
                .map(Facet.fromJson)
                .toList()
          : const [],
    );
  }

  String get displayText => caption.text;

  List<Facet> get displayFacets => caption.facets;

  List<SelfLabel>? get selfLabels => localRecord?.selfLabels;

  List<String> get hashtags => localRecord?.hashtags ?? const [];

  List<RepoStrongRef>? get crossposts => localRecord?.crossposts;

  AudioView? get localSound {
    final postSound = sound;
    if (postSound == null) return null;
    return AudioView.fromJson(postSound.toJson());
  }

  /// Returns true if post has a video or image embed (content we want to show)
  bool get hasSupportedMedia {
    final mediaToCheck = displayMedia;
    if (mediaToCheck == null) return false;
    return true;
  }

  String get videoUrl {
    final mediaToCheck = displayMedia;
    switch (mediaToCheck) {
      case sprk_feed_defs.UPostViewMediaMediaVideoView(:final data):
        return data.playlist;
      case sprk_feed_defs.UPostViewMediaUnknown(:final data):
        if (data[r'$type'] == 'so.sprk.media.video#view') {
          return data['playlist'] as String? ?? '';
        }
        return '';
      case _:
        return '';
    }
  }

  List<String> get imageUrls {
    final mediaToCheck = displayMedia;
    final List<String> urls;
    switch (mediaToCheck) {
      case sprk_feed_defs.UPostViewMediaMediaImagesView(:final data):
        urls = data.images.map((img) => img.fullsize).toList();
      case sprk_feed_defs.UPostViewMediaUnknown(:final data):
        if (data[r'$type'] == 'so.sprk.media.image#view') {
          final image = data['image'];
          urls = image is Map<String, dynamic>
              ? [image['fullsize'] as String? ?? '']
              : const [];
        } else if (data[r'$type'] == 'so.sprk.media.images#view') {
          final images = data['images'];
          urls = images is List
              ? images
                    .whereType<Map<String, dynamic>>()
                    .map((img) => img['fullsize'] as String? ?? '')
                    .toList()
              : const [];
        } else {
          urls = const [];
        }
      case _:
        urls = const [];
    }
    // Filter out invalid URLs (must be http/https)
    return urls
        .where((url) => url.startsWith('http://') || url.startsWith('https://'))
        .toList();
  }

  String get thumbnailUrl {
    final mediaToCheck = displayMedia;
    switch (mediaToCheck) {
      case sprk_feed_defs.UPostViewMediaMediaVideoView(:final data):
        return data.thumbnail ?? '';
      case sprk_feed_defs.UPostViewMediaMediaImagesView(:final data):
        return data.images.isEmpty ? '' : data.images.first.thumb;
      case sprk_feed_defs.UPostViewMediaUnknown(:final data):
        if (data[r'$type'] == 'so.sprk.media.image#view') {
          final image = data['image'];
          return image is Map<String, dynamic>
              ? image['thumb'] as String? ?? ''
              : '';
        }
        if (data[r'$type'] == 'so.sprk.media.images#view') {
          final images = data['images'];
          final firstImage = images is List && images.isNotEmpty
              ? images.first
              : null;
          return firstImage is Map<String, dynamic>
              ? firstImage['thumb'] as String? ?? ''
              : '';
        }
        return '';
      case _:
        return '';
    }
  }
}

@freezed
abstract class ImageUploadResult with _$ImageUploadResult {
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
  const factory FacetFeature.mention({required String did}) = MentionFeature;

  /// Link feature for URLs
  @FreezedUnionValue('#link')
  const factory FacetFeature.link({@AtUriConverter() required Uri uri}) =
      LinkFeature;

  /// Tag feature for hashtags
  @FreezedUnionValue('#tag')
  const factory FacetFeature.tag({required String tag}) = TagFeature;

  // Bluesky facet feature types
  /// Bluesky mention feature for referencing a user
  @FreezedUnionValue('app.bsky.richtext.facet#mention')
  const factory FacetFeature.bskyMention({required String did}) =
      BskyMentionFeature;

  /// Bluesky link feature for URLs
  @FreezedUnionValue('app.bsky.richtext.facet#link')
  const factory FacetFeature.bskyLink({@AtUriConverter() required AtUri uri}) =
      BskyLinkFeature;

  /// Bluesky tag feature for hashtags
  @FreezedUnionValue('app.bsky.richtext.facet#tag')
  const factory FacetFeature.bskyTag({required String tag}) = BskyTagFeature;

  /// Create a FacetFeature from JSON
  factory FacetFeature.fromJson(Map<String, dynamic> json) =>
      _$FacetFeatureFromJson(json);
}

/// Represents a richtext facet for text formatting, mentions, links, etc.
@freezed
abstract class Facet with _$Facet {
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

@Freezed(unionKey: r'$type', copyWith: false)
sealed class ThreadPost with _$ThreadPost {
  const ThreadPost._();

  @FreezedUnionValue('so.sprk.feed.defs#postView')
  const factory ThreadPost.post({required PostView post}) = ThreadPostView;

  @FreezedUnionValue('so.sprk.feed.defs#replyView')
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
    ThreadReplyView(:final reply) => reply.imageUrls,
  };

  bool get isSprk => switch (this) {
    ThreadPostView(:final post) => post.isSprk,
    ThreadReplyView(:final reply) => () {
      final rec = reply.record;
      final type = rec[r'$type'] as String?;
      return type == 'so.sprk.feed.reply' || type == 'so.sprk.feed.post';
    }(),
  };

  ProfileViewBasic get author => switch (this) {
    ThreadPostView(:final post) => post.author,
    ThreadReplyView(:final reply) => reply.author,
  };

  Object? get media => switch (this) {
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

@Freezed(unionKey: r'$type', copyWith: false)
sealed class Thread with _$Thread {
  const Thread._();

  // NORMAL POST
  @FreezedUnionValue('so.sprk.feed.defs#threadViewPost')
  const factory Thread.threadViewPost({
    required ThreadPost post,
    Thread? parent,
    List<Thread>? replies,
    ThreadContext? context,
  }) = ThreadViewPost;

  // NOT FOUND POST
  @FreezedUnionValue('so.sprk.feed.defs#notFoundPost')
  const factory Thread.notFoundPost({
    @AtUriConverter() required AtUri uri,
    required bool notFound,
  }) = NotFoundPost;

  // BLOCKED POST
  @FreezedUnionValue('so.sprk.feed.defs#blockedPost')
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
