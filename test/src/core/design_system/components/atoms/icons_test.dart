import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';

void main() {
  testWidgets('symbols load and render from the shared asset package', (
    tester,
  ) async {
    for (final icon in AppIconData.values) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: AppIcon(icon)),
        ),
      );
      // Decode each actual SVG as well as exercising its packaged asset path.
      await tester.runAsync(() async {
        final svg = await rootBundle.loadString(
          'packages/assets/${icon.assetPath}',
        );
        final data = await vg.loadPicture(SvgStringLoader(svg), null);
        expect(data.size.isEmpty, isFalse, reason: icon.name);
        data.picture.dispose();
      });
      await tester.pump();
      expect(tester.takeException(), isNull, reason: icon.name);
    }
  });

  testWidgets('inherits icon size, tint and opacity with a square footprint', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: IconTheme(
          data: IconThemeData(size: 40, color: Colors.red, opacity: 0.5),
          child: Center(child: AppIcon(AppIconData.chevronRight)),
        ),
      ),
    );
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(tester.getSize(find.byType(AppIcon)), const Size.square(40));
    expect(
      svg.colorFilter,
      ColorFilter.mode(Colors.red.withValues(alpha: 0.5), BlendMode.srcIn),
    );
  });

  testWidgets('keeps the glyph size inside a larger constrained slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox.square(
            dimension: 48,
            child: AppIcon(AppIconData.warning, size: 24),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AppIcon)), const Size.square(48));
    expect(tester.getSize(find.byType(SvgPicture)), const Size.square(24));
  });

  testWidgets(
    'explicit properties override theme and expose a semantic label',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: IconTheme(
            data: IconThemeData(size: 40, color: Colors.red),
            child: Center(
              child: AppIcon(
                AppIconData.warning,
                size: 18,
                color: Colors.blue,
                semanticLabel: 'Warning',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AppIcon)), const Size.square(18));
      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
        const ColorFilter.mode(Color(0xFF2196F3), BlendMode.srcIn),
      );
      expect(find.bySemanticsLabel('Warning'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets('legacy factories keep native asset colors without a tint', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: IconTheme(
          data: const IconThemeData(color: Colors.red, size: 40),
          child: Center(child: AppIcons.verified()),
        ),
      ),
    );
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.colorFilter, isNull);
    expect(svg.width, 24);
    expect(svg.height, 24);
  });
}
