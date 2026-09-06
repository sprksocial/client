import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/toggle_button.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_avatar.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_card.dart';
import 'package:spark/src/core/design_system/templates/info_bar_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderated_content.dart';

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

  testWidgets('avatar moderation leaves the add-story action outside', (
    tester,
  ) async {
    var addRequests = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: _TestApp(
          child: ProfileAvatar(
            avatarUrl: null,
            displayName: 'Alice',
            showAddButton: true,
            onAddTap: () => addRequests += 1,
            avatarBuilder: (avatar) => ModeratedProfileAvatar(
              labels: const [],
              subjectDid: 'did:plc:alice',
              child: avatar,
            ),
          ),
        ),
      ),
    );

    final addAction = find.byWidgetPredicate(
      (widget) => widget is AppIcon && widget.icon == AppIconData.add,
    );
    expect(find.byType(ModeratedProfileAvatar), findsOneWidget);
    expect(
      find.ancestor(
        of: addAction,
        matching: find.byType(ModeratedProfileAvatar),
      ),
      findsNothing,
    );

    await tester.tap(addAction);
    await tester.pump();
    expect(addRequests, 1);
  });

  testWidgets('info bar forwards its avatar builder to the image seam', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: InfoBarTemplate(
          displayName: 'Alice',
          handle: 'alice.sprk.so',
          avatarBuilder: (avatar) => KeyedSubtree(
            key: const Key('moderated-info-bar-avatar'),
            child: avatar,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('moderated-info-bar-avatar')), findsOneWidget);
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
