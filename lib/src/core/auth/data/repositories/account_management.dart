import 'dart:convert';

import 'package:http/http.dart' as http;

/// The account UI belongs to the authorization server, which can differ from
/// the PDS (for example, Bluesky's individual hosted PDS instances).
Future<Uri> resolveAccountManagementUri(
  http.Client client, {
  required String pdsEndpoint,
  required String did,
}) async {
  final response = await client
      .get(
        Uri.parse(pdsEndpoint).resolve('/.well-known/oauth-protected-resource'),
      )
      .timeout(const Duration(seconds: 15));
  if (response.statusCode != 200) {
    throw http.ClientException(
      'Account server discovery failed: ${response.statusCode}',
    );
  }
  final Object? metadata = jsonDecode(response.body);
  if (metadata case {'authorization_servers': [final String server]}) {
    final issuer = Uri.parse(server);
    if (issuer.scheme == 'https' &&
        issuer.host.isNotEmpty &&
        issuer.userInfo.isEmpty &&
        (issuer.path.isEmpty || issuer.path == '/') &&
        !issuer.hasQuery &&
        !issuer.hasFragment) {
      // Reference provider route; OAuth metadata has no account-management URL.
      return issuer.resolve('/account/u/${Uri.encodeComponent(did)}/manage');
    }
  }
  throw const FormatException('Invalid account authorization server metadata');
}
