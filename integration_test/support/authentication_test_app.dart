import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/main.dart' as app;
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/notifications/push_notification_service.dart';
import 'package:spark/src/core/storage/cache/download_manager_interface.dart';
import 'package:spark/src/core/storage/storage.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/auth/providers/oauth_browser_launcher.dart';

class AuthenticationTestApp {
  AuthenticationTestApp()
    : authRepository = FakeAuthRepository(),
      oauthLauncher = FakeOAuthBrowserLauncher();

  final FakeAuthRepository authRepository;
  final FakeOAuthBrowserLauncher oauthLauncher;
  ProviderContainer? _providerContainer;

  int downloadInitializations = 0;
  int pushInitializations = 0;

  Future<void> launch() async {
    final providerContainer = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        oauthBrowserLauncherProvider.overrideWithValue(oauthLauncher),
      ],
    );
    _providerContainer = providerContainer;

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
  }

  void dispose() {
    _providerContainer?.dispose();
    _providerContainer = null;
  }
}

Future<void> pumpUntilVisible(
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

class FakeOAuthBrowserLauncher implements OAuthBrowserLauncher {
  final List<String> requestedUrls = [];
  final List<String> callbackSchemes = [];

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
  }) async {
    requestedUrls.add(url);
    callbackSchemes.add(callbackUrlScheme);
    return 'sprk://oauth-callback?code=isolated-code';
  }
}

class FakeAuthRepository implements AuthRepository {
  final List<String> completedCallbacks = [];

  @override
  Future<void> get initializationComplete => Future<void>.value();

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
  Stream<RemoteMessage> get onMessage => const Stream<RemoteMessage>.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      const Stream<RemoteMessage>.empty();

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

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
