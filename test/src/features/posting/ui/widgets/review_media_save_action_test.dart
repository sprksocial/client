import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/templates/post_review_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/media/media_gallery_service.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/posting/ui/widgets/review_media_save_action.dart';

void main() {
  late _Gallery gallery;

  setUp(() {
    gallery = _Gallery();
    GetIt.I
      ..registerSingleton<MediaGalleryService>(gallery)
      ..registerSingleton<LogService>(LogService());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('prevents duplicate saves and locks controls until completion', (
    tester,
  ) async {
    var edits = 0;
    var posts = 0;
    await tester.pumpWidget(
      _app(
        save: (gallery) => gallery.saveImages(['first.jpg', 'second.jpg']),
        onEdit: () => edits++,
        onPost: () => posts++,
      ),
    );

    final saveButton = find.byKey(const ValueKey('save-media-button'));
    await tester.tap(saveButton);
    // A second tap before rebuilding must not start another write.
    await tester.tap(saveButton);
    await tester.pump();

    expect(gallery.images, [
      ['first.jpg', 'second.jpg'],
    ]);
    expect(tester.widget<IconButton>(saveButton).onPressed, isNull);
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
    await tester.tap(find.text('Edit'), warnIfMissed: false);
    expect(edits, 0);
    expect(posts, 0);

    gallery.pending.complete();
    await tester.pumpAndSettle();

    expect(find.text('Saved to Photos'), findsOneWidget);
    expect(tester.widget<IconButton>(saveButton).onPressed, isNotNull);
    await tester.tap(find.text('Edit'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppButton));
    expect(edits, 1);
    expect(posts, 1);
  });

  for (final (name, error, message) in [
    (
      'permission denial',
      const MediaGalleryPermissionDeniedException(),
      'Allow Spark to access Photos in your device settings, then try again.',
    ),
    (
      'save failure',
      StateError('Storage unavailable'),
      'Could not save to Photos. Please try again.',
    ),
  ]) {
    testWidgets('$name shows feedback and permits retry', (tester) async {
      await tester.pumpWidget(
        _app(save: (gallery) => gallery.saveVideo('review.mp4')),
      );
      final saveButton = find.byKey(const ValueKey('save-media-button'));
      await tester.tap(saveButton);
      await tester.pump();
      gallery.pending.completeError(error);
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
      expect(find.text('Saved to Photos'), findsNothing);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNotNull,
      );

      gallery.pending = Completer<void>();
      await tester.tap(saveButton);
      expect(gallery.videos, ['review.mp4', 'review.mp4']);
      gallery.pending.complete();
      await tester.pumpAndSettle();
      expect(find.text('Saved to Photos'), findsOneWidget);
      expect(find.text(message), findsNothing);
    });
  }

  testWidgets('page eligibility guard blocks saving until enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(canSave: false, save: (gallery) => gallery.saveVideo('review.mp4')),
    );
    final saveButton = find.byKey(const ValueKey('save-media-button'));
    await tester.tap(saveButton);
    await tester.pump();
    expect(gallery.videos, isEmpty);
    expect(find.byType(SnackBar), findsNothing);

    await tester.pumpWidget(
      _app(save: (gallery) => gallery.saveVideo('review.mp4')),
    );
    await tester.tap(saveButton);
    expect(gallery.videos, ['review.mp4']);
    gallery.pending.complete();
    await tester.pumpAndSettle();
  });

  for (final fails in [false, true]) {
    testWidgets('ignores completion after disposal (failure: $fails)', (
      tester,
    ) async {
      final showReview = ValueNotifier(true);
      addTearDown(showReview.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ValueListenableBuilder<bool>(
            valueListenable: showReview,
            builder: (context, show, _) => show
                ? _review(save: (gallery) => gallery.saveVideo('review.mp4'))
                : const Scaffold(body: Text('Destination')),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('save-media-button')));
      await tester.pump();
      showReview.value = false;
      await tester.pump();

      if (fails) {
        gallery.pending.completeError(StateError('Late failure'));
      } else {
        gallery.pending.complete();
      }
      await tester.pumpAndSettle();

      expect(find.text('Destination'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _app({
  required Future<void> Function(MediaGalleryService) save,
  bool canSave = true,
  VoidCallback? onEdit,
  VoidCallback? onPost,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: _review(save: save, canSave: canSave, onEdit: onEdit, onPost: onPost),
);

Widget _review({
  required Future<void> Function(MediaGalleryService) save,
  bool canSave = true,
  VoidCallback? onEdit,
  VoidCallback? onPost,
}) => ReviewMediaSaveAction(
  save: save,
  canSave: canSave,
  builder: (context, onSave, isSaving) => PostReviewPageTemplate(
    title: 'Review',
    onBack: () {},
    media: TextButton(onPressed: onEdit ?? () {}, child: const Text('Edit')),
    caption: const SizedBox.shrink(),
    options: const [],
    postLabel: 'Post',
    onPost: onPost ?? () {},
    isPosting: false,
    onSave: onSave,
    isSaving: isSaving,
  ),
);

class _Gallery implements MediaGalleryService {
  late Completer<void> pending = Completer<void>();
  final List<List<String>> images = [];
  final List<String> videos = [];

  @override
  Future<void> saveImages(List<String> imagePaths) {
    images.add(List.of(imagePaths));
    return pending.future;
  }

  @override
  Future<void> saveVideo(String videoPath) {
    videos.add(videoPath);
    return pending.future;
  }
}
