import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/templates/profile_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';

void main() {
  group('KnownFollowersSummary', () {
    testWidgets('hides when known followers are null', (tester) async {
      await tester.pumpWidget(
        _TestApp(child: KnownFollowersSummary(knownFollowers: null)),
      );

      expect(find.textContaining('Followed by'), findsNothing);
    });

    testWidgets('hides when count is zero', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: KnownFollowersSummary(
            knownFollowers: const KnownFollowers(count: 0, followers: []),
          ),
        ),
      );

      expect(find.textContaining('Followed by'), findsNothing);
    });

    testWidgets('hides when follower list is empty', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: KnownFollowersSummary(
            knownFollowers: const KnownFollowers(count: 3, followers: []),
          ),
        ),
      );

      expect(find.textContaining('Followed by'), findsNothing);
    });

    testWidgets('shows one known follower', (tester) async {
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
          ),
        ),
      );

      expect(find.text('Followed by Alice'), findsOneWidget);
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

    testWidgets('calls onTap when tapped', (tester) async {
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

      await tester.tap(find.text('Followed by Alice'));

      expect(tapped, isTrue);
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
