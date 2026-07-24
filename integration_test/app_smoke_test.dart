import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/main.dart' as app;
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/notifications/push_notification_service.dart';
import 'package:spark/src/core/storage/cache/download_manager_interface.dart';
import 'package:spark/src/core/storage/storage.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/auth/providers/oauth_browser_launcher.dart';
import 'package:spark/src/features/auth/ui/pages/login_page.dart';
import 'package:spark/src/features/auth/ui/pages/register_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('isolated launch supports auth routing and OAuth callback', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final oauthLauncher = _FakeOAuthBrowserLauncher();
    final providerContainer = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        oauthBrowserLauncherProvider.overrideWithValue(oauthLauncher),
      ],
    );
    addTearDown(providerContainer.dispose);
    var downloadInitializations = 0;
    var pushInitializations = 0;

    await app.runSparkApp(
      preferencesStorage: _InMemoryStorage(),
      secureStorage: _InMemoryStorage(),
      providerContainer: providerContainer,
      initializeDownloadManager: () async {
        downloadInitializations++;
        return _FakeDownloadManager();
      },
      initializePushNotifications: () async {
        pushInitializations++;
        return _initializeFakePushNotifications();
      },
    );
    await _pumpUntilVisible(tester, find.byType(RegisterPage));

    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.byKey(RegisterPage.haveAccountButtonKey));
    await _pumpUntilVisible(tester, find.byType(LoginPage));

    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.byKey(LoginPage.backButtonKey));
    await _pumpUntilVisible(tester, find.byType(RegisterPage));
    await tester.pumpAndSettle();

    final getStartedButton = find.byKey(RegisterPage.getStartedButtonKey);
    await tester.ensureVisible(getStartedButton);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();

    expect(authRepository.completedCallbacks, [
      'sprk://oauth-callback?code=isolated-code',
    ]);
    expect(oauthLauncher.requestedUrls, ['https://auth.example/register']);
    expect(downloadInitializations, 1);
    expect(pushInitializations, 1);
    expect(find.text('Callback rejected by test server'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Get Started'), findsOneWidget);
  });
}

Future<PushNotificationService> _initializeFakePushNotifications() async {
  final service = PushNotificationService(
    initializeMessaging: () async => _FakePushMessagingClient(),
    isBadgeSupported: () async => false,
  );
  await service.initialize();
  return service;
}

class _FakeDownloadManager implements DownloadManagerInterface {
  @override
  bool get poolFull => false;

  @override
  Future<void> dispose() async {}

  @override
  void setActiveFeed(Feed feed) {}

  @override
  void submitTask(DownloadTask task) {}
}

class _FakePushMessagingClient implements PushMessagingClient {
  @override
  Stream<RemoteMessage> get onMessage => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  Future<PushAuthorizationStatus> getPermissionStatus() async =>
      PushAuthorizationStatus.denied;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<PushAuthorizationStatus> requestPermission() async =>
      PushAuthorizationStatus.denied;
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final stopwatch = Stopwatch()..start();

  while (finder.evaluate().isEmpty && stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  stopwatch.stop();
  expect(
    finder,
    findsWidgets,
    reason: 'Expected $finder to appear within $timeout.',
  );
}

class _InMemoryStorage implements LocalStorageInterface {
  final Map<String, Object> _values = {};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<bool> containsKey(String key) async => _values.containsKey(key);

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => _values[key] as double?;

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<T?> getObject<T>(String key) async {
    final value = _values[key];
    if (value is! String) {
      return null;
    }

    try {
      return jsonDecode(value) as T;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _values[key] as List<String>?;
    return value == null ? null : List<String>.of(value);
  }

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  Future<void> setDouble(String key, double value) async =>
      _values[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _values[key] = value;

  @override
  Future<void> setObject<T>(String key, T value) async {
    if (value == null) {
      _values.remove(key);
      return;
    }
    _values[key] = jsonEncode(value);
  }

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _values[key] = List<String>.of(value);
}

class _FakeOAuthBrowserLauncher implements OAuthBrowserLauncher {
  final List<String> requestedUrls = [];

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
  }) async {
    requestedUrls.add(url);
    expect(callbackUrlScheme, 'sprk');
    return 'sprk://oauth-callback?code=isolated-code';
  }
}

class _FakeAuthRepository implements AuthRepository {
  final List<String> completedCallbacks = [];

  @override
  Future<void> get initializationComplete => Future.value();

  @override
  bool get isAuthenticated => false;

  @override
  String? get did => null;

  @override
  String? get handle => null;

  @override
  PoptartClient? get atproto => null;

  @override
  Future<String> initiateOAuthWithoutLoginHint() async {
    return 'https://auth.example/register';
  }

  @override
  Future<LoginResult> completeOAuth(String callbackUrl) async {
    completedCallbacks.add(callbackUrl);
    return LoginResult.failed('Callback rejected by test server');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
