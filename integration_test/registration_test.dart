import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spark/src/features/auth/ui/pages/register_page.dart';

import 'support/authentication_test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rejected OAuth callback restores the registration action', (
    tester,
  ) async {
    final testApp = AuthenticationTestApp();
    addTearDown(testApp.dispose);

    await testApp.launch();
    await pumpUntilVisible(tester, find.byType(RegisterPage));

    final getStartedButton = find.byKey(RegisterPage.getStartedButtonKey);
    await tester.ensureVisible(getStartedButton);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();

    expect(testApp.authRepository.completedCallbacks, [
      'sprk://oauth-callback?code=isolated-code',
    ]);
    expect(testApp.oauthLauncher.requestedUrls, [
      'https://auth.example/register',
    ]);
    expect(testApp.oauthLauncher.callbackSchemes, ['sprk']);
    expect(find.text('Callback rejected by test server'), findsOneWidget);
    expect(getStartedButton, findsOneWidget);
  });
}
