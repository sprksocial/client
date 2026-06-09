import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_write_adapters.dart';

void main() {
  const videoAspectRatio = MediaAspectRatio(width: 9, height: 16);

  Blob blob(String mimeType) {
    return Blob.fromJson({
      r'$type': 'blob',
      'mimeType': mimeType,
      'size': 42,
      'ref': {r'$link': 'bafkreigh2akiscaildc2'},
    });
  }

  group('MediaAspectRatio', () {
    test('normalizes video dimensions', () {
      expect(
        MediaAspectRatio.fromDimensions(width: 1080, height: 1920),
        videoAspectRatio,
      );
    });

    test('rejects missing or invalid dimensions', () {
      expect(MediaAspectRatio.fromDimensions(width: 0, height: 1920), isNull);
      expect(
        MediaAspectRatio.fromDimensions(width: null, height: 1920),
        isNull,
      );
    });
  });

  group('sprkPostRecordFromLocal', () {
    test('writes video posts with generated Spark media and label unions', () {
      final record = PostRecord(
        caption: const CaptionRef(text: 'hello #spark'),
        media: Media.video(
          video: blob('video/mp4'),
          alt: 'a clip',
          aspectRatio: videoAspectRatio,
        ),
        createdAt: DateTime.parse('2026-05-15T12:00:00.000Z'),
        selfLabels: const [SelfLabel(val: 'porn')],
        tags: const ['spark'],
        sound: RepoStrongRef(
          uri: AtUri.parse('at://did:plc:sound/so.sprk.sound.audio/1'),
          cid: 'sound-cid',
        ),
      );

      final json = sprkPostRecordFromLocal(record).toJson();

      expect(json[r'$type'], 'so.sprk.feed.post');
      expect(json['caption'][r'$type'], 'so.sprk.feed.post#captionRef');
      expect(json['media'][r'$type'], 'so.sprk.media.video');
      expect(json['media']['alt'], 'a clip');
      expect(json['media']['aspectRatio']['width'], 9);
      expect(json['media']['aspectRatio']['height'], 16);
      expect(json['labels'][r'$type'], 'com.atproto.label.defs#selfLabels');
      expect(json['labels']['values'], [
        {r'$type': 'com.atproto.label.defs#selfLabel', 'val': 'porn'},
      ]);
      expect(json['tags'], ['spark']);
      expect(json['sound']['cid'], 'sound-cid');
    });

    test('wraps a single local image as generated Spark images media', () {
      final record = PostRecord(
        caption: const CaptionRef(text: 'image'),
        media: Media.image(image: blob('image/jpeg')),
        createdAt: DateTime.parse('2026-05-15T12:00:00.000Z'),
      );

      final json = sprkPostRecordFromLocal(record).toJson();

      expect(json['media'][r'$type'], 'so.sprk.media.images');
      expect(json['media']['images'], hasLength(1));
      expect(json['media']['images'].first[r'$type'], 'so.sprk.media.image');
      expect(json['media']['images'].first['alt'], '');
    });

    test('writes image posts with post-level sound references', () {
      final record = PostRecord(
        caption: const CaptionRef(text: 'image with sound'),
        media: Media.image(image: blob('image/jpeg'), alt: 'cover'),
        createdAt: DateTime.parse('2026-05-15T12:00:00.000Z'),
        sound: RepoStrongRef(
          uri: AtUri.parse('at://did:plc:sound/so.sprk.sound.audio/1'),
          cid: 'sound-cid',
        ),
      );

      final json = sprkPostRecordFromLocal(record).toJson();

      expect(json['media'][r'$type'], 'so.sprk.media.images');
      expect(json['sound']['uri'], 'at://did:plc:sound/so.sprk.sound.audio/1');
      expect(json['sound']['cid'], 'sound-cid');
    });

    test('omits absent optional labels, tags, and sound', () {
      final record = PostRecord(
        caption: const CaptionRef(text: 'minimal'),
        media: Media.video(video: blob('video/mp4')),
        createdAt: DateTime.parse('2026-05-15T12:00:00.000Z'),
        selfLabels: const [],
      );

      final json = sprkPostRecordFromLocal(record).toJson();

      expect(json['labels'], isNull);
      expect(json['tags'], isNull);
      expect(json['sound'], isNull);
    });
  });

  group('sprkReplyRecordFromLocal', () {
    test('writes reply refs and image media with generated Spark shapes', () {
      final record = ReplyRecord(
        caption: const CaptionRef(text: 'reply'),
        reply: RecordReplyRef(
          root: RepoStrongRef(
            uri: AtUri.parse('at://did:plc:root/so.sprk.feed.post/1'),
            cid: 'root-cid',
          ),
          parent: RepoStrongRef(
            uri: AtUri.parse('at://did:plc:parent/so.sprk.feed.post/2'),
            cid: 'parent-cid',
          ),
        ),
        media: Media.image(image: blob('image/jpeg'), alt: 'reply image'),
        createdAt: DateTime.parse('2026-05-15T12:00:00.000Z'),
      );

      final json = sprkReplyRecordFromLocal(record).toJson();

      expect(json[r'$type'], 'so.sprk.feed.reply');
      expect(json['reply'][r'$type'], 'so.sprk.feed.reply#replyRef');
      expect(json['reply']['root']['cid'], 'root-cid');
      expect(json['media'][r'$type'], 'so.sprk.media.image');
      expect(json['media']['alt'], 'reply image');
    });
  });

  group('sprkStoryRecordFromLocal', () {
    test('writes story media, labels, sound, and mention embeds', () {
      final json = sprkStoryRecordFromLocal(
        media: Media.video(
          video: blob('video/mp4'),
          alt: 'story clip',
          aspectRatio: videoAspectRatio,
        ),
        createdAt: DateTime.parse('2026-05-15T12:00:00.000Z'),
        labels: const [SelfLabel(val: 'nudity')],
        sound: RepoStrongRef(
          uri: AtUri.parse('at://did:plc:sound/so.sprk.sound.audio/1'),
          cid: 'sound-cid',
        ),
        embeds: const [
          StoryEmbed(
            placement: StoryEmbedPlacement(
              frame: StoryEmbedFrame(x: 10, y: 20, w: 30, h: 40),
              mediaRef: StoryEmbedMediaRef(index: 0),
              zIndex: 2,
              rotation: 15,
            ),
            did: 'did:plc:mentioned',
          ),
        ],
      ).toJson();

      expect(json[r'$type'], 'so.sprk.story.post');
      expect(json['media'][r'$type'], 'so.sprk.media.video');
      expect(json['media']['alt'], 'story clip');
      expect(json['media']['aspectRatio']['width'], 9);
      expect(json['media']['aspectRatio']['height'], 16);
      expect(json['labels'][r'$type'], 'com.atproto.label.defs#selfLabels');
      expect(json['sound']['cid'], 'sound-cid');
      expect(json['tags'], isNull);
      expect(json['embeds'], hasLength(1));
      expect(json['embeds'].first[r'$type'], 'so.sprk.embed.mention');
      expect(json['embeds'].first['did'], 'did:plc:mentioned');
      expect(json['embeds'].first['placement']['frame']['x'], 10);
      expect(json['embeds'].first['placement']['mediaRef']['index'], 0);
      expect(json['embeds'].first['placement']['zIndex'], 2);
      expect(json['embeds'].first['placement']['rotation'], 15);
    });

    test('omits empty story labels, embeds, and absent sound', () {
      final json = sprkStoryRecordFromLocal(
        media: Media.image(image: blob('image/jpeg')),
        createdAt: DateTime.parse('2026-05-15T12:00:00.000Z'),
        labels: const [],
        embeds: const [],
      ).toJson();

      expect(json['labels'], isNull);
      expect(json['embeds'], isNull);
      expect(json['sound'], isNull);
    });
  });
}
