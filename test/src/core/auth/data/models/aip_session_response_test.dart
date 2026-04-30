import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/auth/data/models/aip_session_response.dart';

void main() {
  group('AIP session mapping', () {
    test('maps dpop_jwk into atproto.dart key format', () {
      final xBytes = List<int>.generate(32, (index) => index + 1);
      final yBytes = List<int>.generate(32, (index) => index + 33);
      final dBytes = List<int>.generate(32, (index) => index + 65);
      final response = _sessionResponse(
        accessToken: _jwt(clientId: 'spark-client'),
        clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
        x: _base64UrlNoPadding(xBytes),
        y: _base64UrlNoPadding(yBytes),
        d: _base64UrlNoPadding(dBytes),
      );

      final cache = buildPdsSessionCacheFromAipResponse(response);

      expect(cache.publicKey, base64Url.encode([...xBytes, ...yBytes]));
      expect(cache.privateKey, base64Url.encode(dBytes));
    });

    test('accepts empty initial nonce and preserves later nonce updates', () {
      final cache = buildPdsSessionCacheFromAipResponse(
        _sessionResponse(
          accessToken: _jwt(clientId: 'spark-client'),
          clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
        ),
      );

      expect(cache.dpopNonce, isEmpty);

      final restored = restorePdsOAuthSessionFromCache(
        cache.copyWith(dpopNonce: 'nonce-123'),
      );

      expect(restored.$dPoPNonce, 'nonce-123');
    });

    test('normalizes legacy unpadded cached keys on restore', () {
      final normalizedCache = buildPdsSessionCacheFromAipResponse(
        _sessionResponse(
          accessToken: _jwt(clientId: 'spark-client'),
          clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
        ),
      );
      final legacyCache = normalizedCache.copyWith(
        publicKey: normalizedCache.publicKey.replaceAll('=', ''),
        privateKey: normalizedCache.privateKey.replaceAll('=', ''),
      );

      final restored = restorePdsOAuthSessionFromCache(legacyCache);

      expect(restored.$publicKey, normalizedCache.publicKey);
      expect(restored.$privateKey, normalizedCache.privateKey);
    });

    test('restores with exported client_id when token omits the claim', () {
      final cache = buildPdsSessionCacheFromAipResponse(
        _sessionResponse(
          accessToken: _jwt(clientId: null),
          clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
        ),
      );

      final restored = restorePdsOAuthSessionFromCache(cache);

      expect(
        restored.$clientId,
        'https://auth.sprk.so/oauth-client-metadata.json',
      );
    });

    test(
      'restores with caller-provided client_id when token omits the claim',
      () {
        final cache = buildPdsSessionCacheFromAipResponse(
          _sessionResponse(accessToken: _jwt(clientId: null)),
          clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
        );

        final restored = restorePdsOAuthSessionFromCache(cache);

        expect(
          restored.$clientId,
          'https://auth.sprk.so/oauth-client-metadata.json',
        );
      },
    );

    test('uses caller-provided client_id when exported client_id is empty', () {
      final cache = buildPdsSessionCacheFromAipResponse(
        _sessionResponse(
          accessToken: _jwtFromPayload({
            'sub': 'did:plc:test',
            'exp': DateTime.utc(2030, 1, 1).millisecondsSinceEpoch ~/ 1000,
            'iat': DateTime.utc(2029, 1, 1).millisecondsSinceEpoch ~/ 1000,
            'scope': 'atproto',
            'cnf': 'legacy-key-binding',
          }),
          clientId: '',
        ),
        clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
      );

      final restored = restorePdsOAuthSessionFromCache(cache);

      expect(
        restored.$clientId,
        'https://auth.sprk.so/oauth-client-metadata.json',
      );
    });

    test('rejects responses without private DPoP key material', () {
      final response = _sessionResponse(
        accessToken: _jwt(clientId: 'spark-client'),
        clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
        d: null,
      );

      expect(
        () => buildPdsSessionCacheFromAipResponse(response),
        throwsA(
          isA<AipExportedSessionException>().having(
            (error) => error.message,
            'message',
            contains('DPoP private key material'),
          ),
        ),
      );
    });

    test('does not fall back to the token client_id claim', () {
      final response = _sessionResponse(
        accessToken: _jwt(clientId: 'spark-client'),
      );

      expect(
        () => buildPdsSessionCacheFromAipResponse(response),
        throwsA(
          isA<AipExportedSessionException>().having(
            (error) => error.message,
            'message',
            contains('missing client_id'),
          ),
        ),
      );
    });

    test('rejects exported PDS access tokens without client_id', () {
      final response = _sessionResponse(accessToken: _jwt(clientId: null));

      expect(
        () => buildPdsSessionCacheFromAipResponse(response),
        throwsA(
          isA<AipExportedSessionException>().having(
            (error) => error.message,
            'message',
            contains('missing client_id'),
          ),
        ),
      );
    });

    test('rejects opaque exported access tokens with direct-PDS context', () {
      final response = _sessionResponse(
        accessToken: 'opaque-aip-access-token',
        clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
      );

      expect(
        () => buildPdsSessionCacheFromAipResponse(response),
        throwsA(
          isA<AipExportedSessionException>().having(
            (error) => error.message,
            'message',
            contains('not a JWT'),
          ),
        ),
      );
    });

    test('rejects malformed exported access token JWTs with context', () {
      final response = _sessionResponse(
        accessToken: 'header.not-base64url.signature',
        clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
      );

      expect(
        () => buildPdsSessionCacheFromAipResponse(response),
        throwsA(
          isA<AipExportedSessionException>().having(
            (error) => error.message,
            'message',
            contains('malformed access_token JWT'),
          ),
        ),
      );
    });

    test('rejects exported access token JWTs missing required claims', () {
      final response = _sessionResponse(
        accessToken: _jwtFromPayload({
          'exp': DateTime.utc(2030, 1, 1).millisecondsSinceEpoch ~/ 1000,
          'iat': DateTime.utc(2029, 1, 1).millisecondsSinceEpoch ~/ 1000,
        }),
        clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
      );

      expect(
        () => buildPdsSessionCacheFromAipResponse(response),
        throwsA(
          isA<AipExportedSessionException>().having(
            (error) => error.message,
            'message',
            contains('missing required "sub" claim'),
          ),
        ),
      );
    });

    test('rejects exported access token JWTs with invalid claim types', () {
      final response = _sessionResponse(
        accessToken: _jwtFromPayload({
          'sub': 'did:plc:test',
          'exp': '2030-01-01T00:00:00Z',
          'iat': DateTime.utc(2029, 1, 1).millisecondsSinceEpoch ~/ 1000,
        }),
        clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
      );

      expect(
        () => buildPdsSessionCacheFromAipResponse(response),
        throwsA(
          isA<AipExportedSessionException>().having(
            (error) => error.message,
            'message',
            contains('invalid required numeric "exp" claim'),
          ),
        ),
      );
    });
  });
}

AipAtprotocolSessionResponse _sessionResponse({
  required String accessToken,
  String? clientId,
  String? d = 'AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgI',
  String x = 'AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE',
  String y = 'AwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwM',
}) {
  return AipAtprotocolSessionResponse(
    did: 'did:plc:test',
    handle: 'test.sprk.so',
    accessToken: accessToken,
    tokenType: 'dpop',
    scopes: const ['atproto'],
    pdsEndpoint: 'https://pds.sprk.so',
    expiresAt: DateTime.utc(2030, 1, 1),
    clientId: clientId,
    dpopKey: 'did:key:test',
    dpopJwk: AipDpopJwk(kty: 'EC', crv: 'P-256', x: x, y: y, d: d),
  );
}

String _jwt({String? clientId}) {
  final payload = <String, Object?>{
    'sub': 'did:plc:test',
    'exp': DateTime.utc(2030, 1, 1).millisecondsSinceEpoch ~/ 1000,
    'iat': DateTime.utc(2029, 1, 1).millisecondsSinceEpoch ~/ 1000,
    'scope': 'atproto',
    'client_id': clientId,
  };

  return _jwtFromPayload(payload);
}

String _jwtFromPayload(Map<String, Object?> payload) {
  return '${_base64UrlNoPadding(utf8.encode(json.encode({'alg': 'none', 'typ': 'JWT'})))}.${_base64UrlNoPadding(utf8.encode(json.encode(payload)))}.signature';
}

String _base64UrlNoPadding(List<int> value) {
  return base64Url.encode(value).replaceAll('=', '');
}
