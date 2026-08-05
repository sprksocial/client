import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/media_editor/story/ui/widgets/story_editor_bottom_section.dart';
import 'package:spark/src/features/media_editor/story/ui/widgets/story_editor_top_section.dart';

void main() {
  testWidgets(
    'puts creation tools in the top overlay and keeps them tappable',
    (tester) async {
      var closeCount = 0;
      var textCount = 0;
      var stickerCount = 0;
      var mentionCount = 0;

      await tester.pumpWidget(
        _testApp(
          StoryEditorTopSection(
            onClose: () => closeCount++,
            onMention: () async => mentionCount++,
            onPaint: () {},
            onText: () => textCount++,
            onFilter: () {},
            onBlur: () {},
            onEmoji: () {},
            onStickers: () => stickerCount++,
          ),
        ),
      );

      expect(find.byKey(const ValueKey('story-editor-close')), findsOneWidget);
      expect(find.byKey(const ValueKey('story-editor-undo')), findsNothing);
      expect(find.byKey(const ValueKey('story-editor-redo')), findsNothing);
      expect(
        find.byKey(const ValueKey('story-editor-tool-text')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('story-editor-tool-stickers')),
        findsOneWidget,
      );
      expect(find.text('Text'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('story-editor-close')));
      await tester.tap(find.byKey(const ValueKey('story-editor-tool-text')));
      await tester.tap(
        find.byKey(const ValueKey('story-editor-tool-stickers')),
      );
      await tester.tap(find.byKey(const ValueKey('story-editor-tool-mention')));

      expect(closeCount, 1);
      expect(textCount, 1);
      expect(stickerCount, 1);
      expect(mentionCount, 1);
    },
  );

  testWidgets(
    'keeps the share action at the bottom below contextual controls',
    (tester) async {
      var shareCount = 0;

      await tester.pumpWidget(
        _testApp(
          Align(
            alignment: Alignment.bottomCenter,
            child: StoryEditorBottomSection(
              onShare: () => shareCount++,
              contextualControl: const SizedBox(
                key: ValueKey('story-contextual-control'),
                height: 48,
              ),
            ),
          ),
        ),
      );

      final contextualTop = tester.getTopLeft(
        find.byKey(const ValueKey('story-contextual-control')),
      );
      final shareTop = tester.getTopLeft(
        find.byKey(const ValueKey('story-editor-share-button')),
      );

      expect(contextualTop.dy, lessThan(shareTop.dy));
      expect(find.text('Share'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('story-editor-share-button')));
      expect(shareCount, 1);
    },
  );

  testWidgets('stacks actions vertically at the top right', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _testApp(
        StoryEditorTopSection(
          onClose: () {},
          onMention: () async {},
          onPaint: () {},
          onText: () {},
          onFilter: () {},
          onBlur: () {},
          onEmoji: () {},
          onStickers: () {},
        ),
      ),
    );

    final textCenter = tester.getCenter(
      find.byKey(const ValueKey('story-editor-tool-text')),
    );
    final closeTop = tester.getTopLeft(
      find.byKey(const ValueKey('story-editor-close')),
    );
    final textTop = tester.getTopLeft(
      find.byKey(const ValueKey('story-editor-tool-text')),
    );
    final stickerCenter = tester.getCenter(
      find.byKey(const ValueKey('story-editor-tool-stickers')),
    );

    expect(textCenter.dx, greaterThan(300));
    expect(textTop.dy, closeTop.dy);
    expect(stickerCenter.dx, textCenter.dx);
    expect(stickerCenter.dy, greaterThan(textCenter.dy));
  });

  testWidgets('vertical actions remain overflow-free on a compact phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _testApp(
        StoryEditorTopSection(
          onClose: () {},
          onMention: () async {},
          onPaint: () {},
          onText: () {},
          onFilter: () {},
          onBlur: () {},
          onEmoji: () {},
          onStickers: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData.dark(),
    home: Scaffold(backgroundColor: Colors.black, body: child),
  );
}
