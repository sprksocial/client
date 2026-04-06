import 'package:atproto/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';

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

        final mention = embeds.single as StoryMentionEmbed;
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

        expect(story.record, isA<StoryRecord>());
        expect(story.record.embeds, hasLength(1));
        expect(story.embeds, hasLength(1));

        final recordMention = story.record.embeds!.single as StoryMentionEmbed;
        expect(recordMention.did, 'did:plc:record-mentioned');

        final viewMention = story.embeds!.single as StoryMentionEmbedView;
        expect(viewMention.did, 'did:plc:view-mentioned');
        expect(viewMention.actor?.handle, 'mention.sprk.so');
        expect(viewMention.placement.rotation, 30);
      },
    );

    test('StoryRecord.toJson includes lexicon type on embeds', () {
      final record =
          Record.story(
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
                  StoryEmbed.mention(
                    did: 'did:plc:mentioned-user',
                    placement: const StoryEmbedPlacement(
                      frame: StoryEmbedFrame(
                        x: 1000,
                        y: 2000,
                        w: 3000,
                        h: 1000,
                      ),
                    ),
                  ),
                ],
              )
              as StoryRecord;

      final json = record.toJson();
      final embeds = json['embeds'] as List<dynamic>;
      final mention = embeds.single as Map<String, dynamic>;

      expect(mention[r'$type'], 'so.sprk.embed.mention');
      expect(mention['did'], 'did:plc:mentioned-user');
    });
  });
}
