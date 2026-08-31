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

  testWidgets(
    'prevents duplicate submission while feed preparation is pending',
    (tester) async {
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
      expect(settingsNotifier.prepareCalls, 1);
      expect(tester.widget<AppButton>(confirmButton).onPressed, isNull);
      expect(
        tester
            .widget<AppButton>(find.widgetWithText(AppButton, 'Back'))
            .onPressed,
        isNull,
      );

      await tester.tap(confirmButton);
      await tester.pump();

      expect(saveNotifier.calls, 1);

      settingsNotifier.completePreparation();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('retries only feed setup after the profile is saved', (
    tester,
  ) async {
    final saveNotifier = _SuccessfulOnboardingState();
    final settingsNotifier = _FailingSettings();
    final container = _container(
      saveNotifier,
      settingsNotifier: settingsNotifier,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Confirm');

    expect(saveNotifier.calls, 1);
    expect(settingsNotifier.prepareCalls, 1);
    expect(
      find.text(
        'Your profile is saved, but we couldn’t prepare your feeds. '
        'Check your connection and try again.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(saveNotifier.calls, 1);
    expect(settingsNotifier.prepareCalls, 2);
  });

  testWidgets('saves profile edits made after feed setup fails', (
    tester,
  ) async {
    final saveNotifier = _SuccessfulOnboardingState();
    final settingsNotifier = _FailingSettings();
    final container = _container(
      saveNotifier,
      settingsNotifier: settingsNotifier,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Confirm');

    ScaffoldMessenger.of(
      tester.element(find.byType(OnboardingPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await _tapButton(tester, 'Back');
    await tester.enterText(find.byType(TextFormField).first, 'Updated name');
    await tester.pump();
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Confirm');

    expect(saveNotifier.calls, 2);
    expect(saveNotifier.lastDisplayName, 'Updated name');
    expect(settingsNotifier.prepareCalls, 2);
  });

  testWidgets('saves bio edits made on the final step after feed setup fails', (
    tester,
  ) async {
    final saveNotifier = _SuccessfulOnboardingState();
    final settingsNotifier = _FailingSettings();
    final container = _container(
      saveNotifier,
      settingsNotifier: settingsNotifier,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Confirm');

    await tester.enterText(find.byType(TextFormField), 'Updated biography');
    await tester.pump();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(saveNotifier.calls, 2);
    expect(saveNotifier.lastDescription, 'Updated biography');
    expect(settingsNotifier.prepareCalls, 2);
  });

  testWidgets('saves a final-step bio revert after feed setup fails', (
    tester,
  ) async {
    final saveNotifier = _SuccessfulOnboardingState();
    final settingsNotifier = _FailingSettings();
    final container = _container(
      saveNotifier,
      settingsNotifier: settingsNotifier,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Continue');
    await tester.enterText(find.byType(TextFormField), 'Custom biography');
    await tester.pump();
    await _tapButton(tester, 'Confirm');

    await tester.tap(find.byTooltip('Revert'));
    await tester.pump();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(saveNotifier.calls, 2);
    expect(saveNotifier.lastDescription, 'Imported biography');
    expect(settingsNotifier.prepareCalls, 2);
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
  String? lastDisplayName;
  String? lastDescription;

  @override
  Future<void> build() async {}

  @override
  Future<void> createCustomProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  }) async {
    calls++;
    lastDisplayName = displayName;
    lastDescription = description;
  }
}

class _BlockingSettings extends Settings {
  final _preparationCompleter = Completer<void>();
  int prepareCalls = 0;

  @override
  SettingsState build() => SettingsState(
    activeFeed: Feed(
      type: 'timeline',
      config: makeSavedFeed(type: 'timeline', value: 'following', pinned: true),
    ),
  );

  @override
  Future<void> preparePostOnboardingFeed() {
    prepareCalls++;
    return _preparationCompleter.future;
  }

  void completePreparation() => _preparationCompleter.complete();
}

class _FailingSettings extends Settings {
  int prepareCalls = 0;

  @override
  SettingsState build() => SettingsState(
    activeFeed: Feed(
      type: 'timeline',
      config: makeSavedFeed(type: 'timeline', value: 'following', pinned: true),
    ),
  );

  @override
  Future<void> preparePostOnboardingFeed() async {
    prepareCalls++;
    throw StateError('Feed preparation failed');
  }
}
