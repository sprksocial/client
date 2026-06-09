import 'package:flutter_test/flutter_test.dart';
import 'package:sprk_poptart/so/sprk/feed/get_feed/output.dart'
    as sprk_get_feed;
import 'package:sprk_poptart/so/sprk/feed/get_posts/output.dart'
    as sprk_get_posts;
import 'package:sprk_poptart/so/sprk/feed/get_timeline/output.dart'
    as sprk_get_timeline;
import 'package:sprk_poptart/so/sprk/feed/search_posts/output.dart'
    as sprk_search_posts;

import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_video_aspect_ratio.dart';

void main() {
  Map<String, dynamic> authorJson() => {
    'did': 'did:plc:author',
    'handle': 'author.sprk.so',
    'displayName': 'Author',
    'avatar': 'https://cdn.example.com/avatar.jpg',
  };

  Map<String, dynamic> imageViewJson() => {
    r'$type': 'so.sprk.media.image#view',
    'thumb': 'https://cdn.example.com/thumb.jpg',
    'fullsize': 'https://cdn.example.com/full.jpg',
    'alt': 'fixture image',
  };

  Map<String, dynamic> videoBlobJson() => {
    r'$type': 'blob',
    'ref': {r'$link': 'bafkreigh2akiscaildc2'},
    'mimeType': 'video/mp4',
    'size': 42,
  };

  Map<String, dynamic> videoViewJson() => {
    r'$type': 'so.sprk.media.video#view',
    'cid': 'video-cid',
    'playlist': 'https://cdn.example.com/video.m3u8',
    'thumbnail': 'https://cdn.example.com/video-thumb.jpg',
    'aspectRatio': {'width': 9, 'height': 16},
  };

  Map<String, dynamic> videoRecordMediaJson() => {
    r'$type': 'so.sprk.media.video',
    'video': videoBlobJson(),
    'aspectRatio': {'width': 9, 'height': 16},
  };

  Map<String, dynamic> postViewJson({
    Map<String, dynamic>? media,
    Map<String, dynamic>? recordMedia,
  }) => {
    r'$type': 'so.sprk.feed.defs#postView',
    'uri': 'at://did:plc:author/so.sprk.feed.post/1',
    'cid': 'post-cid',
    'author': authorJson(),
    'record': {
      r'$type': 'so.sprk.feed.post',
      'caption': {
        r'$type': 'so.sprk.feed.post#captionRef',
        'text': 'spark fixture',
      },
      if (recordMedia != null) 'media': recordMedia,
      'createdAt': '2026-05-15T12:00:00.000Z',
    },
    'media':
        media ??
        {
          r'$type': 'so.sprk.media.images#view',
          'images': [imageViewJson()],
        },
    'replyCount': 1,
    'repostCount': 2,
    'likeCount': 3,
    'indexedAt': '2026-05-15T12:00:01.000Z',
  };

  Map<String, dynamic> feedViewPostJson({
    Map<String, dynamic>? media,
    Map<String, dynamic>? recordMedia,
  }) => {
    r'$type': 'so.sprk.feed.defs#feedViewPost',
    'post': postViewJson(media: media, recordMedia: recordMedia),
    'feedContext': 'context-token',
  };

  group('sprk_poptart feed response fixtures', () {
    test('getTimeline parses into local feed views', () {
      final output = sprk_get_timeline.FeedGetTimelineOutput.fromJson({
        'cursor': 'next-cursor',
        'feed': [feedViewPostJson()],
      });

      final post = output.feed.single.localPost;
      expect(output.cursor, 'next-cursor');
      expect(output.feed.single.feedContext, 'context-token');
      expect(post.displayText, 'spark fixture');
      expect(post.imageUrls, ['https://cdn.example.com/full.jpg']);
    });

    test('getFeed parses into local feed views', () {
      final output = sprk_get_feed.FeedGetFeedOutput.fromJson({
        'cursor': 'next-feed-cursor',
        'feed': [feedViewPostJson()],
      });

      expect(output.cursor, 'next-feed-cursor');
      expect(
        output.feed.single.localPost.thumbnailUrl,
        'https://cdn.example.com/thumb.jpg',
      );
    });

    test('getFeed exposes video aspect ratio for thumbnail fitting', () {
      final output = sprk_get_feed.FeedGetFeedOutput.fromJson({
        'cursor': 'next-feed-cursor',
        'feed': [feedViewPostJson(media: videoViewJson())],
      });

      final post = output.feed.single.localPost;

      expect(post.videoUrl, 'https://cdn.example.com/video.m3u8');
      expect(post.thumbnailUrl, 'https://cdn.example.com/video-thumb.jpg');
      expect(post.videoAspectRatio, closeTo(9 / 16, 0.0001));
    });

    test('getFeed falls back to record video aspect ratio', () {
      final media = videoViewJson()..remove('aspectRatio');
      final output = sprk_get_feed.FeedGetFeedOutput.fromJson({
        'cursor': 'next-feed-cursor',
        'feed': [
          feedViewPostJson(media: media, recordMedia: videoRecordMediaJson()),
        ],
      });

      expect(
        output.feed.single.localPost.videoAspectRatio,
        closeTo(9 / 16, 0.0001),
      );
    });

    test('getPosts parses into local post views', () {
      final output = sprk_get_posts.FeedGetPostsOutput.fromJson({
        'posts': [postViewJson()],
      });

      expect(output.posts.single, isA<PostView>());
      expect(output.posts.single.displayText, 'spark fixture');
      expect(output.posts.single.hasSupportedMedia, isTrue);
    });

    test('searchPosts parses hits and local post views', () {
      final output = sprk_search_posts.FeedSearchPostsOutput.fromJson({
        'cursor': 'search-cursor',
        'hitsTotal': 42,
        'posts': [postViewJson()],
      });

      expect(output.cursor, 'search-cursor');
      expect(output.hitsTotal, 42);
      expect(output.posts.single.displayText, 'spark fixture');
    });
  });
}
