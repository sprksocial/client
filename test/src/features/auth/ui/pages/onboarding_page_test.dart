import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/auth/data/models/onboarding_screen_state.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/features/auth/providers/onboarding_notifier.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/auth/ui/pages/onboarding_page.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';

void main() {
  testWidgets(
    'submits imported profile values unchanged and reports save failures',
    (tester) async {
      final saveNotifier = _FailingOnboardingState();
      final container = _container(saveNotifier);
      addTearDown(container.dispose);

      await _pumpPage(tester, container);

      final fields = tester.widgetList<TextFormField>(
        find.byType(TextFormField, skipOffstage: false),
      );
      expect(fields.elementAt(0).controller?.text, 'Alex Rivera');
      expect(fields.elementAt(1).controller?.text, 'Imported biography');

      await _tapButton(tester, 'Continue');
      await _tapButton(tester, 'Continue');
      await _tapButton(tester, 'Continue');
      await _tapButton(tester, 'Confirm');

      expect(saveNotifier.calls, [
        (
          displayName: 'Alex Rivera',
          description: 'Imported biography',
          avatar: null,
        ),
      ]);
      expect(
        find.text(
          'We couldn’t save your profile. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    },
  );

  testWidgets('keeps edits synchronized and restores imported values', (
    tester,
  ) async {
    final container = _container(_FailingOnboardingState());
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');

    final displayNameField = find.byType(TextFormField).first;
    await tester.enterText(displayNameField, 'Changed name');
    await tester.pump();

    expect(
      container.read(onboardingProvider).value?.displayName,
      'Changed name',
    );
    expect(find.byTooltip('Revert'), findsOneWidget);

    await tester.tap(find.byTooltip('Revert'));
    await tester.pump();

    expect(
      tester.widget<TextFormField>(displayNameField).controller?.text,
      'Alex Rivera',
    );
    expect(
      container.read(onboardingProvider).value?.displayName,
      'Alex Rivera',
    );
  });

  testWidgets('prevents duplicate submission while settings sync is pending', (
    tester,
  ) async {
    final saveNotifier = _SuccessfulOnboardingState();
    final settingsNotifier = _BlockingSettings();
    final container = _container(
      saveNotifier,
      settingsNotifier: settingsNotifier,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');

    final confirmButton = find.widgetWithText(AppButton, 'Confirm');
    await tester.tap(confirmButton);
    await tester.pump();

    expect(saveNotifier.calls, 1);
    expect(settingsNotifier.syncCalls, 1);
    expect(tester.widget<AppButton>(confirmButton).onPressed, isNull);

    await tester.tap(confirmButton);
    await tester.pump();

    expect(saveNotifier.calls, 1);

    settingsNotifier.completeSync();
    await tester.pumpAndSettle();
  });
}

ProviderContainer _container(
  OnboardingState saveNotifier, {
  Settings? settingsNotifier,
}) {
  return ProviderContainer.test(
    overrides: [
      onboardingProvider.overrideWith(_FakeOnboardingNotifier.new),
      onboardingStateProvider.overrideWith(() => saveNotifier),
      if (settingsNotifier != null)
        settingsProvider.overrideWith(() => settingsNotifier),
    ],
  );
}

Future<void> _pumpPage(WidgetTester tester, ProviderContainer container) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapButton(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(AppButton, label));
  await tester.pumpAndSettle();
}

class _FakeOnboardingNotifier extends OnboardingNotifier {
  @override
  Future<OnboardingScreenState> build() async {
    final importedProfile = ActorProfileRecord.fromJson({
      r'$type': 'app.bsky.actor.profile',
      'displayName': 'Alex Rivera',
      'description': 'Imported biography',
    });
    return OnboardingScreenState(
      bskyProfileRecord: importedProfile,
      displayName: importedProfile.displayName ?? '',
      description: importedProfile.description ?? '',
      userDid: 'did:plc:viewer',
      isLoading: false,
    );
  }
}

class _FailingOnboardingState extends OnboardingState {
  final List<({String displayName, String description, Object? avatar})> calls =
      [];

  @override
  Future<void> build() async {}

  @override
  Future<void> createCustomProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  }) async {
    calls.add((
      displayName: displayName,
      description: description,
      avatar: avatar as Object?,
    ));
    throw StateError('Profile save failed');
  }
}

class _SuccessfulOnboardingState extends OnboardingState {
  int calls = 0;

  @override
  Future<void> build() async {}

  @override
  Future<void> createCustomProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  }) async {
    calls++;
  }
}

class _BlockingSettings extends Settings {
  final _syncCompleter = Completer<void>();
  int syncCalls = 0;

  @override
  SettingsState build() => SettingsState(
    activeFeed: Feed(
      type: 'timeline',
      config: makeSavedFeed(type: 'timeline', value: 'following', pinned: true),
    ),
  );

  @override
  Future<void> syncPreferencesFromServer() {
    syncCalls++;
    return _syncCompleter.future;
  }

  void completeSync() => _syncCompleter.complete();
}
