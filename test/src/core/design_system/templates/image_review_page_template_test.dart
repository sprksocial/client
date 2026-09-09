import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/templates/image_review_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

void main() {
  late Directory images;
  late String imagePath;

  setUpAll(() {
    images = Directory.systemTemp.createTempSync('photo-review-test-');
    imagePath = '${images.path}/photo.png';
    File(imagePath).writeAsBytesSync(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
      ),
    );
  });
  tearDownAll(() => images.deleteSync(recursive: true));

  Future<void> pumpReview(
    WidgetTester tester,
    Widget child, {
    MediaQueryData? mediaQuery,
  }) async {
    await tester.pumpWidget(
      _TestApp(mediaQuery: mediaQuery, child: const SizedBox()),
    );
    // Start image loading outside fake async before the review requests it.
    await tester.runAsync(() async {
      await precacheImage(
        FileImage(File(imagePath)),
        tester.element(find.byType(SizedBox)),
      );
    });
    await tester.pumpWidget(_TestApp(mediaQuery: mediaQuery, child: child));
  }

  testWidgets('sound row opens picker and selected sound can be removed', (
    tester,
  ) async {
    var addTapped = false;
    var removeTapped = false;
    await pumpReview(tester, _template(onAddSound: () => addTapped = true));
    await tester.ensureVisible(find.text('Add sound'));
    await tester.tap(find.text('Add sound'));
    expect(addTapped, isTrue);

    await pumpReview(
      tester,
      _template(
        selectedSoundTitle: 'Summer Loop',
        selectedSoundSubtitle: 'artist.sprk.so',
        onAddSound: () {},
        onRemoveSound: () => removeTapped = true,
      ),
    );
    expect(find.text('Summer Loop'), findsOneWidget);
    expect(find.text('artist.sprk.so'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Remove'));
    await tester.tap(find.byTooltip('Remove'));
    expect(removeTapped, isTrue);
  });

  testWidgets(
    'each photo opens its editor directly and removes its own index',
    (tester) async {
      final edited = <int>[];
      final removed = <int>[];
      await pumpReview(
        tester,
        _template(
          imagePaths: [imagePath, imagePath],
          onTapEditImage: edited.add,
          onRemoveImage: removed.add,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Edit photo 2'));
      expect(edited, [1]);
      await tester.tap(find.bySemanticsLabel('Edit photo 1'));
      expect(edited, [1, 0]);
      await tester.longPress(find.bySemanticsLabel('Edit photo 2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(removed, [1]);
    },
  );

  testWidgets('removing the last photo disables posting', (tester) async {
    var paths = [imagePath];
    var posts = 0;
    await pumpReview(
      tester,
      StatefulBuilder(
        builder: (context, setState) => _template(
          imagePaths: paths,
          showAddMore: true,
          onPost: () => posts++,
          onRemoveImage: (index) => setState(() => paths = []),
        ),
      ),
    );
    expect(
      tester.widget<AppButton>(find.byType(AppButton)).onPressed,
      isNotNull,
    );
    await tester.longPress(find.bySemanticsLabel('Edit photo 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    expect(posts, 0);
  });

  testWidgets('photo limit prevents adding more photos', (tester) async {
    var adds = 0;
    await pumpReview(
      tester,
      _template(
        imagePaths: [imagePath],
        showAddMore: true,
        canAddMore: false,
        onAddMore: () => adds++,
      ),
    );
    await tester.tap(find.byTooltip('Photo limit reached'));
    expect(adds, 0);
  });

  testWidgets('posting locks media, caption, sound and cross-post controls', (
    tester,
  ) async {
    var actions = 0;
    await pumpReview(
      tester,
      _template(
        imagePaths: [imagePath],
        showAddMore: true,
        isPosting: true,
        onTapEditImage: (_) => actions++,
        onRemoveImage: (_) => actions++,
        onAddMore: () => actions++,
        onAddSound: () => actions++,
        onCrossPostChanged: (_) => actions++,
        onPost: () => actions++,
      ),
    );
    await tester.tap(
      find.bySemanticsLabel('Edit photo 1'),
      warnIfMissed: false,
    );
    await tester.longPress(
      find.bySemanticsLabel('Edit photo 1'),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Add photos'), warnIfMissed: false);
    await tester.ensureVisible(find.text('Add sound'));
    await tester.tap(find.text('Add sound'), warnIfMissed: false);
    await tester.ensureVisible(find.text('Also post to Bluesky'));
    await tester.tap(find.text('Also post to Bluesky'), warnIfMissed: false);
    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(find.text('Remove'), findsNothing);
    expect(actions, 0);
  });

  testWidgets(
    'caption scrolls above keyboard while Post stays in the safe area',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpReview(
        tester,
        _template(imagePaths: [imagePath], descriptionController: controller),
        mediaQuery: const MediaQueryData(
          size: Size(320, 568),
          padding: EdgeInsets.only(top: 44),
          viewPadding: EdgeInsets.only(top: 44, bottom: 34),
          viewInsets: EdgeInsets.only(bottom: 180),
          textScaler: TextScaler.linear(2),
        ),
      );
      final originalCaptionTop = tester.getTopLeft(find.text('Caption')).dy;
      final postBefore = tester.getRect(find.byType(AppButton));
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(
        find.byType(TextField),
        'A caption on a small phone',
      );
      await tester.pump();
      expect(controller.text, 'A caption on a small phone');
      expect(
        tester.getTopLeft(find.text('Caption')).dy,
        lessThan(originalCaptionTop),
      );
      final postAfter = tester.getRect(find.byType(AppButton));
      expect(postAfter, postBefore);
      expect(postAfter.bottom, lessThanOrEqualTo(568 - 180));
      expect(postAfter.top, greaterThan(44));
      expect(find.byType(AppButton).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

ImageReviewPageTemplate _template({
  List<String> imagePaths = const [],
  ValueChanged<int>? onTapEditImage,
  ValueChanged<int>? onRemoveImage,
  bool showAddMore = false,
  bool canAddMore = true,
  VoidCallback? onAddMore,
  bool isPosting = false,
  VoidCallback? onPost,
  TextEditingController? descriptionController,
  String? selectedSoundTitle,
  String? selectedSoundSubtitle,
  VoidCallback? onAddSound,
  VoidCallback? onRemoveSound,
  ValueChanged<bool>? onCrossPostChanged,
}) => ImageReviewPageTemplate(
  title: 'Review',
  onBack: () {},
  imagePaths: imagePaths,
  onTapEditImage: onTapEditImage ?? (_) {},
  onRemoveImage: onRemoveImage ?? (_) {},
  showAddMore: showAddMore,
  canAddMore: canAddMore,
  onAddMore: onAddMore ?? () {},
  descriptionController: descriptionController,
  descriptionMaxChars: 300,
  crossPostValue: false,
  onCrossPostChanged: onCrossPostChanged ?? (_) {},
  postLabel: 'Post',
  onPost: onPost ?? () {},
  isPosting: isPosting,
  selectedSoundTitle: selectedSoundTitle,
  selectedSoundSubtitle: selectedSoundSubtitle,
  onAddSound: onAddSound,
  onRemoveSound: onRemoveSound,
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.mediaQuery});

  final Widget child;
  final MediaQueryData? mediaQuery;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: mediaQuery == null
        ? null
        : (context, child) => MediaQuery(data: mediaQuery!, child: child!),
    home: child,
  );
}
