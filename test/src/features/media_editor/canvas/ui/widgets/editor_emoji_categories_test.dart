import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/emoji_editor/services/emoji_state_manager.dart';
import 'package:pro_image_editor/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/media_editor/canvas/ui/widgets/editor_emoji_categories.dart';

void main() {
  testWidgets('category tabs select the editor scroll category', (
    tester,
  ) async {
    final tabs = TabController(length: 2, vsync: tester);
    final pages = PageController();
    addTearDown(tabs.dispose);
    addTearDown(pages.dispose);
    Category? selected;
    final state = EmojiViewState(
      const [
        CategoryEmoji(Category.RECENT, []),
        CategoryEmoji(Category.ANIMALS, []),
      ],
      (_, _) {},
      null,
      () {},
      () {},
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EmojiStateManager(
            activeCategory: Category.RECENT,
            setActiveCategory: (category) => selected = category,
            child: EditorEmojiCategories(const Config(), state, tabs, pages),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Animals and nature'));
    await tester.pumpAndSettle();
    expect(selected, Category.ANIMALS);
    expect(tabs.index, 1);
    expect(find.byType(Icon), findsNothing);
  });
}
