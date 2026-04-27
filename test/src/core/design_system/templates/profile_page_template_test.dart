import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/templates/profile_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';

void main() {
  group('KnownFollowersSummary', () {
    testWidgets('hides when there is no visible known follower', (
      tester,
    ) async {
      final cases = <KnownFollowers?>[
        null,
        const KnownFollowers(count: 0, followers: []),
        const KnownFollowers(count: 3, followers: []),
      ];

      for (final knownFollowers in cases) {
        await tester.pumpWidget(
          _TestApp(
            child: KnownFollowersSummary(knownFollowers: knownFollowers),
          ),
        );

        expect(find.textContaining('Followed by'), findsNothing);
      }
    });

    testWidgets('shows one known follower and handles taps', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _TestApp(
          child: KnownFollowersSummary(
            knownFollowers: const KnownFollowers(
              count: 1,
              followers: [
                ProfileViewBasic(
                  did: 'did:plc:alice',
                  handle: 'alice.sprk.so',
                  displayName: 'Alice',
                ),
              ],
            ),
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Followed by Alice'), findsOneWidget);
      await tester.tap(find.text('Followed by Alice'));

      expect(tapped, isTrue);
    });

    testWidgets('uses total count for others copy', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: KnownFollowersSummary(
            knownFollowers: const KnownFollowers(
              count: 5,
              followers: [
                ProfileViewBasic(
                  did: 'did:plc:alice',
                  handle: 'alice.sprk.so',
                  displayName: 'Alice',
                ),
                ProfileViewBasic(
                  did: 'did:plc:bob',
                  handle: 'bob.sprk.so',
                  displayName: 'Bob',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Followed by Alice, Bob, and 3 others'), findsOneWidget);
    });
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
