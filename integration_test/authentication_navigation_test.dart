import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spark/src/features/auth/ui/pages/login_page.dart';
import 'package:spark/src/features/auth/ui/pages/register_page.dart';

import 'support/authentication_test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can move between registration and login', (tester) async {
    final testApp = AuthenticationTestApp();
    addTearDown(testApp.dispose);

    await testApp.launch();
    await pumpUntilVisible(tester, find.byType(RegisterPage));

    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(testApp.downloadInitializations, 1);
    expect(testApp.pushInitializations, 1);

    await tester.tap(find.byKey(RegisterPage.haveAccountButtonKey));
    await pumpUntilVisible(tester, find.byType(LoginPage));

    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.byKey(LoginPage.backButtonKey));
    await pumpUntilVisible(tester, find.byType(RegisterPage));

    expect(find.byType(RegisterPage), findsOneWidget);
  });
}
