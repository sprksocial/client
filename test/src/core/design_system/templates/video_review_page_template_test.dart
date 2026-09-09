import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/templates/video_review_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

void main() {
  for (final aspectRatio in [9 / 16, 16 / 9]) {
    testWidgets('bounds the full $aspectRatio video preview on a small phone', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _TestApp(child: _template(aspectRatio: aspectRatio)),
      );

      final preview = tester.getRect(
        find.byKey(const ValueKey('video-preview')),
      );
      expect(preview.width / preview.height, closeTo(aspectRatio, 0.01));
      expect(preview.height, lessThanOrEqualTo(300));
      expect(preview.center.dx, closeTo(160, 0.01));
      if (aspectRatio < 1) {
        expect(preview.height, greaterThanOrEqualTo(196));
      } else {
        expect(preview.width, closeTo(248, 0.01));
      }
      expect(
        tester.getTopLeft(find.text('Caption')).dy - preview.bottom,
        closeTo(28, 0.01),
      );
      expect(preview.left, greaterThanOrEqualTo(0));
      expect(preview.right, lessThanOrEqualTo(320));
      expect(find.byType(AppButton).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('failed upload keeps retry and disabled Post visible', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      _TestApp(
        child: _template(
          onPost: null,
          uploadStatusLabel: 'Upload failed',
          hasUploadError: true,
          onUploadRetry: () => retries++,
        ),
      ),
    );
    expect(find.text('Upload failed').hitTestable(), findsOneWidget);
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets(
    'processing has indeterminate progress without a fake percentage',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: _template(
            uploadStatusLabel: 'Processing video',
            uploadProgress: 0.75,
            uploadIndeterminate: true,
          ),
        ),
      );
      expect(find.text('Processing video').hitTestable(), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        isNull,
      );
    },
  );

  testWidgets('upload status and Post fit with a keyboard and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _TestApp(
        mediaQuery: const MediaQueryData(
          size: Size(320, 568),
          padding: EdgeInsets.only(top: 44),
          viewPadding: EdgeInsets.only(top: 44, bottom: 34),
          viewInsets: EdgeInsets.only(bottom: 180),
          textScaler: TextScaler.linear(2),
        ),
        child: _template(
          uploadStatusLabel: 'Uploading video',
          uploadProgress: 0.4,
        ),
      ),
    );
    expect(find.text('Uploading video').hitTestable(), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.byType(AppButton).hitTestable(), findsOneWidget);
    final post = tester.getRect(find.byType(AppButton));
    expect(post.bottom, lessThanOrEqualTo(568 - 180));
    expect(post.top, greaterThan(44));
    expect(tester.takeException(), isNull);
  });
}

VideoReviewPageTemplate _template({
  double aspectRatio = 9 / 16,
  VoidCallback? onPost = _noop,
  String? uploadStatusLabel,
  double? uploadProgress,
  bool uploadIndeterminate = false,
  bool hasUploadError = false,
  VoidCallback? onUploadRetry,
}) => VideoReviewPageTemplate(
  title: 'Review',
  onBack: () {},
  videoPreview: const SizedBox.expand(key: ValueKey('video-preview')),
  aspectRatio: aspectRatio,
  descriptionMaxChars: 300,
  crossPostValue: false,
  onCrossPostChanged: (_) {},
  postLabel: 'Post',
  onPost: onPost,
  isPosting: false,
  uploadStatusLabel: uploadStatusLabel,
  uploadProgress: uploadProgress,
  uploadIndeterminate: uploadIndeterminate,
  hasUploadError: hasUploadError,
  onUploadRetry: onUploadRetry,
);

void _noop() {}

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
