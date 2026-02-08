import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spark/src/core/utils/did_utils.dart';

/// Resolves the OAuth authorization server from a handle, DID, or PDS URL.
///
/// This method automatically detects the input type and performs the necessary
/// resolution steps:
/// - **Handle** ('user.bsky.social'): Resolve handle → DID → PDS → OAuth server
/// - **DID** ('did:plc:' or 'did:web:'): Fetch DID doc → PDS → OAuth server
/// - **PDS URL** ('https://example.com'): Directly resolve OAuth server
///
/// [input] The handle, DID, or PDS URL to resolve.
/// [identityService] Optional service URL for handle resolution.
///   Defaults to 'public.api.bsky.app'. Only used when input is a handle.
///
/// Returns a [Future<String>] containing the host of the authorization server
/// (e.g., 'bsky.social').
///
/// Throws:
/// - [ArgumentError] when input is null or empty
/// - [OAuthResolverException] when:
///   * Handle resolution fails
///   * DID document cannot be fetched
///   * PDS endpoint is not found in the DID document
///   * The HTTP request fails
///   * The server returns a non-200 status code
///   * The response cannot be parsed or doesn't contain authorization_servers
///
/// Example:
/// ```dart
/// // From PDS URL
/// final authServer = await resolveOAuthServer('https://suillus.us-west.host.bsky.network');
///
/// // From handle
/// final authServer = await resolveOAuthServer('user.bsky.social');
///
/// // From DID
/// final authServer = await resolveOAuthServer('did:plc:abc123');
/// ```
Future<String> resolveOAuthServer(
  String input, {
  String identityService = 'public.api.bsky.app',
}) async {
  if (input.isEmpty) throw ArgumentError.notNull(input);

  String pdsUrl;

  if (input.startsWith('did:')) {
    // Input is a DID - fetch DID document and extract PDS
    pdsUrl = await _resolvePdsFromDid(input);
  } else if (input.startsWith('https://') || input.startsWith('http://')) {
    // Input is already a PDS URL
    pdsUrl = input;
  } else {
    // Input is a handle - resolve to DID first, then get PDS
    final did = await _resolveHandleToDid(input, identityService);
    pdsUrl = await _resolvePdsFromDid(did);
  }

  return _resolveOAuthServerFromPds(pdsUrl);
}

/// Resolves a handle to a DID using the identity service.
Future<String> _resolveHandleToDid(
  String handle,
  String identityService,
) async {
  final resolveUrl = Uri.https(
    identityService,
    '/xrpc/com.atproto.identity.resolveHandle',
    {'handle': handle},
  );
  final resolveResponse = await http.get(resolveUrl);

  if (resolveResponse.statusCode != 200) {
    throw OAuthResolverException(
      'Failed to resolve handle: ${resolveResponse.statusCode}',
    );
  }

  final resolveBody = jsonDecode(resolveResponse.body) as Map<String, dynamic>;
  final did = resolveBody['did'] as String?;

  if (did == null || did.isEmpty) {
    throw const OAuthResolverException(
      'Handle resolution did not return a DID',
    );
  }

  return did;
}

/// Resolves a DID to its PDS endpoint by fetching the DID document.
Future<String> _resolvePdsFromDid(String did) async {
  final didDocUrl = DidUtils.buildDidDocumentUrl(did);
  final didDocResponse = await http.get(didDocUrl);

  if (didDocResponse.statusCode != 200) {
    throw OAuthResolverException(
      'Failed to fetch DID document: ${didDocResponse.statusCode}',
    );
  }

  final didDoc = jsonDecode(didDocResponse.body) as Map<String, dynamic>;
  final pdsEndpoint = _extractPdsEndpoint(didDoc);

  if (pdsEndpoint == null) {
    throw const OAuthResolverException(
      'PDS endpoint not found in DID document',
    );
  }

  return pdsEndpoint;
}

/// Resolves the OAuth server from a PDS URL.
Future<String> _resolveOAuthServerFromPds(String pdsUrl) async {
  final pdsUri = Uri.tryParse(pdsUrl);
  if (pdsUri == null) throw ArgumentError.value(pdsUrl);

  final wellKnownUrl = pdsUri.resolve('/.well-known/oauth-protected-resource');
  final response = await http.get(wellKnownUrl);

  if (response.statusCode != 200) {
    throw OAuthResolverException(
      'Failed to get OAuth protected resource metadata: ${response.statusCode}',
    );
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final authorizationServers = body['authorization_servers'] as List<dynamic>?;

  if (authorizationServers == null || authorizationServers.isEmpty) {
    throw const OAuthResolverException(
      'No authorization servers found in OAuth protected resource metadata',
    );
  }

  final firstServer = authorizationServers.first as String;
  final serverUri = Uri.tryParse(firstServer);
  if (serverUri == null) {
    throw OAuthResolverException(
      'Invalid authorization server URL: $firstServer',
    );
  }

  return serverUri.host;
}

/// Extracts the PDS endpoint from a DID document.
String? _extractPdsEndpoint(Map<String, dynamic> doc) {
  final services = doc['service'] as List<dynamic>?;
  if (services == null || services.isEmpty) {
    return null;
  }

  for (final service in services) {
    if (service is Map<String, dynamic> &&
        service['id'] == '#atproto_pds' &&
        service['type'] == 'AtprotoPersonalDataServer') {
      return service['serviceEndpoint'] as String?;
    }
  }

  return null;
}

/// Exception thrown when OAuth server resolution fails.
final class OAuthResolverException implements Exception {
  const OAuthResolverException(this.message);

  /// Error message.
  final String message;

  @override
  String toString() => 'OAuthResolverException: $message';
}
