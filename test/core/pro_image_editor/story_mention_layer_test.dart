import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';
import 'package:spark/src/core/pro_image_editor/story_mention_layer.dart';
import 'package:spark/src/core/ui/widgets/story_mention_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('story mention widget layers', () {
    test('createStoryMentionLayer marks a widget layer as a story mention', () {
      final layer = createStoryMentionLayer(
        _actor('did:plc:first', 'first.sprk.so'),
      );

      expect(layer, isA<WidgetLayer>());
      expect(isStoryMentionLayer(layer), isTrue);
      expect(layer.meta?['did'], 'did:plc:first');
      expect(layer.meta?['handle'], 'first.sprk.so');
    });

    test(
      'extractStoryMentionEmbeds exports normalized placement from layers',
      () {
        final baseSize = measureStoryMentionChipSize(
          primaryText: '@first.sprk.so',
          height: kStoryMentionInitialHeight,
        );
        final mention =
            createStoryMentionLayer(_actor('did:plc:first', 'first.sprk.so'))
              ..width = 200
              ..offset = const Offset(-100, 50)
              ..scale = 1.5
              ..rotation = math.pi / 2;

        final embeds = extractStoryMentionEmbeds([
          mention,
        ], canvasSize: const Size(1000, 1000));

        expect(embeds, hasLength(1));

        final embed = embeds.single as StoryMentionEmbed;
        final expectedWidth = 3000;
        final expectedHeight =
            ((200 * 1.5) * (baseSize.height / baseSize.width) / 1000 * 10000)
                .round();
        final renderedHeight = (200 * 1.5) * (baseSize.height / baseSize.width);
        final expectedTop = 50 + 500 - renderedHeight / 2;
        expect(embed.did, 'did:plc:first');
        expect(embed.placement.frame.x, 2500);
        expect(embed.placement.frame.y, ((expectedTop / 1000) * 10000).round());
        expect(embed.placement.frame.w, expectedWidth);
        expect(embed.placement.frame.h, expectedHeight);
        expect(embed.placement.zIndex, 0);
        expect(embed.placement.rotation, 90);
      },
    );

    test('extractStoryMentionEmbeds ignores non-mention widget layers', () {
      final mention = createStoryMentionLayer(
        _actor('did:plc:first', 'first.sprk.so'),
      );
      final background = WidgetLayer(
        widget: const SizedBox.shrink(),
        meta: const {'kind': 'background'},
      );

      final embeds = extractStoryMentionEmbeds([
        background,
        mention,
      ], canvasSize: const Size(1000, 1000));
      final embed = embeds.single as StoryMentionEmbed;

      expect(embeds, hasLength(1));
      expect(embed.did, 'did:plc:first');
      expect(embed.placement.zIndex, 1);
    });

    test('extractStoryMentionEmbeds clips partially off-canvas mentions', () {
      final baseSize = measureStoryMentionChipSize(
        primaryText: '@first.sprk.so',
        height: kStoryMentionInitialHeight,
      );
      final mention =
          createStoryMentionLayer(_actor('did:plc:first', 'first.sprk.so'))
            ..width = 200
            ..offset = const Offset(-450, 0);

      final embeds = extractStoryMentionEmbeds([
        mention,
      ], canvasSize: const Size(1000, 1000));

      expect(embeds, hasLength(1));

      final embed = embeds.single as StoryMentionEmbed;
      final renderedWidth = 200.0;
      final renderedHeight = renderedWidth * (baseSize.height / baseSize.width);
      final unclippedLeft = -450 + 500 - renderedWidth / 2;
      final unclippedTop = 500 - renderedHeight / 2;
      final clippedWidth = renderedWidth - (0 - unclippedLeft);

      expect(embed.placement.frame.x, 0);
      expect(embed.placement.frame.y, ((unclippedTop / 1000) * 10000).round());
      expect(embed.placement.frame.w, ((clippedWidth / 1000) * 10000).round());
      expect(
        embed.placement.frame.h,
        ((renderedHeight / 1000) * 10000).round(),
      );
    });

    test('extractStoryMentionEmbeds drops fully clipped mentions', () {
      final mention =
          createStoryMentionLayer(_actor('did:plc:first', 'first.sprk.so'))
            ..width = 200
            ..offset = const Offset(-700, 0);

      final embeds = extractStoryMentionEmbeds([
        mention,
      ], canvasSize: const Size(1000, 1000));

      expect(embeds, isEmpty);
    });
  });
}

ProfileViewBasic _actor(String did, String handle) {
  return ProfileViewBasic(did: did, handle: handle);
}
