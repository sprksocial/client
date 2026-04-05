import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_embed_images.dart';
import 'package:bluesky/app_bsky_feed_defs.dart' as bsky_defs;
import 'package:bluesky/app_bsky_feed_getpostthread.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/app_bsky_richtext_facet.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart'
    hide ReplyRef;
import 'package:spark/src/core/utils/json_utils.dart';

/// Adapter for Bluesky feed models <-> Spark feed models
///
/// Handles bidirectional conversion between Bluesky feed data structures
/// and Spark feed data structures. This includes posts, replies, threads,
/// and all associated metadata.
class BskyFeedAdapter {
  const BskyFeedAdapter();

  // ===========================================================================
  // Bluesky Embed Filtering & Sanitization
  // ===========================================================================

  /// List of unsupported embed types that should be filtered out
  static const unsupportedEmbedTypes = [
    'app.bsky.graph.defs#starterPackViewBasic',
    'app.bsky.graph.defs#listViewBasic',
    'app.bsky.feed.defs#generatorView',
    'app.bsky.labeler.defs#labelerView',
  ];

  /// Check if an embed type is unsupported
  static bool isUnsupportedEmbedType(String? type) {
    return type != null && unsupportedEmbedTypes.contains(type);
  }

  /// Check if a post JSON has an EmbedViewRecord embed (quote post)
  /// These can cause deserialization issues and should be filtered from replies
  bool hasEmbedViewRecord(Map<String, dynamic> postJson) {
    bool checkForRecordEmbed(Map<String, dynamic> embedData) {
      final embedType = embedData[r'$type'] as String?;

      // Check if this is a record embed
      if (embedType == 'app.bsky.embed.record#view' &&
          embedData['record'] != null) {
        return true;
      }

      // Check if this is a recordWithMedia embed
      if (embedType == 'app.bsky.embed.recordWithMedia#view' &&
          embedData['record'] != null) {
        return true;
      }

      // Recursively check nested structures
      for (final value in embedData.values) {
        if (value is Map<String, dynamic>) {
          if (checkForRecordEmbed(value)) return true;
        } else if (value is List) {
          for (final item in value) {
            if (item is Map<String, dynamic> && checkForRecordEmbed(item)) {
              return true;
            }
          }
        }
      }

      return false;
    }

    // Check post-level embed
    if (postJson['embed'] != null &&
        postJson['embed'] is Map<String, dynamic>) {
      if (checkForRecordEmbed(postJson['embed'] as Map<String, dynamic>)) {
        return true;
      }
    }

    // Check record-level embed
    if (postJson['record'] != null &&
        postJson['record'] is Map<String, dynamic>) {
      final record = postJson['record'] as Map<String, dynamic>;
      if (record['embed'] != null && record['embed'] is Map<String, dynamic>) {
        if (checkForRecordEmbed(record['embed'] as Map<String, dynamic>)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check if a reply should be filtered out (has problematic embeds)
  bool shouldFilterReply(bsky_defs.PostView post) {
    final replyJson = post.toJson();
    return hasEmbedViewRecord(replyJson);
  }

  /// Sanitize a Bluesky post JSON by removing/fixing problematic embeds
  /// Returns the sanitized JSON (modifies in place)
  void sanitizeBskyPostViewJson(Map<String, dynamic> postViewJson) {
    if (postViewJson['embed'] == null) return;

    final embedJson = postViewJson['embed'] as Map<String, dynamic>;

    // Check for external embed without required cid
    if (embedJson[r'$type'] == 'app.bsky.embed.external#view') {
      if (embedJson['cid'] == null) {
        postViewJson.remove('embed');
        return;
      }
    }

    // If it's a record embed, check the record data
    if (embedJson[r'$type'] == 'app.bsky.embed.record#view' &&
        embedJson['record'] != null) {
      final recordJson = embedJson['record'] as Map<String, dynamic>;

      // Filter out unsupported record embed types
      final recordType = recordJson[r'$type'] as String?;
      if (isUnsupportedEmbedType(recordType)) {
        postViewJson.remove('embed');
        return;
      }

      // Check required fields for EmbedViewRecord#viewRecord
      if (recordJson[r'$type'] == 'app.bsky.embed.record#viewRecord') {
        if (recordJson['cid'] == null ||
            recordJson['uri'] == null ||
            recordJson['author'] == null ||
            recordJson['value'] == null ||
            recordJson['indexedAt'] == null) {
          postViewJson.remove('embed');
          return;
        }

        // Check nested embeds array in the record value
        if (recordJson['embeds'] != null && recordJson['embeds'] is List) {
          final embedsList = recordJson['embeds'] as List;
          for (final nestedEmbed in embedsList) {
            if (nestedEmbed is Map<String, dynamic>) {
              // Check external embeds in the nested embeds
              if (nestedEmbed[r'$type'] == 'app.bsky.embed.external#view' &&
                  nestedEmbed['cid'] == null) {
                postViewJson.remove('embed');
                return;
              }
            }
          }
        }
      }
    }

    // Enhanced check for recordWithMedia embeds
    if (embedJson[r'$type'] == 'app.bsky.embed.recordWithMedia#view') {
      if (embedJson['record'] != null) {
        final recordEmbedJson = embedJson['record'] as Map<String, dynamic>;
        if (recordEmbedJson['record'] != null) {
          final recordJson = recordEmbedJson['record'] as Map<String, dynamic>;

          // Filter out unsupported record embed types
          final recordType = recordJson[r'$type'] as String?;
          if (isUnsupportedEmbedType(recordType)) {
            postViewJson.remove('embed');
            return;
          }

          // Check if it's a viewRecord and has required fields
          if (recordJson[r'$type'] == 'app.bsky.embed.record#viewRecord') {
            if (recordJson['uri'] == null ||
                recordJson['cid'] == null ||
                recordJson['author'] == null ||
                recordJson['value'] == null ||
                recordJson['indexedAt'] == null) {
              postViewJson.remove('embed');
              return;
            }
          }
        }
      }
    }

    // Recursive validation for any remaining embed structures
    if (postViewJson['embed'] != null) {
      _validateRecordViewInEmbed(
        postViewJson['embed'] as Map<String, dynamic>,
        postViewJson,
      );
    }
  }

  /// Recursively validate record views in embed structures
  void _validateRecordViewInEmbed(
    Map<String, dynamic> embedData,
    Map<String, dynamic> postViewJson,
  ) {
    final embedType = embedData[r'$type'] as String?;

    // Filter out unsupported record embed types
    if (isUnsupportedEmbedType(embedType)) {
      postViewJson.remove('embed');
      return;
    }

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
        _validateRecordViewInEmbed(value, postViewJson);
      } else if (value is List) {
        for (var i = 0; i < value.length; i++) {
          if (value[i] is Map<String, dynamic>) {
            _validateRecordViewInEmbed(
              value[i] as Map<String, dynamic>,
              postViewJson,
            );
          }
        }
      }
    });
  }

  // ===========================================================================
  // Bluesky -> Spark Conversions
  // ===========================================================================
  /// Transforms Bluesky images (multiple) to Spark single image format
  /// For comments/replies, only the first image should be used
  void _transformBskyImagesToSingleSparkImage(Map<String, dynamic> mediaJson) {
    if (mediaJson[r'$type'] == 'app.bsky.embed.images#view') {
      final images = mediaJson['images'] as List?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images.first as Map<String, dynamic>;
        // Transform to Spark single image format
        mediaJson[r'$type'] = 'so.sprk.media.image#view';
        mediaJson['image'] = firstImage;
        mediaJson['alt'] = firstImage['alt'] ?? '';
        mediaJson.remove('images');
      }
    }
  }

  /// Convert Bluesky PostView JSON to Spark PostView JSON format
  void convertPostViewJson(
    Map<String, dynamic> post, {
    bool isNestedReply = false,
  }) {
    if (post.containsKey('embed')) {
      post['media'] = post['embed'];
      post.remove('embed');
    }

    // Check if this post is actually a reply/comment by examining the record
    var isReply = false;

    if (post.containsKey('record') && post['record'] != null) {
      final record = post['record'] as Map<String, dynamic>;
      final recordType = record[r'$type'] as String?;

      if (recordType == 'app.bsky.feed.post') {
        final text = record['text'] as String? ?? '';
        final facets = record['facets'] as List<dynamic>? ?? [];

        record['caption'] = {'text': text, 'facets': facets};

        record[r'$type'] = 'so.sprk.feed.post';

        if (record.containsKey('embed')) {
          record['media'] = record['embed'];
          record.remove('embed');
        }

        record
          ..remove('text')
          ..remove('facets');

        // Check if this is a reply/comment
        isReply = record.containsKey('reply') && record['reply'] != null;

        if (isReply) {
          final reply = record['reply'] as Map<String, dynamic>;
          convertReplyRefJson(reply);

          // Transform media for replies - only single image allowed
          if (record.containsKey('media') && record['media'] != null) {
            final mediaJson = record['media'] as Map<String, dynamic>;
            _transformBskyImagesToSingleSparkImage(mediaJson);
          }
        }
      }
    }

    // Also transform post-level media if this is a reply
    if (isReply && post.containsKey('media') && post['media'] != null) {
      final mediaJson = post['media'] as Map<String, dynamic>;
      _transformBskyImagesToSingleSparkImage(mediaJson);
    }

    if (!isNestedReply && post.containsKey('reply') && post['reply'] != null) {
      final replyRef = post['reply'] as Map<String, dynamic>;
      convertReplyRefJson(replyRef);
    }
  }

  /// Convert Bluesky ReplyRef JSON to Spark ReplyRef JSON format
  void convertReplyRefJson(Map<String, dynamic> replyRef) {
    if (replyRef.containsKey('root') && replyRef['root'] != null) {
      final root = replyRef['root'] as Map<String, dynamic>;
      final rootType = root[r'$type'] as String?;

      if (rootType == 'com.atproto.repo.strongRef') {
        // Leave as is
      } else if (rootType == 'app.bsky.feed.defs#postView') {
        final postViewData = deepCopyJson(root)..remove(r'$type');
        convertPostViewJson(postViewData, isNestedReply: true);
        root
          ..clear()
          ..addAll({r'$type': rootType, 'post': postViewData});
      } else if (rootType == 'app.bsky.feed.defs#notFoundPost' ||
          rootType == 'app.bsky.feed.defs#blockedPost') {
        // Already in correct format
      } else if (root.containsKey('post')) {
        final rootPost = root['post'];
        if (rootPost is Map<String, dynamic>) {
          convertPostViewJson(rootPost);
        }
      }
    }

    if (replyRef.containsKey('parent') && replyRef['parent'] != null) {
      final parent = replyRef['parent'] as Map<String, dynamic>;
      final parentType = parent[r'$type'] as String?;

      if (parentType == 'com.atproto.repo.strongRef') {
        // Leave as is
      } else if (parentType == 'app.bsky.feed.defs#postView') {
        final postViewData = deepCopyJson(parent)..remove(r'$type');
        convertPostViewJson(postViewData, isNestedReply: true);
        parent
          ..clear()
          ..addAll({r'$type': parentType, 'post': postViewData});
      } else if (parentType == 'app.bsky.feed.defs#notFoundPost' ||
          parentType == 'app.bsky.feed.defs#blockedPost') {
        // Already in correct format
      } else if (parent.containsKey('post')) {
        final parentPost = parent['post'];
        if (parentPost is Map<String, dynamic>) {
          convertPostViewJson(parentPost);
        }
      }
    }
  }

  /// Convert Bluesky FeedViewPost JSON to Spark FeedViewPost JSON format
  void convertFeedViewPostJson(Map<String, dynamic> postData) {
    if (postData.containsKey('post') && postData['post'] != null) {
      final post = postData['post'] as Map<String, dynamic>;
      convertPostViewJson(post);

      if (postData.containsKey('reply') && postData['reply'] != null) {
        final replyContext = postData['reply'] as Map<String, dynamic>;
        convertReplyRefJson(replyContext);
      }

      postData[r'$type'] = 'so.sprk.feed.defs#feedPostView';
    } else if (postData.containsKey('reply') && postData['reply'] != null) {
      final replyContext = postData['reply'] as Map<String, dynamic>;
      convertReplyRefJson(replyContext);
      postData[r'$type'] = 'so.sprk.feed.defs#feedReplyView';
    }
  }

  // ===========================================================================
  // Spark -> Bluesky Conversions
  // ===========================================================================

  /// Convert Spark images to Bluesky images
  List<EmbedImagesImage> convertImages(List<Image> sparkImages) {
    return sparkImages.map((sparkImage) {
      return EmbedImagesImage(
        alt: sparkImage.alt ?? '',
        image: sparkImage.image,
      );
    }).toList();
  }

  /// Convert Spark Media JSON to Bluesky embed format
  /// Returns null if media is null or not supported for Bluesky
  UFeedPostEmbed? convertJsonToBskyEmbed(Map<String, dynamic> mediaJson) {
    final media = Media.fromJson(mediaJson);

    switch (media) {
      case MediaImage(:final image, :final alt):
        // Convert single Spark image to Bluesky embed images
        final bskyImage = EmbedImagesImage(alt: alt ?? '', image: image);
        return UFeedPostEmbed.embedImages(
          data: EmbedImages(images: [bskyImage]),
        );

      case MediaImages(:final images):
        // Convert multiple Spark images to Bluesky embed images
        final bskyImages = convertImages(images);
        return UFeedPostEmbed.embedImages(
          data: EmbedImages(images: bskyImages),
        );

      case MediaBskyImages(:final images):
        // Already in Bluesky format, convert to embed
        final bskyImages = convertImages(images);
        return UFeedPostEmbed.embedImages(
          data: EmbedImages(images: bskyImages),
        );

      case MediaVideo():
      case MediaBskyVideo():
      case MediaBskyRecord():
      case MediaBskyRecordWithMedia():
      case MediaBskyExternal():
        // Videos and other embed types are not supported for comments/replies
        return null;
    }
  }

  /// Create a Bluesky post record
  FeedPostRecord createPostRecord({
    required String text,
    required DateTime createdAt,
    List<EmbedImagesImage>? images,
    List<RichtextFacet>? facets,
  }) {
    return FeedPostRecord(
      text: text,
      createdAt: createdAt,
      embed: images != null && images.isNotEmpty
          ? UFeedPostEmbed.embedImages(data: EmbedImages(images: images))
          : null,
      facets: facets,
    );
  }

  /// Create Bluesky comment/reply record
  FeedPostRecord createCommentRecord({
    required String text,
    required DateTime createdAt,
    required RecordReplyRef reply,
    UFeedPostEmbed? embed,
    List<RichtextFacet>? facets,
  }) {
    return FeedPostRecord(
      text: text,
      createdAt: createdAt,
      reply: ReplyRef(root: reply.root, parent: reply.parent),
      embed: embed,
      facets: facets,
    );
  }

  /// Create a link facet for Bluesky posts
  RichtextFacet createLinkFacet({
    required String linkUrl,
    required int byteStart,
  }) {
    return RichtextFacet(
      index: RichtextFacetByteSlice(
        byteStart: byteStart,
        byteEnd: byteStart + linkUrl.length,
      ),
      features: [
        URichtextFacetFeatures.richtextFacetLink(
          data: RichtextFacetLink(uri: linkUrl),
        ),
      ],
    );
  }

  /// Create a mention facet for Bluesky posts
  RichtextFacet createMentionFacet({
    required String did,
    required int byteStart,
    required int byteEnd,
  }) {
    return RichtextFacet(
      index: RichtextFacetByteSlice(byteStart: byteStart, byteEnd: byteEnd),
      features: [
        URichtextFacetFeatures.richtextFacetMention(
          data: RichtextFacetMention(did: did),
        ),
      ],
    );
  }

  // ===========================================================================
  // Bluesky Thread Conversion
  // ===========================================================================

  /// Convert a Bluesky parent thread to Spark Thread
  Thread? _convertParentToThread(
    bsky_defs.UThreadViewPostParent parent,
    AtUri uri,
  ) {
    switch (parent) {
      case bsky_defs.UThreadViewPostParentThreadViewPost(:final data):
        return convertBskyThreadToSparkThread(
          thread: UFeedGetPostThreadThread.threadViewPost(data: data),
          uri: uri,
        );
      case bsky_defs.UThreadViewPostParentNotFoundPost(:final data):
        return Thread.notFoundPost(uri: data.uri, notFound: true);
      case bsky_defs.UThreadViewPostParentBlockedPost(:final data):
        return Thread.blockedPost(
          uri: data.uri,
          blocked: true,
          author: BlockedAuthor.fromJson(data.author.toJson()),
        );
      case bsky_defs.UThreadViewPostParentUnknown():
        return null;
    }
  }

  /// Convert Bluesky thread to Spark thread
  ///
  /// This is the main entry point for converting Bluesky thread responses
  /// to Spark Thread models. Handles all thread types: normal posts,
  /// not found posts, and blocked posts.
  Thread convertBskyThreadToSparkThread({
    required UFeedGetPostThreadThread thread,
    required AtUri uri,
  }) {
    switch (thread) {
      case UFeedGetPostThreadThreadThreadViewPost(:final data):
        try {
          var embed = data.post.embed;
          if (data.post.embed is bsky_defs.UPostViewEmbedEmbedExternalView) {
            embed = null;
          }
          final postJson = data.post.copyWith(embed: embed);

          // Create PostView with deep copy
          //Required because we modify nested structures like embeds
          final postViewJson = deepCopyJson(postJson.toJson());

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

          // Sanitize embeds using adapter (handles Bluesky-specific filtering)
          sanitizeBskyPostViewJson(postViewJson);

          // Convert from Bluesky format to Spark format
          convertPostViewJson(postViewJson);

          final sparkThread = Thread.threadViewPost(
            post: ThreadPost.post(post: PostView.fromJson(postViewJson)),
            parent: data.parent != null
                ? _convertParentToThread(data.parent!, uri)
                : null,
            replies: data.replies
                ?.map((reply) {
                  switch (reply) {
                    case bsky_defs.UThreadViewPostRepliesThreadViewPost(
                      :final data,
                    ):
                      // Filter out replies with EmbedViewRecord using adapter
                      if (shouldFilterReply(data.post)) {
                        return null;
                      }
                      return convertBskyThreadToSparkThread(
                        thread: UFeedGetPostThreadThread.threadViewPost(
                          data: data,
                        ),
                        uri: data.post.uri,
                      );
                    case bsky_defs.UThreadViewPostRepliesNotFoundPost(
                      :final data,
                    ):
                      return Thread.notFoundPost(uri: data.uri, notFound: true);
                    case bsky_defs.UThreadViewPostRepliesBlockedPost(
                      :final data,
                    ):
                      return Thread.blockedPost(
                        uri: data.uri,
                        blocked: true,
                        author: BlockedAuthor.fromJson(data.author.toJson()),
                      );
                    case bsky_defs.UThreadViewPostRepliesUnknown():
                      // Skip unknown reply types by returning null
                      return null;
                  }
                })
                .whereType<Thread>()
                .toList(),
          );
          return sparkThread;
        } catch (e) {
          rethrow;
        }
      case UFeedGetPostThreadThreadNotFoundPost(:final data):
        return Thread.notFoundPost(uri: data.uri, notFound: true);
      case UFeedGetPostThreadThreadBlockedPost(:final data):
        return Thread.blockedPost(
          uri: data.uri,
          blocked: true,
          author: BlockedAuthor.fromJson(data.author.toJson()),
        );
      default:
        throw Exception('Unsupported thread type: ${thread.runtimeType}');
    }
  }

  // ===========================================================================
  // Bluesky Feed Processing
  // ===========================================================================

  /// Check if a FeedViewPost has supported media
  bool _feedViewPostHasMedia(FeedViewPost feedViewPost) {
    return feedViewPost.map(
      post: (p) => p.post.hasSupportedMedia,
      reply: (r) => r.reply.media != null,
    );
  }

  /// Check if a FeedViewPost is a reply
  bool _feedViewPostIsReply(FeedViewPost feedViewPost) {
    return feedViewPost.map(post: (p) => p.reply != null, reply: (r) => true);
  }

  /// Process raw Bluesky FeedViewPost list and convert to Spark format
  /// Handles deep copy, conversion, parsing, and filtering
  /// (reposts, replies, media)
  ({List<FeedViewPost> posts, String? cursor}) processBskyAuthorFeed({
    required List<bsky_defs.FeedViewPost> rawFeed,
    required String? cursor,
    void Function(String message, {Object? error, StackTrace? stackTrace})?
    onError,
  }) {
    final feedPosts = <FeedViewPost>[];

    for (var i = 0; i < rawFeed.length; i++) {
      try {
        // Deep copy to make mutable
        final rawPost = deepCopyJson(rawFeed[i].toJson());

        // Convert using adapter
        convertFeedViewPostJson(rawPost);

        if (!rawPost.containsKey(r'$type')) {
          continue;
        }

        final parsedPost = FeedViewPost.fromJson(rawPost);
        feedPosts.add(parsedPost);
      } catch (e, stackTrace) {
        onError?.call(
          'Failed to parse bsky feed view #$i',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    // Convert to Spark format and filter
    final convertedPosts = feedPosts
        .map((post) => post.toSparkFeedViewPost())
        .toList();
    final filteredPosts = convertedPosts
        .where((post) => !_feedViewPostIsReply(post))
        .where(_feedViewPostHasMedia)
        .toList();

    return (posts: filteredPosts, cursor: cursor);
  }

  /// Process raw Bluesky feed items (from getFeed API), convert to Spark format
  /// Handles: conversion, parsing, and filtering (reposts, replies + media)
  List<FeedViewPost> processBskyFeedItems({
    required List<dynamic> feedData,
    void Function(String message, {StackTrace? stackTrace})? onWarning,
  }) {
    final feedPosts = <FeedViewPost>[];

    for (final item in feedData) {
      try {
        final itemMap = item as Map<String, dynamic>;

        // Convert the JSON to Spark format
        convertFeedViewPostJson(itemMap);

        // Ensure $type is set for FeedViewPost union type
        if (!itemMap.containsKey(r'$type')) {
          if (itemMap.containsKey('post')) {
            itemMap[r'$type'] = 'so.sprk.feed.defs#feedPostView';
          } else if (itemMap.containsKey('reply')) {
            itemMap[r'$type'] = 'so.sprk.feed.defs#feedReplyView';
          }
        }

        // Parse and convert
        final feedViewPost = FeedViewPost.fromJson(itemMap);
        final convertedPost = feedViewPost.toSparkFeedViewPost();
        feedPosts.add(convertedPost);
      } catch (e, stackTrace) {
        onWarning?.call(
          'Failed to parse feed item, skipping: $e',
          stackTrace: stackTrace,
        );
      }
    }

    // Filter out replies and posts without media
    return feedPosts
        .where((post) => !_feedViewPostIsReply(post))
        .where(_feedViewPostHasMedia)
        .toList();
  }

  /// Process raw Bluesky PostView list and convert to Spark format
  /// Handles: deep copy, conversion, parsing, and optional filtering
  List<PostView> processBskyPosts({
    required List<bsky_defs.PostView> rawPosts,
    bool filterByMedia = true,
  }) {
    final rawPostsJson =
        rawPosts.map((post) {
            final json = post.toJson();
            return deepCopyJson(json);
          })
          ..toList()
          // Convert each post
          ..forEach(convertPostViewJson);

    // Parse and convert to Spark format
    final parsedPosts = rawPostsJson.map(PostView.fromJson).toList();
    final sparkPosts = parsedPosts
        .map((post) => post.toSparkPostView())
        .toList();

    // Optionally filter by media
    if (filterByMedia) {
      return sparkPosts.where((post) => post.hasSupportedMedia).toList();
    }
    return sparkPosts;
  }
}

/// Singleton instance of the Bluesky feed adapter
///
/// Use this instance for all feed model conversions:
/// ```dart
/// bskyFeedAdapter.convertPostViewJson(rawPost);
/// bskyFeedAdapter.convertImages(sparkImages);
/// ```
const bskyFeedAdapter = BskyFeedAdapter();

// ============================================================================
// Extensions for feed model conversions
// ============================================================================

extension BskyPostRecordAdapter on BskyPostRecord {
  Record toSparkRecord() {
    if (reply != null) {
      return ReplyRecord(
        caption: CaptionRef(text: text ?? '', facets: facets ?? []),
        reply: reply!,
        media: embed,
        langs: langs,
        labels: selfLabels,
        createdAt: createdAt,
      );
    } else {
      return PostRecord(
        caption: CaptionRef(text: text ?? '', facets: facets ?? []),
        media: embed,
        createdAt: createdAt,
        langs: langs,
        tags: tags,
        selfLabels: selfLabels,
      );
    }
  }
}

extension BskyRecordAdapter on Record {
  Record toSparkRecord() {
    return when(
      post:
          (
            caption,
            createdAt,
            reply,
            langs,
            tags,
            selfLabels,
            crossposts,
            media,
            sound,
          ) => PostRecord(
            caption: caption,
            createdAt: createdAt,
            reply: reply,
            langs: langs,
            tags: tags,
            selfLabels: selfLabels,
            crossposts: crossposts,
            media: media,
            sound: sound,
          ),
      reply: (caption, reply, createdAt, langs, labels, media) => ReplyRecord(
        caption: caption,
        reply: reply,
        createdAt: createdAt,
        langs: langs,
        labels: labels,
        media: media,
      ),
      story: (media, createdAt, sound, labels, tags) => StoryRecord(
        media: media,
        createdAt: createdAt,
        sound: sound,
        labels: labels,
        tags: tags,
      ),
      profile:
          (
            displayName,
            description,
            avatar,
            banner,
            selfLabels,
            joinedViaStarterPack,
            pinnedPost,
            createdAt,
          ) => ProfileRecord(
            displayName: displayName,
            description: description,
            avatar: avatar,
            banner: banner,
            selfLabels: selfLabels,
            joinedViaStarterPack: joinedViaStarterPack,
            pinnedPost: pinnedPost,
            createdAt: createdAt,
          ),
      audio: (sound, title, createdAt, origin, details, labels) => AudioRecord(
        sound: sound,
        title: title,
        createdAt: createdAt,
        origin: origin,
        details: details,
        labels: labels,
      ),
      bskyPost:
          (createdAt, text, facets, reply, langs, tags, selfLabels, embed) =>
              BskyPostRecord(
                createdAt: createdAt,
                text: text,
                facets: facets,
                reply: reply,
                langs: langs,
                tags: tags,
                selfLabels: selfLabels,
                embed: embed,
              ).toSparkRecord(),
    );
  }
}

extension BskyPostViewAdapter on PostView {
  PostView toSparkPostView() {
    return copyWith(
      record: record.toSparkRecord() as PostRecord,
      likeCount: likeCount,
      replyCount: replyCount,
      repostCount: repostCount,
    );
  }
}

extension BskyReplyViewAdapter on ReplyView {
  ReplyView toSparkReplyView() {
    return copyWith(
      record: record.toSparkRecord(),
      media: media,
      replyCount: replyCount,
      likeCount: likeCount,
    );
  }
}

extension BskyFeedViewPostAdapter on FeedViewPost {
  FeedViewPost toSparkFeedViewPost() {
    return map(
      post: (postVariant) => FeedViewPost.post(
        post: postVariant.post.toSparkPostView(),
        reply: postVariant.reply,
      ),
      reply: (replyVariant) => FeedViewPost.reply(
        reply: replyVariant.reply.toSparkReplyView(),
        replyRef: replyVariant.replyRef,
      ),
    );
  }
}
