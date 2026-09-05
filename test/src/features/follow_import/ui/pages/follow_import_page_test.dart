import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/follow_import/providers/follow_import_provider.dart';
import 'package:spark/src/features/follow_import/ui/pages/follow_import_page.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  testWidgets('explains when the current account has no Bluesky profile', (
    tester,
  ) async {
    final container = ProviderContainer.test(
      overrides: [
        followImportBskyProfileProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);

    expect(find.text('No Bluesky profile found'), findsOneWidget);
    expect(
      find.text(
        'Add a Bluesky profile before importing people you follow there.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('imports selected matches and reports completion', (
    tester,
  ) async {
    final controller = _RecordingFollowImportController();
    final container = ProviderContainer.test(
      overrides: [
        followImportBskyProfileProvider.overrideWith(
          (ref) async => ActorProfileRecord.fromJson({
            r'$type': 'app.bsky.actor.profile',
            'displayName': 'Alex',
          }),
        ),
        followImportMatchesProvider.overrideWith((ref) async => _matches),
        followImportControllerProvider.overrideWith(() => controller),
      ],
    );
    addTearDown(container.dispose);

    bool? routeResult;
    await _pumpRoutedPage(
      tester,
      container,
      onResult: (result) => routeResult = result,
    );

    expect(find.text('Alex One'), findsOneWidget);
    expect(find.text('Blair Two'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Follow 2 people'));
    await tester.pumpAndSettle();

    expect(controller.calls, [
      {'did:plc:alex', 'did:plc:blair'},
    ]);
    expect(find.text('You’re following 2 new people'), findsOneWidget);
    expect(
      find.text('Their posts can now appear in your Following feed.'),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(routeResult, isTrue);
  });

  testWidgets('freezes selection while an import is running', (tester) async {
    final controller = _BlockingFollowImportController();
    final container = ProviderContainer.test(
      overrides: [
        followImportBskyProfileProvider.overrideWith(
          (ref) async => ActorProfileRecord.fromJson({
            r'$type': 'app.bsky.actor.profile',
            'displayName': 'Alex',
          }),
        ),
        followImportMatchesProvider.overrideWith((ref) async => _matches),
        followImportControllerProvider.overrideWith(() => controller),
      ],
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    await tester.tap(find.widgetWithText(AppButton, 'Follow 2 people'));
    await controller.started.future;
    await tester.pump();

    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Deselect all'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .map((tile) => tile.onChanged),
      everyElement(isNull),
    );

    controller.complete();
    await tester.pumpAndSettle();
  });
}

Future<void> _pumpPage(WidgetTester tester, ProviderContainer container) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FollowImportPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpRoutedPage(
  WidgetTester tester,
  ProviderContainer container, {
  required ValueChanged<bool?> onResult,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const FollowImportPage()),
              );
              onResult(result);
            },
            child: const Text('Open import'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open import'));
  await tester.pumpAndSettle();
}

class _RecordingFollowImportController extends FollowImportController {
  final List<Set<String>> calls = [];

  @override
  FollowImportSessionState build() => const FollowImportSessionState();

  @override
  Future<bool> importSelected() async {
    final dids = state.remainingSelectedDids;
    calls.add(dids);
    state = state.copyWith(
      importedDids: {...state.importedDids, ...dids},
      isComplete: true,
    );
    return true;
  }
}

class _BlockingFollowImportController extends FollowImportController {
  final started = Completer<void>();
  final _completion = Completer<void>();

  @override
  FollowImportSessionState build() => const FollowImportSessionState();

  @override
  Future<bool> importSelected() async {
    final dids = state.remainingSelectedDids;
    state = state.copyWith(isSubmitting: true);
    started.complete();
    await _completion.future;
    state = state.copyWith(
      importedDids: {...state.importedDids, ...dids},
      isSubmitting: false,
      isComplete: true,
    );
    return true;
  }

  void complete() => _completion.complete();
}

const _matches = [
  ProfileViewDetailed(
    did: 'did:plc:alex',
    handle: 'alex.test',
    displayName: 'Alex One',
  ),
  ProfileViewDetailed(
    did: 'did:plc:blair',
    handle: 'blair.test',
    displayName: 'Blair Two',
  ),
];
