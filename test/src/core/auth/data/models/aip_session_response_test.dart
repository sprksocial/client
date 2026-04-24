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
        _sessionResponse(accessToken: _jwt(clientId: 'spark-client')),
      );

      expect(cache.dpopNonce, isEmpty);

      final restored = restorePdsOAuthSessionFromCache(
        cache.copyWith(dpopNonce: 'nonce-123'),
      );

      expect(restored.$dPoPNonce, 'nonce-123');
    });

    test('normalizes legacy unpadded cached keys on restore', () {
      final normalizedCache = buildPdsSessionCacheFromAipResponse(
        _sessionResponse(accessToken: _jwt(clientId: 'spark-client')),
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

    test('rejects responses without private DPoP key material', () {
      final response = _sessionResponse(
        accessToken: _jwt(clientId: 'spark-client'),
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

  return '${_base64UrlNoPadding(utf8.encode(json.encode({'alg': 'none', 'typ': 'JWT'})))}.${_base64UrlNoPadding(utf8.encode(json.encode(payload)))}.signature';
}

String _base64UrlNoPadding(List<int> value) {
  return base64Url.encode(value).replaceAll('=', '');
}
