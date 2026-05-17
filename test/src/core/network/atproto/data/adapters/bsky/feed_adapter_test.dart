import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/adapters/bsky/feed_adapter.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

void main() {
  const adapter = BskyFeedAdapter();

  Map<String, dynamic> profileJson() => {
    'did': 'did:plc:author',
    'handle': 'author.sprk.so',
    'displayName': 'Author',
    'avatar': 'https://cdn.example.com/avatar.jpg',
  };

  Map<String, dynamic> imageJson(String id) => {
    'thumb': 'https://cdn.example.com/$id-thumb.jpg',
    'fullsize': 'https://cdn.example.com/$id-full.jpg',
    'alt': '$id alt',
  };

  Map<String, dynamic> strongRefJson(String rkey) => {
    r'$type': 'com.atproto.repo.strongRef',
    'uri': 'at://did:plc:author/app.bsky.feed.post/$rkey',
    'cid': '$rkey-cid',
  };

  Map<String, dynamic> postViewJson({
    Map<String, dynamic>? record,
    Map<String, dynamic>? embed,
  }) {
    final json = {
      'uri': 'at://did:plc:author/app.bsky.feed.post/1',
      'cid': 'post-cid',
      'author': profileJson(),
      'record':
          record ??
          {
            r'$type': 'app.bsky.feed.post',
            'text': 'hello from bluesky',
            'facets': [
              {
                'index': {'byteStart': 0, 'byteEnd': 5},
                'features': [
                  {r'$type': 'app.bsky.richtext.facet#tag', 'tag': 'hello'},
                ],
              },
            ],
            'createdAt': '2026-05-15T12:00:00.000Z',
          },
      'indexedAt': '2026-05-15T12:00:01.000Z',
    };
    if (embed != null) {
      json['embed'] = embed;
    }
    return json;
  }

  group('convertPostViewJson', () {
    test('converts Bluesky text and images into Spark post shape', () {
      final post = postViewJson(
        embed: {
          r'$type': 'app.bsky.embed.images#view',
          'images': [imageJson('first'), imageJson('second')],
        },
      );

      adapter.convertPostViewJson(post);

      final record = post['record'] as Map<String, dynamic>;
      final caption = record['caption'] as Map<String, dynamic>;
      final media = post['media'] as Map<String, dynamic>;

      expect(record[r'$type'], 'so.sprk.feed.post');
      expect(record.containsKey('text'), isFalse);
      expect(record.containsKey('facets'), isFalse);
      expect(caption['text'], 'hello from bluesky');
      expect(caption['facets'], hasLength(1));
      expect(media[r'$type'], 'so.sprk.media.images#view');
      expect(media['images'], hasLength(2));

      final parsed = PostView.fromJson(post);
      expect(parsed.displayText, 'hello from bluesky');
      expect(parsed.imageUrls, [
        'https://cdn.example.com/first-full.jpg',
        'https://cdn.example.com/second-full.jpg',
      ]);
    });

    test('keeps reply image media parseable through local fallback', () {
      final post = postViewJson(
        record: {
          r'$type': 'app.bsky.feed.post',
          'text': 'reply with image',
          'createdAt': '2026-05-15T12:00:00.000Z',
          'reply': {
            'root': strongRefJson('root'),
            'parent': strongRefJson('parent'),
          },
        },
        embed: {
          r'$type': 'app.bsky.embed.images#view',
          'images': [imageJson('reply')],
        },
      );

      adapter.convertPostViewJson(post);

      final parsed = PostView.fromJson(post);
      expect(parsed.thumbnailUrl, 'https://cdn.example.com/reply-thumb.jpg');
      expect(parsed.imageUrls, ['https://cdn.example.com/reply-full.jpg']);
    });

    test('unwraps recordWithMedia into Spark media view', () {
      final post = postViewJson(
        embed: {
          r'$type': 'app.bsky.embed.recordWithMedia#view',
          'record': {
            r'$type': 'app.bsky.embed.record#view',
            'record': {
              r'$type': 'app.bsky.embed.record#viewNotFound',
              'uri': 'at://did:plc:other/app.bsky.feed.post/2',
              'notFound': true,
            },
          },
          'media': {
            r'$type': 'app.bsky.embed.images#view',
            'images': [imageJson('nested')],
          },
        },
      );

      adapter.convertPostViewJson(post);

      final media = post['media'] as Map<String, dynamic>;
      expect(media[r'$type'], 'so.sprk.media.images#view');
      expect(
        media['images'].single['fullsize'],
        'https://cdn.example.com/nested-full.jpg',
      );
      expect(PostView.fromJson(post).imageUrls, [
        'https://cdn.example.com/nested-full.jpg',
      ]);
    });

    test('drops malformed and unsupported embeds before parsing', () {
      final missingExternalCid = postViewJson(
        embed: {
          r'$type': 'app.bsky.embed.external#view',
          'external': {'uri': 'https://example.com', 'title': 'Example'},
        },
      );
      final unsupportedRecord = postViewJson(
        embed: {
          r'$type': 'app.bsky.embed.record#view',
          'record': {
            r'$type': 'app.bsky.feed.defs#generatorView',
            'uri': 'at://did:plc:feed/app.bsky.feed.generator/1',
          },
        },
      );

      adapter.sanitizeBskyPostViewJson(missingExternalCid);
      adapter.sanitizeBskyPostViewJson(unsupportedRecord);

      expect(missingExternalCid.containsKey('embed'), isFalse);
      expect(unsupportedRecord.containsKey('embed'), isFalse);
    });
  });
}
