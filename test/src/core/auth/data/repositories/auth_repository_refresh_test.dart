import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:spark/src/core/auth/data/models/auth_snapshot.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';

import '../../../../../support/in_memory_storage.dart';
import 'auth_repository_test_support.dart';

void main() {
  group('AuthRepositoryImpl token refresh', () {
    test('refreshes AIP grant before fetching a new PDS session', () async {
      final storage = InMemoryStorage();
      await storeSnapshot(
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
              scopes: currentAipScopes,
            ).toJson(),
          ),
          pdsSessionCache: pdsSessionCache(
            accessToken: pdsJwt(clientId: 'client-1'),
            expiresAt: DateTime.utc(2030, 1, 1),
          ),
        ),
      );

      var tokenCalls = 0;
      var sessionCalls = 0;
      final client = CloseAwareMockClient((request) async {
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
            json.encode(sessionResponseBody(pdsJwt(clientId: 'client-1'))),
            200,
          );
        }

        return http.Response('unexpected request', 500);
      });

      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: client,
      );

      await repository.initializationComplete;
      final refreshed = await repository.refreshToken();

      expect(refreshed, isTrue);
      expect(client.isClosed, isFalse);
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
    });

    test('failure preserves the saved auth snapshot', () async {
      final storage = InMemoryStorage();
      await storeSnapshot(
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
              scopes: currentAipScopes,
            ).toJson(),
          ),
          pdsSessionCache: pdsSessionCache(
            accessToken: pdsJwt(clientId: 'client-1'),
            expiresAt: DateTime.utc(2030, 1, 1),
          ),
        ),
      );
      final storedBefore = AuthSnapshot.fromJsonString(
        (await storage.getString(StorageKeys.account))!,
      );

      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: MockClient(
          (_) async => http.Response('temporary outage', 503),
        ),
      );

      await repository.initializationComplete;
      final refreshed = await repository.refreshToken();

      expect(refreshed, isFalse);
      expect(repository.isAuthenticated, isFalse);
      final savedSnapshot = AuthSnapshot.fromJsonString(
        (await storage.getString(StorageKeys.account))!,
      );
      expect(savedSnapshot.aipClientRegistration?.clientId, 'client-1');
      expect(savedSnapshot.aipGrant?.credentialsJson, contains('refresh-1'));
      expect(
        savedSnapshot.pdsSessionCache?.did,
        storedBefore.pdsSessionCache?.did,
      );
    });

    test('concurrent calls share one in-flight refresh', () async {
      final storage = InMemoryStorage();
      await storeSnapshot(
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
              scopes: currentAipScopes,
            ).toJson(),
          ),
          pdsSessionCache: pdsSessionCache(
            accessToken: pdsJwt(clientId: 'client-1'),
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
            json.encode(sessionResponseBody(pdsJwt(clientId: 'client-1'))),
            200,
          );
        }

        return http.Response('unexpected request', 500);
      });

      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: client,
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
  });
}
