import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:spark/src/core/auth/data/models/account.dart';
import 'package:spark/src/core/auth/data/models/auth_snapshot.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';

import '../../../../../support/in_memory_storage.dart';
import 'auth_repository_test_support.dart';

void main() {
  group('AuthRepositoryImpl startup', () {
    test('valid cached PDS session does not call AIP', () async {
      final storage = InMemoryStorage();
      await storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
          ),
          pdsSessionCache: pdsSessionCache(
            accessToken: pdsJwt(clientId: 'client-1'),
            expiresAt: DateTime.utc(2030, 1, 1),
          ),
        ),
      );

      var networkCalls = 0;
      final client = MockClient((request) async {
        networkCalls += 1;
        return http.Response('unexpected request', 500);
      });

      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: client,
      );

      await repository.initializationComplete;

      expect(repository.isAuthenticated, isTrue);
      expect(repository.did, 'did:plc:test');
      expect(networkCalls, 0);
    });

    test('stale cached PDS scope refreshes via AIP', () async {
      final storage = InMemoryStorage();
      await storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
          ),
          aipGrant: AipGrant(
            credentialsJson: oauth2.Credentials(
              'aip-access',
              expiration: DateTime.utc(2030, 1, 1),
              scopes: currentAipScopes,
            ).toJson(),
          ),
          pdsSessionCache: pdsSessionCache(
            accessToken: pdsJwt(clientId: 'client-1'),
            expiresAt: DateTime.utc(2030, 1, 1),
            scopes: const ['atproto'],
          ),
        ),
      );

      var sessionCalls = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/api/atprotocol/session') {
          sessionCalls += 1;
          expect(request.headers['authorization'], 'Bearer aip-access');
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

      expect(repository.isAuthenticated, isTrue);
      expect(sessionCalls, 1);
    });

    test('legacy account payload is cleared and requires re-login', () async {
      final storage = InMemoryStorage();
      final cache = pdsSessionCache(
        accessToken: pdsJwt(clientId: 'client-1'),
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

      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: MockClient((_) async => http.Response('unexpected', 500)),
      );

      await repository.initializationComplete;

      expect(repository.isAuthenticated, isFalse);
      expect(repository.did, isNull);
      expect(await storage.getString(StorageKeys.account), isNull);
    });

    test('stale cached PDS session refreshes via AIP', () async {
      final storage = InMemoryStorage();
      await storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
          ),
          aipGrant: AipGrant(
            credentialsJson: oauth2.Credentials(
              'aip-access',
              expiration: DateTime.utc(2030, 1, 1),
              scopes: currentAipScopes,
            ).toJson(),
          ),
          pdsSessionCache: pdsSessionCache(
            accessToken: pdsJwt(
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

      expect(repository.isAuthenticated, isTrue);
      expect(repository.pdsEndpoint, 'https://pds.sprk.so');
      expect(sessionCalls, 1);
    });

    test('refresh failure preserves the saved auth snapshot', () async {
      final storage = InMemoryStorage();
      await storeSnapshot(
        storage,
        AuthSnapshot(
          aipClientRegistration: const AipClientRegistration(
            clientId: 'client-1',
          ),
          aipGrant: AipGrant(
            credentialsJson: oauth2.Credentials(
              'aip-access',
              expiration: DateTime.utc(2030, 1, 1),
              scopes: currentAipScopes,
            ).toJson(),
          ),
          pdsSessionCache: pdsSessionCache(
            accessToken: pdsJwt(
              clientId: 'client-1',
              exp: DateTime.utc(2020, 1, 1),
            ),
            expiresAt: DateTime.utc(2020, 1, 1),
          ),
        ),
      );
      final storedBefore = await storage.getString(StorageKeys.account);

      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: MockClient(
          (_) async => http.Response('temporary outage', 503),
        ),
      );

      await repository.initializationComplete;

      expect(repository.isAuthenticated, isFalse);
      expect(repository.handle, isNull);
      expect(repository.lastKnownHandle, 'test.sprk.so');
      expect(await storage.getString(StorageKeys.account), storedBefore);
    });
  });
}
