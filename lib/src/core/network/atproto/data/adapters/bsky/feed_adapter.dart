import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart' as bsky;
// ignore: implementation_imports
import 'package:bluesky/src/services/entities/converter/embed_converter.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

/// Adapter for Bluesky feed models <-> Spark feed models
///
/// Handles bidirectional conversion between Bluesky feed data structures
/// and Spark feed data structures. This includes posts, replies, threads,
/// and all associated metadata.
class BskyFeedAdapter {
  const BskyFeedAdapter();

  // ============================================================================
  // Bluesky -> Spark Conversions
  // ============================================================================
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
  void convertPostViewJson(Map<String, dynamic> post, {bool isNestedReply = false}) {
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

        record['caption'] = {
          'text': text,
          'facets': facets,
        };

        record[r'$type'] = 'so.sprk.feed.post';

        if (record.containsKey('embed')) {
          record['media'] = record['embed'];
          record.remove('embed');
        }

        record.remove('text');
        record.remove('facets');

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
        final postViewData = jsonDecode(jsonEncode(root)) as Map<String, dynamic>;
        postViewData.remove(r'$type');
        convertPostViewJson(postViewData, isNestedReply: true);
        root.removeWhere((key, value) => key != r'$type');
        root['post'] = postViewData;
      } else if (rootType == 'app.bsky.feed.defs#notFoundPost' || rootType == 'app.bsky.feed.defs#blockedPost') {
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
        final postViewData = jsonDecode(jsonEncode(parent)) as Map<String, dynamic>;
        postViewData.remove(r'$type');
        convertPostViewJson(postViewData, isNestedReply: true);
        parent.removeWhere((key, value) => key != r'$type');
        parent['post'] = postViewData;
      } else if (parentType == 'app.bsky.feed.defs#notFoundPost' || parentType == 'app.bsky.feed.defs#blockedPost') {
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

  // ============================================================================
  // Spark -> Bluesky Conversions
  // ============================================================================

  /// Convert Spark images to Bluesky images
  List<bsky.Image> convertImages(List<Image> sparkImages) {
    return sparkImages.map((sparkImage) {
      return bsky.Image(
        alt: sparkImage.alt ?? '',
        image: sparkImage.image,
      );
    }).toList();
  }

  /// Create a Bluesky post record
  bsky.PostRecord createPostRecord({
    required String text,
    required DateTime createdAt,
    List<bsky.Image>? images,
    List<bsky.Facet>? facets,
  }) {
    return bsky.PostRecord(
      text: text,
      createdAt: createdAt,
      embed: images != null && images.isNotEmpty ? bsky.Embed.images(data: bsky.EmbedImages(images: images)) : null,
      facets: facets,
    );
  }

  /// Create Bluesky comment/reply record
  bsky.PostRecord createCommentRecord({
    required String text,
    required DateTime createdAt,
    required bsky.ReplyRef reply,
    bsky.Embed? embed,
  }) {
    return bsky.PostRecord(
      text: text,
      createdAt: createdAt,
      reply: reply,
      embed: embed,
    );
  }

  /// Create a link facet for Bluesky posts
  bsky.Facet createLinkFacet({
    required String linkUrl,
    required int byteStart,
  }) {
    return bsky.Facet(
      index: bsky.ByteSlice(byteStart: byteStart, byteEnd: byteStart + linkUrl.length),
      features: [bsky.FacetFeature.link(data: bsky.FacetLink(uri: linkUrl))],
    );
  }

  /// Convert Bluesky thread to Spark thread
  Thread convertBskyThreadToSparkThread({
    required bsky.PostThreadView thread,
    required AtUri uri,
  }) {
    return Thread.fromBsky(thread: thread, uri: uri);
  }

  /// Convert media JSON to Bluesky embed
  bsky.Embed? convertJsonToBskyEmbed(Map<String, dynamic> mediaJson) {
    return embedConverter.fromJson(mediaJson);
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
      post: (caption, createdAt, reply, langs, tags, selfLabels, media, sound) => PostRecord(
        caption: caption,
        createdAt: createdAt,
        reply: reply,
        langs: langs,
        tags: tags,
        selfLabels: selfLabels,
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
      profile: (displayName, description, avatar, banner, selfLabels, joinedViaStarterPack, pinnedPost, createdAt) =>
          ProfileRecord(
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
      bskyPost: (createdAt, text, facets, reply, langs, tags, selfLabels, embed) => BskyPostRecord(
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
      quoteCount: quoteCount,
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
