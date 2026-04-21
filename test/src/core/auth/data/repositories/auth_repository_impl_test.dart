import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:spark/src/core/auth/data/models/account.dart';
import 'package:spark/src/core/auth/data/models/aip_session_response.dart';
import 'package:spark/src/core/auth/data/models/auth_snapshot.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:spark/src/core/storage/preferences/local_storage_interface.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('startup with valid cached PDS session does not call AIP', () async {
      final storage = _InMemoryStorage();
      await _storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
          ),
          pdsSessionCache: _pdsSessionCache(
            accessToken: _pdsJwt(clientId: 'client-1'),
            expiresAt: DateTime.utc(2030, 1, 1),
          ),
        ),
      );

      var networkCalls = 0;
      final client = MockClient((request) async {
        networkCalls += 1;
        return http.Response('unexpected request', 500);
      });

      final repository = AuthRepositoryImpl(
        secureStorage: storage,
        httpClient: client,
        logger: SparkLogger(name: 'AuthRepositoryTest'),
      );

      await repository.initializationComplete;

      expect(repository.isAuthenticated, isTrue);
      expect(repository.did, 'did:plc:test');
      expect(networkCalls, 0);
    });

    test(
      'startup clears legacy account payload and requires re-login',
      () async {
        final storage = _InMemoryStorage();
        final cache = _pdsSessionCache(
          accessToken: _pdsJwt(clientId: 'client-1'),
          expiresAt: DateTime.utc(2030, 1, 1),
        );
        await storage.setString(
          StorageKeys.account,
          Account(
            accessToken: cache.accessToken,
            refreshToken: 'legacy-refresh',
            publicKey: cache.publicKey,
            privateKey: cache.privateKey,
            clientId: 'client-1',
            dpopNonce: cache.dpopNonce,
            expiresAt: cache.expiresAt,
            did: cache.did,
            handle: cache.handle,
            pdsEndpoint: cache.pdsEndpoint,
            server: 'https://auth.sprk.so',
          ).toJsonString(),
        );

        final repository = AuthRepositoryImpl(
          secureStorage: storage,
          httpClient: MockClient((_) async => http.Response('unexpected', 500)),
          logger: SparkLogger(name: 'AuthRepositoryTest'),
        );

        await repository.initializationComplete;

        expect(repository.isAuthenticated, isFalse);
        expect(repository.did, isNull);
        expect(await storage.getString(StorageKeys.account), isNull);
      },
    );

    test('startup with stale cached PDS session refreshes via AIP', () async {
      final storage = _InMemoryStorage();
      await _storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
          ),
          aipGrant: AipGrant(
            credentialsJson: oauth2.Credentials(
              'aip-access',
              expiration: DateTime.utc(2030, 1, 1),
            ).toJson(),
          ),
          pdsSessionCache: _pdsSessionCache(
            accessToken: _pdsJwt(
              clientId: 'client-1',
              exp: DateTime.utc(2020, 1, 1),
            ),
            expiresAt: DateTime.utc(2020, 1, 1),
          ),
        ),
      );

      var sessionCalls = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/api/atprotocol/session') {
          sessionCalls += 1;
          expect(request.headers['authorization'], 'Bearer aip-access');
          return http.Response(
            json.encode(_sessionResponseBody(_pdsJwt(clientId: 'client-1'))),
            200,
          );
        }

        return http.Response('unexpected request', 500);
      });

      final repository = AuthRepositoryImpl(
        secureStorage: storage,
        httpClient: client,
        logger: SparkLogger(name: 'AuthRepositoryTest'),
      );

      await repository.initializationComplete;

      expect(repository.isAuthenticated, isTrue);
      expect(repository.pdsEndpoint, 'https://pds.sprk.so');
      expect(sessionCalls, 1);
    });

    test(
      'refreshToken refreshes AIP grant before fetching a new PDS session',
      () async {
        final storage = _InMemoryStorage();
        await _storeSnapshot(
          storage,
          AuthSnapshot(
            aipClientRegistration: const AipClientRegistration(
              clientId: 'client-1',
              clientSecret: 'secret-1',
            ),
            aipGrant: AipGrant(
              credentialsJson: oauth2.Credentials(
                'expired-aip-access',
                refreshToken: 'refresh-1',
                tokenEndpoint: Uri.parse('https://auth.sprk.so/oauth/token'),
                expiration: DateTime.utc(2020, 1, 1),
              ).toJson(),
            ),
            pdsSessionCache: _pdsSessionCache(
              accessToken: _pdsJwt(clientId: 'client-1'),
              expiresAt: DateTime.utc(2030, 1, 1),
            ),
          ),
        );

        var tokenCalls = 0;
        var sessionCalls = 0;
        final client = MockClient((request) async {
          if (request.url.path == '/oauth/token') {
            tokenCalls += 1;
            return http.Response(
              json.encode({
                'access_token': 'fresh-aip-access',
                'refresh_token': 'refresh-2',
                'token_type': 'Bearer',
                'expires_in': 3600,
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          if (request.url.path == '/api/atprotocol/session') {
            sessionCalls += 1;
            expect(request.headers['authorization'], 'Bearer fresh-aip-access');
            return http.Response(
              json.encode(_sessionResponseBody(_pdsJwt(clientId: 'client-1'))),
              200,
            );
          }

          return http.Response('unexpected request', 500);
        });

        final repository = AuthRepositoryImpl(
          secureStorage: storage,
          httpClient: client,
          logger: SparkLogger(name: 'AuthRepositoryTest'),
        );

        await repository.initializationComplete;
        final refreshed = await repository.refreshToken();

        expect(refreshed, isTrue);
        expect(tokenCalls, 1);
        expect(sessionCalls, 1);

        final savedSnapshot = AuthSnapshot.fromJsonString(
          (await storage.getString(StorageKeys.account))!,
        );
        expect(savedSnapshot.aipGrant, isNotNull);
        expect(
          savedSnapshot.aipGrant!.credentialsJson,
          contains('fresh-aip-access'),
        );
      },
    );

    test('concurrent refreshToken calls share one in-flight refresh', () async {
      final storage = _InMemoryStorage();
      await _storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
            clientSecret: 'secret-1',
          ),
          aipGrant: AipGrant(
            credentialsJson: oauth2.Credentials(
              'expired-aip-access',
              refreshToken: 'refresh-1',
              tokenEndpoint: Uri.parse('https://auth.sprk.so/oauth/token'),
              expiration: DateTime.utc(2020, 1, 1),
            ).toJson(),
          ),
          pdsSessionCache: _pdsSessionCache(
            accessToken: _pdsJwt(clientId: 'client-1'),
            expiresAt: DateTime.utc(2030, 1, 1),
          ),
        ),
      );

      final tokenRequestStarted = Completer<void>();
      final releaseTokenRefresh = Completer<void>();
      var tokenCalls = 0;
      var sessionCalls = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/oauth/token') {
          tokenCalls += 1;
          if (!tokenRequestStarted.isCompleted) {
            tokenRequestStarted.complete();
          }
          await releaseTokenRefresh.future;
          return http.Response(
            json.encode({
              'access_token': 'fresh-aip-access',
              'refresh_token': 'refresh-2',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path == '/api/atprotocol/session') {
          sessionCalls += 1;
          expect(request.headers['authorization'], 'Bearer fresh-aip-access');
          return http.Response(
            json.encode(_sessionResponseBody(_pdsJwt(clientId: 'client-1'))),
            200,
          );
        }

        return http.Response('unexpected request', 500);
      });

      final repository = AuthRepositoryImpl(
        secureStorage: storage,
        httpClient: client,
        logger: SparkLogger(name: 'AuthRepositoryTest'),
      );

      await repository.initializationComplete;

      final firstRefresh = repository.refreshToken();
      await tokenRequestStarted.future;
      final secondRefresh = repository.refreshToken();

      await Future<void>.delayed(Duration.zero);
      releaseTokenRefresh.complete();

      final results = await Future.wait([firstRefresh, secondRefresh]);

      expect(results, everyElement(isTrue));
      expect(tokenCalls, 1);
      expect(sessionCalls, 1);
    });

    test('logout invalidates an in-flight refresh', () async {
      final storage = _InMemoryStorage();
      await _storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
            clientSecret: 'secret-1',
          ),
          aipGrant: AipGrant(
            credentialsJson: oauth2.Credentials(
              'expired-aip-access',
              refreshToken: 'refresh-1',
              tokenEndpoint: Uri.parse('https://auth.sprk.so/oauth/token'),
              expiration: DateTime.utc(2020, 1, 1),
            ).toJson(),
          ),
          pdsSessionCache: _pdsSessionCache(
            accessToken: _pdsJwt(clientId: 'client-1'),
            expiresAt: DateTime.utc(2030, 1, 1),
          ),
        ),
      );

      final tokenRequestStarted = Completer<void>();
      final releaseTokenRefresh = Completer<void>();
      var tokenCalls = 0;
      var sessionCalls = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/oauth/token') {
          tokenCalls += 1;
          if (!tokenRequestStarted.isCompleted) {
            tokenRequestStarted.complete();
          }
          await releaseTokenRefresh.future;
          return http.Response(
            json.encode({
              'access_token': 'fresh-aip-access',
              'refresh_token': 'refresh-2',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path == '/api/atprotocol/session') {
          sessionCalls += 1;
          return http.Response(
            json.encode(_sessionResponseBody(_pdsJwt(clientId: 'client-1'))),
            200,
          );
        }

        return http.Response('unexpected request', 500);
      });

      final repository = AuthRepositoryImpl(
        secureStorage: storage,
        httpClient: client,
        logger: SparkLogger(name: 'AuthRepositoryTest'),
      );

      await repository.initializationComplete;

      final refreshFuture = repository.refreshToken();
      await tokenRequestStarted.future;
      final logoutFuture = repository.logout();

      await Future<void>.delayed(Duration.zero);
      releaseTokenRefresh.complete();

      final refreshed = await refreshFuture;
      await logoutFuture;

      expect(refreshed, isFalse);
      expect(tokenCalls, 1);
      expect(sessionCalls, 0);
      expect(repository.isAuthenticated, isFalse);

      final savedSnapshot = AuthSnapshot.fromJsonString(
        (await storage.getString(StorageKeys.account))!,
      );
      expect(savedSnapshot.aipClientRegistration?.clientId, 'client-1');
      expect(savedSnapshot.aipGrant, isNull);
      expect(savedSnapshot.pdsSessionCache, isNull);
    });

    test('validateSession reboots from AIP after direct PDS failure', () async {
      final storage = _InMemoryStorage();
      await _storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
          ),
          aipGrant: AipGrant(
            credentialsJson: oauth2.Credentials(
              'aip-access',
              expiration: DateTime.utc(2030, 1, 1),
            ).toJson(),
          ),
          pdsSessionCache: _pdsSessionCache(
            accessToken: _pdsJwt(clientId: 'client-1'),
            expiresAt: DateTime.utc(2030, 1, 1),
          ),
        ),
      );

      var sessionCalls = 0;
      var fetchCalls = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/api/atprotocol/session') {
          sessionCalls += 1;
          return http.Response(
            json.encode(_sessionResponseBody(_pdsJwt(clientId: 'client-1'))),
            200,
          );
        }

        return http.Response('unexpected request', 500);
      });

      final repository = AuthRepositoryImpl(
        secureStorage: storage,
        httpClient: client,
        logger: SparkLogger(name: 'AuthRepositoryTest'),
        fetchSessionInfo: (_) async {
          fetchCalls += 1;
          if (fetchCalls == 1) {
            throw Exception('Unauthorized');
          }

          return (did: 'did:plc:test', handle: 'updated.sprk.so');
        },
      );

      await repository.initializationComplete;
      final isValid = await repository.validateSession();

      expect(isValid, isTrue);
      expect(fetchCalls, 2);
      expect(sessionCalls, 1);
      expect(repository.handle, 'updated.sprk.so');
    });

    test(
      'logout clears active auth state but preserves registration',
      () async {
        final storage = _InMemoryStorage();
        await _storeSnapshot(
          storage,
          AuthSnapshot(
            aipClientRegistration: const AipClientRegistration(
              clientId: 'client-1',
              clientSecret: 'secret-1',
            ),
            aipGrant: AipGrant(
              credentialsJson: oauth2.Credentials(
                'aip-access',
                expiration: DateTime.utc(2030, 1, 1),
              ).toJson(),
            ),
            pdsSessionCache: _pdsSessionCache(
              accessToken: _pdsJwt(clientId: 'client-1'),
              expiresAt: DateTime.utc(2030, 1, 1),
            ),
          ),
        );

        final repository = AuthRepositoryImpl(
          secureStorage: storage,
          httpClient: MockClient((_) async => http.Response('unexpected', 500)),
          logger: SparkLogger(name: 'AuthRepositoryTest'),
        );

        await repository.initializationComplete;
        await repository.logout();

        expect(repository.isAuthenticated, isFalse);

        final savedSnapshot = AuthSnapshot.fromJsonString(
          (await storage.getString(StorageKeys.account))!,
        );
        expect(savedSnapshot.aipClientRegistration?.clientId, 'client-1');
        expect(savedSnapshot.aipGrant, isNull);
        expect(savedSnapshot.pdsSessionCache, isNull);
      },
    );

    test(
      'initiateOAuth and completeOAuth bootstrap a direct PDS session',
      () async {
        final storage = _InMemoryStorage();
        var registrationCalls = 0;
        var tokenCalls = 0;
        var sessionCalls = 0;

        final client = MockClient((request) async {
          switch (request.url.path) {
            case '/.well-known/oauth-authorization-server':
              return http.Response(
                json.encode({
                  'authorization_endpoint':
                      'https://auth.sprk.so/oauth/authorize',
                  'token_endpoint': 'https://auth.sprk.so/oauth/token',
                  'registration_endpoint':
                      'https://auth.sprk.so/oauth/clients/register',
                }),
                200,
              );
            case '/oauth/clients/register':
              registrationCalls += 1;
              final registrationBody =
                  json.decode(request.body) as Map<String, dynamic>;
              expect(
                registrationBody['grant_types'],
                containsAll(<String>['authorization_code', 'refresh_token']),
              );
              return http.Response(
                json.encode({
                  'client_id': 'client-1',
                  'client_secret': 'secret-1',
                  'registration_access_token': 'reg-token',
                }),
                201,
              );
            case '/oauth/token':
              tokenCalls += 1;
              return http.Response(
                json.encode({
                  'access_token': 'aip-access',
                  'refresh_token': 'aip-refresh',
                  'token_type': 'Bearer',
                  'expires_in': 3600,
                }),
                200,
                headers: {'content-type': 'application/json'},
              );
            case '/api/atprotocol/session':
              sessionCalls += 1;
              return http.Response(
                json.encode(
                  _sessionResponseBody(_pdsJwt(clientId: 'client-1')),
                ),
                200,
              );
            default:
              return http.Response('unexpected request', 500);
          }
        });

        final repository = AuthRepositoryImpl(
          secureStorage: storage,
          httpClient: client,
          logger: SparkLogger(name: 'AuthRepositoryTest'),
        );

        await repository.initializationComplete;
        final authUrl = await repository.initiateOAuth('alice.sprk.so');
        final authUri = Uri.parse(authUrl);

        expect(authUri.queryParameters['login_hint'], 'alice.sprk.so');
        expect(authUri.queryParameters['code_challenge'], isNotEmpty);
        expect(authUri.queryParameters['state'], isNotEmpty);

        final callbackUrl = Uri.parse(_redirectUri)
            .replace(
              queryParameters: {
                'code': 'code-123',
                'state': authUri.queryParameters['state']!,
              },
            )
            .toString();
        final result = await repository.completeOAuth(callbackUrl);

        expect(result.isSuccess, isTrue);
        expect(repository.isAuthenticated, isTrue);
        expect(registrationCalls, 1);
        expect(tokenCalls, 1);
        expect(sessionCalls, 1);
      },
    );

    test('initiateOAuthWithService omits login_hint in AIP mode', () async {
      final storage = _InMemoryStorage();
      final client = MockClient((request) async {
        switch (request.url.path) {
          case '/.well-known/oauth-authorization-server':
            return http.Response(
              json.encode({
                'authorization_endpoint':
                    'https://auth.sprk.so/oauth/authorize',
                'token_endpoint': 'https://auth.sprk.so/oauth/token',
                'registration_endpoint':
                    'https://auth.sprk.so/oauth/clients/register',
              }),
              200,
            );
          case '/oauth/clients/register':
            return http.Response(json.encode({'client_id': 'client-1'}), 201);
          default:
            return http.Response('unexpected request', 500);
        }
      });

      final repository = AuthRepositoryImpl(
        secureStorage: storage,
        httpClient: client,
        logger: SparkLogger(name: 'AuthRepositoryTest'),
      );

      await repository.initializationComplete;
      final authUrl = await repository.initiateOAuthWithService('pds.sprk.so');

      expect(
        Uri.parse(authUrl).queryParameters.containsKey('login_hint'),
        isFalse,
      );
    });
  });
}

const String _redirectUri = 'sprk://oauth-callback';

Future<void> _storeSnapshot(
  _InMemoryStorage storage,
  AuthSnapshot snapshot,
) async {
  await storage.setString(StorageKeys.account, snapshot.toJsonString());
}

PdsSessionCache _pdsSessionCache({
  required String accessToken,
  required DateTime expiresAt,
}) {
  return buildPdsSessionCacheFromAipResponse(
    AipAtprotocolSessionResponse.fromJson(
      _sessionResponseBody(accessToken)
        ..['expires_at'] = expiresAt.millisecondsSinceEpoch ~/ 1000,
    ),
  );
}

Map<String, dynamic> _sessionResponseBody(String accessToken) {
  return {
    'did': 'did:plc:test',
    'handle': 'test.sprk.so',
    'access_token': accessToken,
    'token_type': 'dpop',
    'scopes': ['atproto'],
    'pds_endpoint': 'https://pds.sprk.so',
    'dpop_key': 'did:key:test',
    'dpop_jwk': {
      'kty': 'EC',
      'crv': 'P-256',
      'x': _base64UrlNoPadding(List<int>.generate(32, (index) => index + 1)),
      'y': _base64UrlNoPadding(List<int>.generate(32, (index) => index + 33)),
      'd': _base64UrlNoPadding(List<int>.generate(32, (index) => index + 65)),
    },
    'expires_at': DateTime.utc(2030, 1, 1).millisecondsSinceEpoch ~/ 1000,
  };
}

String _pdsJwt({required String clientId, DateTime? exp}) {
  final payload = <String, Object?>{
    'sub': 'did:plc:test',
    'exp': (exp ?? DateTime.utc(2030, 1, 1)).millisecondsSinceEpoch ~/ 1000,
    'iat': DateTime.utc(2029, 1, 1).millisecondsSinceEpoch ~/ 1000,
    'scope': 'atproto',
    'client_id': clientId,
  };

  return '${_base64UrlNoPadding(utf8.encode(json.encode({'alg': 'none', 'typ': 'JWT'})))}.${_base64UrlNoPadding(utf8.encode(json.encode(payload)))}.signature';
}

String _base64UrlNoPadding(List<int> value) {
  return base64Url.encode(value).replaceAll('=', '');
}

class _InMemoryStorage implements LocalStorageInterface {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  Future<void> clear() async {
    _values.clear();
  }

  @override
  Future<bool> containsKey(String key) async => _values.containsKey(key);

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => _values[key] as double?;

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<T?> getObject<T>(String key) async => _values[key] as T?;

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<List<String>?> getStringList(String key) async =>
      (_values[key] as List<dynamic>?)?.cast<String>();

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _values[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _values[key] = value;
  }

  @override
  Future<void> setObject<T>(String key, T value) async {
    _values[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _values[key] = List<String>.from(value);
  }
}
