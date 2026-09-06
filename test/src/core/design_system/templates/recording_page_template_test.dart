import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/templates/recording_page_template.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(420, 912)]) {
    testWidgets('keeps placeholder at natural size on $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const placeholderKey = ValueKey('placeholder');

      await tester.pumpWidget(
        MaterialApp(
          home: RecordingPageTemplate(
            cameraPreview: const Center(
              child: SizedBox(
                key: placeholderKey,
                width: 200,
                height: 100,
                child: ColoredBox(color: Colors.grey),
              ),
            ),
            isRecording: false,
            elapsedDuration: Duration.zero,
            maxDuration: const Duration(minutes: 1),
            onBack: () {},
            onFlipCamera: null,
            canFlipCamera: false,
            captureMode: CaptureMode.hybrid,
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byKey(placeholderKey));
      final topLeft = box.localToGlobal(Offset.zero);
      final bottomRight = box.localToGlobal(box.size.bottomRight(Offset.zero));
      expect(bottomRight - topLeft, const Offset(200, 100));
      expect(topLeft.dx, greaterThanOrEqualTo(0));
      expect(bottomRight.dx, lessThanOrEqualTo(size.width));
      expect(tester.takeException(), isNull);
    });
  }
}
