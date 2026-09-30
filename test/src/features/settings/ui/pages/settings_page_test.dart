import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/l10n/app_localization_delegates.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/settings/ui/pages/settings_page.dart';

void main() {
  testWidgets('groups moderation controls under a dedicated destination', (
    tester,
  ) async {
    await _pumpSettingsPage(tester);

    expect(find.text('Moderation'), findsOneWidget);
    expect(find.text('Show adult content'), findsNothing);
    expect(find.text('Labelers'), findsNothing);
  });

  testWidgets('offers Bluesky follow import as a persistent settings entry', (
    tester,
  ) async {
    await _pumpSettingsPage(tester);

    expect(find.byKey(const Key('settings-follow-import')), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(find.byKey(const Key('settings-follow-import')))
          .subtitle,
      isNull,
    );
  });

  group('account management', () {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    late _FakeAuthRepository authRepository;
    late List<MethodCall> launches;
    var launchSucceeds = true;

    setUp(() {
      authRepository = _FakeAuthRepository();
      launches = [];
      launchSucceeds = true;
      GetIt.I.registerSingleton<AuthRepository>(authRepository);
      GetIt.I.registerSingleton<LogService>(_TestLogService());
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            launches.add(call);
            return launchSucceeds;
          });
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await GetIt.I.reset();
    });

    testWidgets('opens the account management URL resolved by auth', (
      tester,
    ) async {
      await _pumpSettingsPage(tester);

      expect(find.text('Manage or delete your account'), findsOneWidget);
      await tester.tap(find.text('Manage Account'));
      await tester.pumpAndSettle();

      expect(launches, hasLength(1));
      expect(launches.single.method, 'launch');
      final arguments = launches.single.arguments as Map<Object?, Object?>;
      final uri = Uri.parse(arguments['url']! as String);
      expect(uri.origin, 'https://auth.example.com');
      expect(uri.pathSegments, ['account', 'u', 'did:plc:test', 'manage']);
      expect(arguments['useSafariVC'], isTrue);
    });

    testWidgets('shows an error when account discovery fails', (tester) async {
      authRepository.resolve = () =>
          Future.error(StateError('Discovery failed'));
      await _pumpSettingsPage(tester);
      await tester.tap(find.text('Manage Account'));
      await tester.pumpAndSettle();

      expect(launches, isEmpty);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsPage)),
      );
      expect(find.text(l10n.errorUnableToOpenLink), findsOneWidget);
    });

    testWidgets('disables repeated taps while resolving the account server', (
      tester,
    ) async {
      final pending = Completer<Uri>();
      authRepository.resolve = () => pending.future;
      await _pumpSettingsPage(tester);
      await tester.tap(find.text('Manage Account'));
      await tester.pump();
      await tester.tap(find.text('Manage Account'));
      expect(authRepository.resolutionCalls, 1);
      expect(launches, isEmpty);
      pending.complete(Uri.parse('https://auth.example.com/account'));
      await tester.pumpAndSettle();
      expect(launches, hasLength(1));
    });

    testWidgets('does not open the browser after settings is disposed', (
      tester,
    ) async {
      final pending = Completer<Uri>();
      authRepository.resolve = () => pending.future;
      await _pumpSettingsPage(tester);
      await tester.tap(find.text('Manage Account'));
      await tester.pumpWidget(const SizedBox.shrink());
      pending.complete(Uri.parse('https://auth.example.com/account'));
      await tester.pumpAndSettle();
      expect(launches, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows an error when the browser cannot open', (tester) async {
      launchSucceeds = false;
      await _pumpSettingsPage(tester);
      await tester.tap(find.text('Manage Account'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsPage)),
      );
      expect(find.text(l10n.errorUnableToOpenLink), findsOneWidget);
    });
  });
}

Future<void> _pumpSettingsPage(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAuthRepository implements AuthRepository {
  int resolutionCalls = 0;
  Future<Uri> Function() resolve = () async =>
      Uri.parse('https://auth.example.com/account/u/did%3Aplc%3Atest/manage');

  @override
  Future<Uri> getAccountManagementUri() {
    resolutionCalls++;
    return resolve();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestLogService extends LogService {
  @override
  SparkLogger getLogger(String name) => SparkLogger(outputs: []);
}
