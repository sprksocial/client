import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// Opens the system browser for OAuth and returns the callback URL.
abstract interface class OAuthBrowserLauncher {
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
  });
}

class FlutterWebAuthOAuthBrowserLauncher implements OAuthBrowserLauncher {
  const FlutterWebAuthOAuthBrowserLauncher();

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
  }) {
    return FlutterWebAuth2.authenticate(
      url: url,
      callbackUrlScheme: callbackUrlScheme,
    );
  }
}

final oauthBrowserLauncherProvider = Provider<OAuthBrowserLauncher>(
  (ref) => const FlutterWebAuthOAuthBrowserLauncher(),
);
