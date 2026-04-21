import 'dart:convert';
import 'dart:typed_data';

import 'package:atproto_core/atproto_core.dart' show restoreOAuthSession;
import 'package:atproto_oauth/atproto_oauth.dart';
import 'package:spark/src/core/auth/data/models/auth_snapshot.dart';

class AipAtprotocolSessionResponse {
  const AipAtprotocolSessionResponse({
    required this.did,
    required this.handle,
    required this.accessToken,
    required this.tokenType,
    required this.scopes,
    required this.pdsEndpoint,
    required this.expiresAt,
    this.dpopKey,
    this.dpopJwk,
  });

  factory AipAtprotocolSessionResponse.fromJson(Map<String, dynamic> json) {
    return AipAtprotocolSessionResponse(
      did: json['did'] as String,
      handle: json['handle'] as String,
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      scopes: (json['scopes'] as List<dynamic>? ?? const [])
          .map((scope) => scope as String)
          .toList(),
      pdsEndpoint: json['pds_endpoint'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (json['expires_at'] as int) * 1000,
        isUtc: true,
      ),
      dpopKey: json['dpop_key'] as String?,
      dpopJwk: json['dpop_jwk'] == null
          ? null
          : AipDpopJwk.fromJson(json['dpop_jwk'] as Map<String, dynamic>),
    );
  }

  final String did;
  final String handle;
  final String accessToken;
  final String tokenType;
  final List<String> scopes;
  final String pdsEndpoint;
  final DateTime expiresAt;
  final String? dpopKey;
  final AipDpopJwk? dpopJwk;
}

class AipDpopJwk {
  const AipDpopJwk({
    required this.kty,
    required this.crv,
    required this.x,
    required this.y,
    this.d,
  });

  factory AipDpopJwk.fromJson(Map<String, dynamic> json) {
    return AipDpopJwk(
      kty: json['kty'] as String,
      crv: json['crv'] as String,
      x: json['x'] as String,
      y: json['y'] as String,
      d: json['d'] as String?,
    );
  }

  final String kty;
  final String crv;
  final String x;
  final String y;
  final String? d;
}

class AipExportedSessionException implements Exception {
  const AipExportedSessionException(this.message);

  final String message;

  @override
  String toString() => message;
}

PdsSessionCache buildPdsSessionCacheFromAipResponse(
  AipAtprotocolSessionResponse response, {
  String dpopNonce = '',
}) {
  final dpopJwk = response.dpopJwk;
  if (dpopJwk == null || dpopJwk.d == null || dpopJwk.d!.isEmpty) {
    throw const AipExportedSessionException(
      'AIP-exported session is missing DPoP private key material.',
    );
  }

  final clientId = extractClientIdFromAccessToken(response.accessToken);
  if (clientId == null || clientId.isEmpty) {
    throw const AipExportedSessionException(
      'AIP-exported token is incompatible with direct-PDS mode: missing client_id.',
    );
  }

  return PdsSessionCache(
    accessToken: response.accessToken,
    expiresAt: response.expiresAt.toIso8601String(),
    did: response.did,
    handle: response.handle,
    pdsEndpoint: response.pdsEndpoint,
    scope: response.scopes.join(' '),
    dpopNonce: dpopNonce,
    publicKey: encodeDpopPublicKey(dpopJwk.x, dpopJwk.y),
    privateKey: encodeDpopPrivateKey(dpopJwk.d!),
  );
}

OAuthSession restorePdsOAuthSessionFromCache(PdsSessionCache cache) {
  final clientId = extractClientIdFromAccessToken(cache.accessToken);
  if (clientId == null || clientId.isEmpty) {
    throw const AipExportedSessionException(
      'AIP-exported token is incompatible with direct-PDS mode: missing client_id.',
    );
  }

  return restoreOAuthSession(
    accessToken: cache.accessToken,
    refreshToken: '',
    clientId: clientId,
    dPoPNonce: cache.dpopNonce,
    publicKey: normalizeDpopKeyEncoding(cache.publicKey),
    privateKey: normalizeDpopKeyEncoding(cache.privateKey),
  );
}

String encodeDpopPublicKey(String x, String y) {
  final xBytes = base64Url.decode(base64Url.normalize(x));
  final yBytes = base64Url.decode(base64Url.normalize(y));
  final buffer = Uint8List(xBytes.length + yBytes.length)
    ..setAll(0, xBytes)
    ..setAll(xBytes.length, yBytes);

  return base64Url.encode(buffer);
}

String encodeDpopPrivateKey(String d) {
  final bytes = base64Url.decode(base64Url.normalize(d));
  return base64Url.encode(bytes);
}

String normalizeDpopKeyEncoding(String value) {
  return base64Url.normalize(value);
}

String? extractClientIdFromAccessToken(String accessToken) {
  final payload = decodeJwtPayload(accessToken);
  final clientId = payload['client_id'];
  if (clientId is String && clientId.isNotEmpty) {
    return clientId;
  }

  return null;
}

Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length < 2) {
    throw const AipExportedSessionException('Invalid exported JWT.');
  }

  final payloadBytes = base64Url.decode(base64Url.normalize(parts[1]));
  final payload = json.decode(utf8.decode(payloadBytes));
  if (payload is! Map<String, dynamic>) {
    throw const AipExportedSessionException('Invalid exported JWT payload.');
  }

  return payload;
}
