import 'package:poptart/poptart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_write_adapters.dart';
import 'package:sprk_poptart/so/sprk/story/get_stories/output.dart'
    as sprk_get_stories;
import 'package:sprk_poptart/so/sprk/story/get_timeline/output.dart'
    as sprk_get_timeline;

void main() {
  group('story embed parsing', () {
    test(
      'storyEmbedsFromJson parses mention embeds and skips malformed items',
      () {
        final embeds = storyEmbedsFromJson([
          {
            r'$type': 'so.sprk.embed.mention',
            'placement': {
              'frame': {'x': 1200, 'y': 3400, 'w': 2500, 'h': 900},
              'mediaRef': {'index': 0},
              'zIndex': 2,
              'rotation': 15,
            },
            'did': 'did:plc:mentioned-user',
          },
          {
            r'$type': 'so.sprk.embed.mention',
            'placement': {'zIndex': 3},
            'did': 'did:plc:broken-user',
          },
          'not-a-map',
        ]);

        expect(embeds, hasLength(1));

        final mention = embeds.single;
        expect(mention.did, 'did:plc:mentioned-user');
        expect(mention.placement.frame.x, 1200);
        expect(mention.placement.frame.y, 3400);
        expect(mention.placement.frame.w, 2500);
        expect(mention.placement.frame.h, 900);
        expect(mention.placement.mediaRef?.index, 0);
        expect(mention.placement.zIndex, 2);
        expect(mention.placement.rotation, 15);
      },
    );

    test(
      'StoryView.fromJson preserves hydrated embeds and skips malformed ones',
      () {
        final story = StoryView.fromJson({
          'cid': 'bafyreicid',
          'uri': 'at://did:plc:author/so.sprk.story.post/3lk4example',
          'author': {'did': 'did:plc:author', 'handle': 'author.sprk.so'},
          'record': {
            r'$type': 'so.sprk.story.post',
            'media': {
              r'$type': 'so.sprk.media.image',
              'image': {
                r'$type': 'blob',
                'mimeType': 'image/jpeg',
                'size': 42,
                'ref': {r'$link': 'bafkreigh2akiscaildc2'},
              },
            },
            'createdAt': '2026-04-05T12:00:00.000Z',
            'embeds': [
              {
                r'$type': 'so.sprk.embed.mention',
                'placement': {
                  'frame': {'x': 1000, 'y': 2000, 'w': 3000, 'h': 1000},
                  'zIndex': 1,
                },
                'did': 'did:plc:record-mentioned',
              },
            ],
          },
          'indexedAt': '2026-04-05T12:00:01.000Z',
          'embeds': [
            {
              r'$type': 'so.sprk.embed.mention#view',
              'placement': {
                'frame': {'x': 1000, 'y': 2000, 'w': 3000, 'h': 1000},
                'zIndex': 1,
                'rotation': 30,
              },
              'did': 'did:plc:view-mentioned',
              'actor': {
                'did': 'did:plc:view-mentioned',
                'handle': 'mention.sprk.so',
                'displayName': 'Mentioned User',
              },
            },
            {
              r'$type': 'so.sprk.embed.mention#view',
              'placement': {'zIndex': 99},
              'did': 'did:plc:broken-view',
            },
          ],
        });

        expect(story.localRecord, isA<StoryRecord>());
        expect(story.localRecord!.localEmbeds, hasLength(1));
        expect(story.localEmbeds, hasLength(1));

        final recordMention = story.localRecord!.localEmbeds.single;
        expect(recordMention.did, 'did:plc:record-mentioned');

        final viewMention = story.localEmbeds!.single;
        expect(viewMention.did, 'did:plc:view-mentioned');
        expect(viewMention.actor?.handle, 'mention.sprk.so');
        expect(viewMention.placement.rotation, 30);
      },
    );

    test('StoryRecord.toJson includes lexicon type on embeds', () {
      final record = sprkStoryRecordFromLocal(
        media: Media.image(
          image: Blob.fromJson({
            r'$type': 'blob',
            'mimeType': 'image/jpeg',
            'size': 42,
            'ref': {r'$link': 'bafkreigh2akiscaildc2'},
          }),
        ),
        createdAt: DateTime.parse('2026-04-05T12:00:00.000Z'),
        embeds: [
          StoryEmbed(
            did: 'did:plc:mentioned-user',
            placement: const StoryEmbedPlacement(
              frame: StoryEmbedFrame(x: 1000, y: 2000, w: 3000, h: 1000),
            ),
          ),
        ],
      );

      final json = record.toJson();
      final embeds = json['embeds'] as List<dynamic>;
      final mention = embeds.single as Map<String, dynamic>;

      expect(mention[r'$type'], 'so.sprk.embed.mention');
      expect(mention['did'], 'did:plc:mentioned-user');
    });

    test('sprk_poptart story responses parse image stories by author', () {
      final author = {
        'did': 'did:plc:author',
        'handle': 'author.sprk.so',
        'displayName': 'Author',
        'avatar': 'https://cdn.example.com/avatar.jpg',
      };
      final storyJson = {
        'cid': 'story-cid',
        'uri': 'at://did:plc:author/so.sprk.story.post/1',
        'author': author,
        'record': {
          r'$type': 'so.sprk.story.post',
          'media': {
            r'$type': 'so.sprk.media.image',
            'image': {
              r'$type': 'blob',
              'mimeType': 'image/jpeg',
              'size': 42,
              'ref': {r'$link': 'bafkreigh2akiscaildc2'},
            },
          },
          'createdAt': '2026-04-05T12:00:00.000Z',
        },
        'media': {
          r'$type': 'so.sprk.media.image#view',
          'thumb': 'https://cdn.example.com/story-thumb.jpg',
          'fullsize': 'https://cdn.example.com/story-full.jpg',
          'alt': 'story image',
        },
        'embeds': [
          {
            r'$type': 'so.sprk.embed.mention#view',
            'placement': {
              'frame': {'x': 1000, 'y': 2000, 'w': 3000, 'h': 1000},
              'zIndex': 1,
            },
            'did': 'did:plc:view-mentioned',
            'actor': {
              'did': 'did:plc:view-mentioned',
              'handle': 'mention.sprk.so',
            },
          },
        ],
        'indexedAt': '2026-04-05T12:00:01.000Z',
      };

      final timeline = sprk_get_timeline.StoryGetTimelineOutput.fromJson({
        'cursor': 'story-cursor',
        'storiesByAuthor': [
          {
            'author': author,
            'stories': [storyJson],
          },
        ],
      });
      final stories = sprk_get_stories.StoryGetStoriesOutput.fromJson({
        'stories': [storyJson],
      });

      expect(timeline.cursor, 'story-cursor');
      expect(timeline.storiesByAuthor.single.author.handle, 'author.sprk.so');
      expect(
        timeline.storiesByAuthor.single.stories.single.imageUrl,
        'https://cdn.example.com/story-full.jpg',
      );
      expect(
        stories.stories.single.thumbnailUrl,
        'https://cdn.example.com/story-thumb.jpg',
      );
      expect(
        stories.stories.single.localEmbeds?.single.did,
        'did:plc:view-mentioned',
      );
    });
  });
}
