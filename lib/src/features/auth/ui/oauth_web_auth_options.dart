import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:spark/src/core/config/app_config.dart';

/// Builds platform-specific options for `FlutterWebAuth2.authenticate`.
///
/// On web, `debugOrigin` can be overridden for localhost OAuth callback
/// testing where callback and app origins differ (for example `localhost`
/// vs `127.0.0.1`).
FlutterWebAuth2Options buildOAuthWebAuthOptions() {
  if (!kIsWeb) {
    return const FlutterWebAuth2Options();
  }

  final loopbackOrigin = _resolveLoopbackWebOrigin();
  if (loopbackOrigin == null) {
    return const FlutterWebAuth2Options();
  }

  final callbackOrigin = _toOAuthCallbackOrigin(loopbackOrigin);
  return FlutterWebAuth2Options(
    debugOrigin: _normalizeOrigin(callbackOrigin),
  );
}

Uri? _resolveLoopbackWebOrigin() {
  final baseOrigin = Uri.tryParse(Uri.base.origin);
  if (baseOrigin != null && _isLoopbackHost(baseOrigin.host)) {
    return baseOrigin;
  }

  final configuredOrigin = AppConfig.webAuthOrigin.trim();
  final originSource = configuredOrigin.isNotEmpty ? configuredOrigin : '';
  if (originSource.isEmpty) {
    return null;
  }

  final originUri = Uri.tryParse(originSource);
  if (originUri == null || !_isLoopbackHost(originUri.host)) {
    return null;
  }

  return originUri;
}

Uri _toOAuthCallbackOrigin(Uri origin) {
  if (origin.host == 'localhost' || origin.host == '::1') {
    return origin.replace(host: '127.0.0.1');
  }
  return origin;
}

bool _isLoopbackHost(String host) =>
    host == 'localhost' || host == '127.0.0.1' || host == '::1';

String _normalizeOrigin(Uri uri) {
  final origin = uri.origin;
  return origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin;
}
