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
    this.clientId,
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
      clientId: json['client_id'] as String?,
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
  final String? clientId;
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
  String? clientId,
}) {
  final dpopJwk = response.dpopJwk;
  if (dpopJwk == null || dpopJwk.d == null || dpopJwk.d!.isEmpty) {
    throw const AipExportedSessionException(
      'AIP-exported session is missing DPoP private key material.',
    );
  }

  final resolvedClientId = _firstNonEmpty(response.clientId, clientId);
  if (resolvedClientId == null || resolvedClientId.isEmpty) {
    throw const AipExportedSessionException(
      'AIP-exported token is incompatible with direct-PDS mode: missing client_id.',
    );
  }
  validateExportedAccessToken(response.accessToken);

  return PdsSessionCache(
    accessToken: response.accessToken,
    expiresAt: response.expiresAt.toIso8601String(),
    did: response.did,
    handle: response.handle,
    pdsEndpoint: response.pdsEndpoint,
    scope: response.scopes.join(' '),
    dpopNonce: dpopNonce,
    clientId: resolvedClientId,
    publicKey: encodeDpopPublicKey(dpopJwk.x, dpopJwk.y),
    privateKey: encodeDpopPrivateKey(dpopJwk.d!),
  );
}

OAuthSession restorePdsOAuthSessionFromCache(PdsSessionCache cache) {
  final clientId = _firstNonEmpty(cache.clientId);
  if (clientId == null || clientId.isEmpty) {
    throw const AipExportedSessionException(
      'AIP-exported token is incompatible with direct-PDS mode: missing client_id.',
    );
  }
  validateExportedAccessToken(cache.accessToken);

  try {
    return restoreOAuthSession(
      accessToken: cache.accessToken,
      refreshToken: '',
      clientId: clientId,
      dPoPNonce: cache.dpopNonce,
      publicKey: normalizeDpopKeyEncoding(cache.publicKey),
      privateKey: normalizeDpopKeyEncoding(cache.privateKey),
    );
  } on FormatException catch (error) {
    throw AipExportedSessionException(
      'AIP /api/atprotocol/session returned an access_token JWT that could '
      'not be restored: ${error.message}.',
    );
  }
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

void validateExportedAccessToken(String accessToken) {
  final parts = accessToken.split('.');
  if (parts.length != 3 || parts.any((part) => part.isEmpty)) {
    throw const AipExportedSessionException(
      'AIP /api/atprotocol/session returned an access_token that is not a JWT. '
      'Direct-PDS mode requires AIP to export the PDS-issued JWT access token, '
      'not an opaque AIP bearer token.',
    );
  }

  final Map<String, dynamic> payload;
  try {
    final decoded = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JWT payload is not a JSON object.');
    }
    payload = decoded;
  } catch (_) {
    throw const AipExportedSessionException(
      'AIP /api/atprotocol/session returned a malformed access_token JWT. '
      'Direct-PDS mode requires a decodable PDS-issued JWT access token.',
    );
  }

  _requireStringClaim(payload, 'sub');
  _requireNumericDateClaim(payload, 'exp');
  _requireNumericDateClaim(payload, 'iat');
  _requireOptionalStringClaim(payload, 'aud');
  _requireOptionalStringClaim(payload, 'jti');
  _requireOptionalStringClaim(payload, 'client_id');
  _requireOptionalStringClaim(payload, 'scope');
}

void _requireStringClaim(Map<String, dynamic> payload, String claim) {
  final value = payload[claim];
  if (value is String && value.isNotEmpty) {
    return;
  }

  final reason = value == null ? 'missing' : 'invalid';
  throw AipExportedSessionException(
    'AIP /api/atprotocol/session returned an access_token JWT with a $reason '
    'required "$claim" claim.',
  );
}

void _requireNumericDateClaim(Map<String, dynamic> payload, String claim) {
  final value = payload[claim];
  if (value is num) {
    return;
  }

  final reason = value == null ? 'missing' : 'invalid';
  throw AipExportedSessionException(
    'AIP /api/atprotocol/session returned an access_token JWT with a $reason '
    'required numeric "$claim" claim.',
  );
}

void _requireOptionalStringClaim(Map<String, dynamic> payload, String claim) {
  final value = payload[claim];
  if (value == null || value is String) {
    return;
  }

  throw AipExportedSessionException(
    'AIP /api/atprotocol/session returned an access_token JWT with an invalid '
    '"$claim" claim; expected a string.',
  );
}

String? _firstNonEmpty(String? first, [String? second]) {
  if (first != null && first.isNotEmpty) {
    return first;
  }
  if (second != null && second.isNotEmpty) {
    return second;
  }

  return null;
}
