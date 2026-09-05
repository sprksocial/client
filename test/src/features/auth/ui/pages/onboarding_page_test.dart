import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/auth/data/models/onboarding_screen_state.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/features/auth/providers/onboarding_notifier.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/auth/ui/pages/onboarding_page.dart';
import 'package:spark/src/features/follow_import/providers/follow_import_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

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

      await _advanceToReview(tester);
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

  testWidgets('shows matched Bluesky follows as a numbered onboarding step', (
    tester,
  ) async {
    final container = _container(
      _SuccessfulOnboardingState(),
      followMatches: _followMatches,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    for (var index = 0; index < 4; index++) {
      await _tapButton(tester, 'Continue');
    }

    expect(find.text('Step 5 of 6'), findsOneWidget);
    expect(find.text('Find people you know'), findsOneWidget);
    expect(find.text('Alex One'), findsOneWidget);
    expect(find.text('Blair Two'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Follow 2 people'), findsOneWidget);

    await _tapButton(tester, 'Back');
    expect(find.text('Step 4 of 6'), findsOneWidget);
    expect(find.text('Add a bio'), findsOneWidget);
    await _tapButton(tester, 'Continue');

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.widgetWithText(AppButton, 'Follow 1 person'), findsOneWidget);

    await _tapButton(tester, 'Follow 1 person');

    expect(find.text('Step 6 of 6'), findsOneWidget);
    expect(find.text('Review and confirm'), findsOneWidget);
    expect(
      find.text('You’ll also follow 1 person from Bluesky.'),
      findsOneWidget,
    );
  });

  testWidgets('skips the import step when no Spark matches exist', (
    tester,
  ) async {
    final container = _container(_SuccessfulOnboardingState());
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    await _advanceToReview(tester);

    expect(find.text('Step 5 of 5'), findsOneWidget);
    expect(find.text('Review and confirm'), findsOneWidget);
  });

  testWidgets('can skip follow import and reconsider it after going back', (
    tester,
  ) async {
    final container = _container(
      _SuccessfulOnboardingState(),
      followMatches: _followMatches,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    for (var index = 0; index < 4; index++) {
      await _tapButton(tester, 'Continue');
    }
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('Review and confirm'), findsOneWidget);
    expect(find.text('Step 5 of 5'), findsOneWidget);
    expect(find.textContaining('from Bluesky'), findsNothing);

    await _tapButton(tester, 'Back');
    expect(find.text('Step 4 of 6'), findsOneWidget);
    expect(find.text('Add a bio'), findsOneWidget);
    await _tapButton(tester, 'Continue');
    expect(find.text('Step 5 of 6'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Follow 2 people'), findsOneWidget);
  });

  testWidgets('can skip while follow discovery is still running', (
    tester,
  ) async {
    final discovery = Completer<List<ProfileViewDetailed>>();
    addTearDown(() {
      if (!discovery.isCompleted) discovery.complete(const []);
    });
    final container = _container(
      _SuccessfulOnboardingState(),
      followMatchesFuture: discovery.future,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container, settle: false);
    for (var index = 0; index < 4; index++) {
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(find.text('Finding people you know on Spark…'), findsOneWidget);
    expect(find.text('Step 5 of 6'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
    await tester.tap(find.text('Skip for now'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Review and confirm'), findsOneWidget);
    expect(find.text('Step 5 of 5'), findsOneWidget);
  });

  testWidgets('keeps discovery errors visible and retries in place', (
    tester,
  ) async {
    var attempts = 0;
    final container = _container(
      _SuccessfulOnboardingState(),
      followMatchesLoader: () async {
        attempts++;
        if (attempts == 1) throw StateError('Discovery failed');
        return _followMatches;
      },
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    for (var index = 0; index < 4; index++) {
      await _tapButton(tester, 'Continue');
    }

    expect(find.text('Step 5 of 6'), findsOneWidget);
    expect(find.text('We couldn’t find your matches'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);

    await _tapButton(tester, 'Retry');

    expect(attempts, 2);
    expect(find.text('Alex One'), findsOneWidget);
    expect(find.text('Blair Two'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Follow 2 people'), findsOneWidget);
  });

  testWidgets('retries only follow imports that did not complete', (
    tester,
  ) async {
    final saveNotifier = _SuccessfulOnboardingState();
    final importNotifier = _PartiallyFailingImportController();
    final settingsNotifier = _BlockingSettings();
    final container = _container(
      saveNotifier,
      followImportNotifier: importNotifier,
      settingsNotifier: settingsNotifier,
      followMatches: _followMatches,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    for (var index = 0; index < 4; index++) {
      await _tapButton(tester, 'Continue');
    }
    await _tapButton(tester, 'Follow 2 people');
    await _tapButton(tester, 'Confirm');

    expect(saveNotifier.calls, 1);
    expect(importNotifier.importCalls, [
      {'did:plc:alex', 'did:plc:blair'},
    ]);
    expect(settingsNotifier.prepareCalls, 0);
    expect(
      find.text(
        'Your profile is saved, but we couldn’t follow everyone you selected. '
        'Confirm to retry the remaining people, or continue without them.',
      ),
      findsOneWidget,
    );

    ScaffoldMessenger.of(
      tester.element(find.byType(OnboardingPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Confirm'));
    await tester.pump();

    expect(saveNotifier.calls, 1);
    expect(importNotifier.importCalls, [
      {'did:plc:alex', 'did:plc:blair'},
      {'did:plc:blair'},
    ]);
    expect(settingsNotifier.prepareCalls, 1);

    settingsNotifier.completePreparation();
    await tester.pumpAndSettle();
  });

  testWidgets('can continue without follows when import fails before a write', (
    tester,
  ) async {
    final saveNotifier = _SuccessfulOnboardingState();
    final importNotifier = _FailingImportController();
    final settingsNotifier = _BlockingSettings();
    final container = _container(
      saveNotifier,
      followImportNotifier: importNotifier,
      settingsNotifier: settingsNotifier,
      followMatches: _followMatches,
    );
    addTearDown(container.dispose);

    await _pumpPage(tester, container);
    for (var index = 0; index < 4; index++) {
      await _tapButton(tester, 'Continue');
    }
    await _tapButton(tester, 'Follow 2 people');
    await _tapButton(tester, 'Confirm');

    expect(saveNotifier.calls, 1);
    expect(importNotifier.importCalls, 1);
    expect(settingsNotifier.prepareCalls, 0);
    expect(
      find.text(
        'Your profile is saved, but we couldn’t follow everyone you selected. '
        'Confirm to retry the remaining people, or continue without them.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue without'));
    await tester.pump();

    expect(importNotifier.importCalls, 1);
    expect(settingsNotifier.prepareCalls, 1);

    settingsNotifier.completePreparation();
    await tester.pumpAndSettle();
  });

  testWidgets(
    're-enables failed follow imports after continuing without them',
    (tester) async {
      final saveNotifier = _SuccessfulOnboardingState();
      final importNotifier = _PartiallyFailingImportController();
      final settingsNotifier = _FailingSettings();
      final container = _container(
        saveNotifier,
        followImportNotifier: importNotifier,
        settingsNotifier: settingsNotifier,
        followMatches: _followMatches,
      );
      addTearDown(container.dispose);

      await _pumpPage(tester, container);
      for (var index = 0; index < 4; index++) {
        await _tapButton(tester, 'Continue');
      }
      await _tapButton(tester, 'Follow 2 people');
      await _tapButton(tester, 'Confirm');
      await tester.tap(find.text('Continue without'));
      await tester.pumpAndSettle();

      expect(settingsNotifier.prepareCalls, 1);

      ScaffoldMessenger.of(
        tester.element(find.byType(OnboardingPage)),
      ).hideCurrentSnackBar();
      await tester.pumpAndSettle();
      await _tapButton(tester, 'Back');
      expect(find.text('Alex One'), findsNothing);
      expect(find.text('Blair Two'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Follow 1 person'), findsOneWidget);
      await _tapButton(tester, 'Follow 1 person');
      await _tapButton(tester, 'Confirm');

      expect(saveNotifier.calls, 1);
      expect(importNotifier.importCalls, [
        {'did:plc:alex', 'did:plc:blair'},
        {'did:plc:blair'},
      ]);
      expect(settingsNotifier.prepareCalls, 2);
    },
  );

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
      await _advanceToReview(tester);

      final confirmButton = find.widgetWithText(AppButton, 'Confirm');
      await tester.tap(confirmButton);
      await tester.pump();

      expect(saveNotifier.calls, 1);
      expect(settingsNotifier.prepareCalls, 1);
      expect(find.byType(AppLeadingButton), findsNothing);
      expect(
        tester.widget<PopScope<void>>(find.byType(PopScope<void>)).canPop,
        isFalse,
      );
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
    await _advanceToReview(tester);
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
    await _advanceToReview(tester);
    await _tapButton(tester, 'Confirm');

    ScaffoldMessenger.of(
      tester.element(find.byType(OnboardingPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await _tapButton(tester, 'Back');
    await _tapButton(tester, 'Back');
    await tester.enterText(find.byType(TextFormField).first, 'Updated name');
    await tester.pump();
    await _tapButton(tester, 'Continue');
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
    await _advanceToReview(tester);
    await _tapButton(tester, 'Confirm');

    ScaffoldMessenger.of(
      tester.element(find.byType(OnboardingPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await _tapButton(tester, 'Back');
    await tester.enterText(find.byType(TextFormField), 'Updated biography');
    await tester.pump();
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Confirm');

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
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Confirm');

    ScaffoldMessenger.of(
      tester.element(find.byType(OnboardingPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await _tapButton(tester, 'Back');
    await tester.tap(find.byTooltip('Revert'));
    await tester.pump();
    await _tapButton(tester, 'Continue');
    await _tapButton(tester, 'Confirm');

    expect(saveNotifier.calls, 2);
    expect(saveNotifier.lastDescription, 'Imported biography');
    expect(settingsNotifier.prepareCalls, 2);
  });
}

ProviderContainer _container(
  OnboardingState saveNotifier, {
  FollowImportController? followImportNotifier,
  Settings? settingsNotifier,
  List<ProfileViewDetailed> followMatches = const [],
  Future<List<ProfileViewDetailed>>? followMatchesFuture,
  Future<List<ProfileViewDetailed>> Function()? followMatchesLoader,
}) {
  return ProviderContainer.test(
    overrides: [
      onboardingProvider.overrideWith(_FakeOnboardingNotifier.new),
      followImportMatchesProvider.overrideWith(
        (ref) =>
            followMatchesLoader?.call() ??
            followMatchesFuture ??
            Future.value(followMatches),
      ),
      onboardingStateProvider.overrideWith(() => saveNotifier),
      if (followImportNotifier != null)
        followImportControllerProvider.overrideWith(() => followImportNotifier),
      if (settingsNotifier != null)
        settingsProvider.overrideWith(() => settingsNotifier),
    ],
  );
}

Future<void> _pumpPage(
  WidgetTester tester,
  ProviderContainer container, {
  bool settle = true,
}) async {
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
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
}

Future<void> _tapButton(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(AppButton, label));
  await tester.pumpAndSettle();
}

Future<void> _advanceToReview(WidgetTester tester) async {
  for (var index = 0; index < 4; index++) {
    await _tapButton(tester, 'Continue');
  }
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

class _PartiallyFailingImportController extends FollowImportController {
  final List<Set<String>> importCalls = [];

  @override
  FollowImportSessionState build() => const FollowImportSessionState();

  @override
  Future<bool> importSelected() async {
    final requested = state.remainingSelectedDids;
    importCalls.add(requested);
    if (importCalls.length == 1) {
      state = state.copyWith(
        importedDids: {...state.importedDids, 'did:plc:alex'},
        hasPartialFailure: true,
      );
      return false;
    }
    state = state.copyWith(
      importedDids: {...state.importedDids, ...requested},
      isComplete: true,
    );
    return true;
  }
}

class _FailingImportController extends FollowImportController {
  int importCalls = 0;

  @override
  FollowImportSessionState build() => const FollowImportSessionState();

  @override
  Future<bool> importSelected() async {
    importCalls++;
    state = state.copyWith(hasPartialFailure: true);
    return false;
  }
}

const _followMatches = [
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
