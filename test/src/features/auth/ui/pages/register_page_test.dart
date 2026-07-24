import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/auth/providers/oauth_browser_launcher.dart';
import 'package:spark/src/features/auth/ui/pages/register_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('completes the callback and routes new users to onboarding', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final browserLauncher = _FakeOAuthBrowserLauncher(
      () async => 'sprk://oauth-callback?code=registration-code',
    );
    final onboardingRepository = _FakeOnboardingRepository(false);

    await _pumpRegisterPage(
      tester,
      authRepository: authRepository,
      browserLauncher: browserLauncher,
      onboardingRepository: onboardingRepository,
    );

    await tester.tap(find.bySemanticsLabel('Get Started'));
    await tester.pumpAndSettle();

    expect(authRepository.initiateWithoutHintCalls, 1);
    expect(browserLauncher.calls, [
      (url: 'https://auth.example/register', callbackUrlScheme: 'sprk'),
    ]);
    expect(authRepository.completedCallbacks, [
      'sprk://oauth-callback?code=registration-code',
    ]);
    expect(onboardingRepository.hasSparkProfileCalls, 1);
    expect(find.text('Onboarding destination'), findsOneWidget);
  });

  testWidgets('native cancellation restores the registration action', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final browserLauncher = _FakeOAuthBrowserLauncher(
      () async => throw PlatformException(code: 'CANCELED'),
    );

    await _pumpRegisterPage(
      tester,
      authRepository: authRepository,
      browserLauncher: browserLauncher,
      onboardingRepository: _FakeOnboardingRepository(false),
    );

    await tester.tap(find.bySemanticsLabel('Get Started'));
    await tester.pumpAndSettle();

    expect(authRepository.completedCallbacks, isEmpty);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.textContaining('Sign up failed:'), findsNothing);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Get Started'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
  });

  testWidgets('browser errors are presented and restore the action', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final browserLauncher = _FakeOAuthBrowserLauncher(
      () async => throw PlatformException(
        code: 'FAILED',
        message: 'Browser unavailable',
      ),
    );

    await _pumpRegisterPage(
      tester,
      authRepository: authRepository,
      browserLauncher: browserLauncher,
      onboardingRepository: _FakeOnboardingRepository(false),
    );

    await tester.tap(find.bySemanticsLabel('Get Started'));
    await tester.pumpAndSettle();

    expect(authRepository.completedCallbacks, isEmpty);
    expect(find.text('Sign up failed: Browser unavailable'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Get Started'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
  });
}

Future<void> _pumpRegisterPage(
  WidgetTester tester, {
  required _FakeAuthRepository authRepository,
  required _FakeOAuthBrowserLauncher browserLauncher,
  required _FakeOnboardingRepository onboardingRepository,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = RootStackRouter.build(
    routes: [
      AutoRoute(
        page: PageInfo.builder(
          RegisterRoute.name,
          builder: (context, data) => const RegisterPage(),
        ),
        path: '/',
        initial: true,
      ),
      AutoRoute(
        page: PageInfo.builder(
          OnboardingRoute.name,
          builder: (context, data) => const Scaffold(
            body: Center(child: Text('Onboarding destination')),
          ),
        ),
        path: '/onboarding',
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        oauthBrowserLauncherProvider.overrideWithValue(browserLauncher),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
      ],
      child: MaterialApp.router(
        routerConfig: router.config(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeOAuthBrowserLauncher implements OAuthBrowserLauncher {
  _FakeOAuthBrowserLauncher(this.response);

  final Future<String> Function() response;
  final List<({String url, String callbackUrlScheme})> calls = [];

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
  }) {
    calls.add((url: url, callbackUrlScheme: callbackUrlScheme));
    return response();
  }
}

class _FakeAuthRepository implements AuthRepository {
  bool _isAuthenticated = false;

  int initiateWithoutHintCalls = 0;
  final List<String> completedCallbacks = [];

  @override
  Future<void> get initializationComplete => Future.value();

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  String? get did => _isAuthenticated ? 'did:plc:me' : null;

  @override
  String? get handle => _isAuthenticated ? 'me.example' : null;

  @override
  PoptartClient? get atproto => null;

  @override
  Future<String> initiateOAuthWithoutLoginHint() async {
    initiateWithoutHintCalls++;
    return 'https://auth.example/register';
  }

  @override
  Future<LoginResult> completeOAuth(String callbackUrl) async {
    completedCallbacks.add(callbackUrl);
    _isAuthenticated = true;
    return LoginResult.success();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository(this._hasSparkProfile);

  final bool _hasSparkProfile;
  int hasSparkProfileCalls = 0;

  @override
  Future<bool> hasSparkProfile() async {
    hasSparkProfileCalls++;
    return _hasSparkProfile;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
