import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sprk_poptart/so/sprk/feed/get_feed/output.dart'
    as sprk_get_feed;
import 'package:sprk_poptart/so/sprk/feed/get_posts/output.dart'
    as sprk_get_posts;
import 'package:sprk_poptart/so/sprk/feed/get_timeline/output.dart'
    as sprk_get_timeline;
import 'package:sprk_poptart/so/sprk/feed/search_posts/output.dart'
    as sprk_search_posts;

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

  Map<String, dynamic> postViewJson() => {
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
      'createdAt': '2026-05-15T12:00:00.000Z',
    },
    'media': {
      r'$type': 'so.sprk.media.images#view',
      'images': [imageViewJson()],
    },
    'replyCount': 1,
    'repostCount': 2,
    'likeCount': 3,
    'indexedAt': '2026-05-15T12:00:01.000Z',
  };

  Map<String, dynamic> feedViewPostJson() => {
    r'$type': 'so.sprk.feed.defs#feedViewPost',
    'post': postViewJson(),
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
