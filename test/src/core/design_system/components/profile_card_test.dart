import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/toggle_button.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_card.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

void main() {
  testWidgets('reports follow and unfollow through one state-change intent', (
    tester,
  ) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      _TestApp(
        child: ProfileCard(
          imageUrl: '',
          userName: 'Alice',
          userHandle: '@alice',
          isFollowing: false,
          onFollowingChanged: changes.add,
        ),
      ),
    );

    await tester.tap(find.byType(ToggleButton));
    await tester.pump();
    expect(changes, [true]);

    await tester.pumpWidget(
      _TestApp(
        child: ProfileCard(
          imageUrl: '',
          userName: 'Alice',
          userHandle: '@alice',
          isFollowing: true,
          onFollowingChanged: changes.add,
        ),
      ),
    );

    await tester.tap(find.byType(ToggleButton));
    await tester.pump();
    expect(changes, [true, false]);
  });

  testWidgets('does not require a no-op callback when actions are hidden', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: ProfileCard(
          imageUrl: '',
          userName: 'Alice',
          userHandle: '@alice',
          isFollowing: false,
          showFollowButton: false,
        ),
      ),
    );

    expect(find.text('Follow'), findsNothing);
    expect(find.text('Unfollow'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }
}
