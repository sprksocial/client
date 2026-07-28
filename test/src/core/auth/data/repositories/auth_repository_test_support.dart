import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spark/src/core/auth/data/models/aip_session_response.dart';
import 'package:spark/src/core/auth/data/models/auth_snapshot.dart';
import 'package:spark/src/core/auth/data/repositories/aip_scope_policy.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:spark/src/core/storage/preferences/local_storage_interface.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import '../../../../../support/in_memory_storage.dart';

AuthRepositoryImpl createAuthRepository({
  required LocalStorageInterface secureStorage,
  required http.Client httpClient,
  AtprotoSessionFetcher? fetchSessionInfo,
}) {
  return AuthRepositoryImpl(
    secureStorage: secureStorage,
    httpClient: httpClient,
    logger: SparkLogger(name: 'AuthRepositoryTest'),
    now: fixedNow,
    fetchSessionInfo: fetchSessionInfo,
  );
}

DateTime fixedNow() => DateTime.utc(2026, 1, 1);

const String redirectUri = 'sprk://oauth-callback';

List<String> get currentAipScopes => AipScopePolicy.current().scopes;

Future<void> storeSnapshot(
  InMemoryStorage storage,
  AuthSnapshot snapshot,
) async {
  await storage.setString(StorageKeys.account, snapshot.toJsonString());
}

PdsSessionCache pdsSessionCache({
  required String accessToken,
  required DateTime expiresAt,
  List<String>? scopes,
}) {
  return buildPdsSessionCacheFromAipResponse(
    AipAtprotocolSessionResponse.fromJson(
      sessionResponseBody(accessToken, scopes: scopes)
        ..['expires_at'] = expiresAt.millisecondsSinceEpoch ~/ 1000,
    ),
    clientId: 'https://auth.sprk.so/oauth-client-metadata.json',
  );
}

Map<String, dynamic> sessionResponseBody(
  String accessToken, {
  List<String>? scopes,
}) {
  return {
    'did': 'did:plc:test',
    'handle': 'test.sprk.so',
    'access_token': accessToken,
    'token_type': 'dpop',
    'scopes': scopes ?? currentAipScopes,
    'pds_endpoint': 'https://pds.sprk.so',
    'dpop_key': 'did:key:test',
    'dpop_jwk': {
      'kty': 'EC',
      'crv': 'P-256',
      'x': base64UrlNoPadding(List<int>.generate(32, (index) => index + 1)),
      'y': base64UrlNoPadding(List<int>.generate(32, (index) => index + 33)),
      'd': base64UrlNoPadding(List<int>.generate(32, (index) => index + 65)),
    },
    'expires_at': DateTime.utc(2030, 1, 1).millisecondsSinceEpoch ~/ 1000,
  };
}

String pdsJwt({required String? clientId, DateTime? exp}) {
  final payload = <String, Object?>{
    'sub': 'did:plc:test',
    'exp': (exp ?? DateTime.utc(2030, 1, 1)).millisecondsSinceEpoch ~/ 1000,
    'iat': DateTime.utc(2029, 1, 1).millisecondsSinceEpoch ~/ 1000,
    'scope': 'atproto',
    'client_id': clientId,
  };

  return '${base64UrlNoPadding(utf8.encode(json.encode({'alg': 'none', 'typ': 'JWT'})))}.${base64UrlNoPadding(utf8.encode(json.encode(payload)))}.signature';
}

String base64UrlNoPadding(List<int> value) {
  return base64Url.encode(value).replaceAll('=', '');
}

class CloseAwareMockClient extends MockClient {
  CloseAwareMockClient(super.fn);

  bool isClosed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (isClosed) {
      throw StateError('HTTP client is closed');
    }

    return super.send(request);
  }

  @override
  void close() {
    isClosed = true;
    super.close();
  }
}
