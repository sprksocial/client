import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/templates/image_review_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

void main() {
  group('ImageReviewPageTemplate sound section', () {
    testWidgets('shows add sound action when no sound is selected', (
      tester,
    ) async {
      var addTapped = false;

      await tester.pumpWidget(
        _TestApp(child: _template(onAddSound: () => addTapped = true)),
      );

      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is AppButton && widget.label == 'Add sound',
        ),
      );

      expect(addTapped, isTrue);
    });

    testWidgets('shows selected sound and supports removal', (tester) async {
      var removeTapped = false;

      await tester.pumpWidget(
        _TestApp(
          child: _template(
            selectedSoundTitle: 'Summer Loop',
            selectedSoundSubtitle: 'artist.sprk.so',
            onAddSound: () {},
            onRemoveSound: () => removeTapped = true,
          ),
        ),
      );

      expect(find.text('Summer Loop'), findsOneWidget);
      expect(find.text('artist.sprk.so'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove'));

      expect(removeTapped, isTrue);
    });
  });
}

ImageReviewPageTemplate _template({
  String? selectedSoundTitle,
  String? selectedSoundSubtitle,
  VoidCallback? onAddSound,
  VoidCallback? onRemoveSound,
}) {
  return ImageReviewPageTemplate(
    title: 'Review',
    onBack: () {},
    imagePaths: const [],
    currentPage: 0,
    onPageChanged: (_) {},
    onTapEditImage: (_) {},
    onAltEdit: (_) {},
    onRemoveImage: (_) {},
    showAddMore: false,
    canAddMore: false,
    imagesCount: 0,
    maxImages: 12,
    onAddMore: () {},
    descriptionMaxChars: 300,
    crossPostValue: false,
    onCrossPostChanged: (_) {},
    postLabel: 'Post',
    onPost: () {},
    isPosting: false,
    selectedSoundTitle: selectedSoundTitle,
    selectedSoundSubtitle: selectedSoundSubtitle,
    onAddSound: onAddSound,
    onRemoveSound: onRemoveSound,
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
