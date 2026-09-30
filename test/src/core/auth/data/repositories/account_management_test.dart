import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spark/src/core/auth/data/models/auth_snapshot.dart';
import 'package:spark/src/core/auth/data/repositories/account_management.dart';

import '../../../../../support/in_memory_storage.dart';
import 'auth_repository_test_support.dart';

void main() {
  group('resolveAccountManagementUri', () {
    test(
      'discovers the account UI on a separate authorization server',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'https://pds.example.com/.well-known/oauth-protected-resource',
          );
          expect(request.headers, isNot(contains('authorization')));
          return _metadataResponse(['https://accounts.example.com']);
        });
        addTearDown(client.close);

        final uri = await resolveAccountManagementUri(
          client,
          pdsEndpoint: 'https://pds.example.com',
          did: 'did:plc:test',
        );

        expect(uri.origin, 'https://accounts.example.com');
        expect(uri.pathSegments, ['account', 'u', 'did:plc:test', 'manage']);
      },
    );

    test('supports a self-hosted authorization server with a port', () async {
      final client = MockClient(
        (_) async => _metadataResponse(['https://pds.example.com:8443/']),
      );
      addTearDown(client.close);

      final uri = await resolveAccountManagementUri(
        client,
        pdsEndpoint: 'https://pds.example.com:8443/',
        did: 'did:plc:test',
      );

      expect(uri.origin, 'https://pds.example.com:8443');
      expect(uri.pathSegments, ['account', 'u', 'did:plc:test', 'manage']);
    });

    test(
      'preserves a did:web identifier as one encoded path segment',
      () async {
        const did = 'did:web:example.com%3A8443:users:alice';
        final client = MockClient(
          (_) async => _metadataResponse(['https://accounts.example.com']),
        );
        addTearDown(client.close);

        final uri = await resolveAccountManagementUri(
          client,
          pdsEndpoint: 'https://pds.example.com',
          did: did,
        );

        expect(uri.pathSegments, ['account', 'u', did, 'manage']);
        expect(
          uri.toString(),
          'https://accounts.example.com/account/u/'
          'did%3Aweb%3Aexample.com%253A8443%3Ausers%3Aalice/manage',
        );
      },
    );

    final invalidServers = <String, List<Object?>>{
      'no authorization server': [],
      'multiple authorization servers': [
        'https://first.example.com',
        'https://second.example.com',
      ],
      'non-string authorization server': [42],
      'HTTP origin': ['http://accounts.example.com'],
      'origin with a path': ['https://accounts.example.com/oauth'],
      'origin with credentials': ['https://user:password@accounts.example.com'],
      'origin with a query': ['https://accounts.example.com?next=elsewhere'],
      'origin with a fragment': ['https://accounts.example.com#account'],
    };
    for (final entry in invalidServers.entries) {
      test('rejects ${entry.key}', () async {
        final client = MockClient((_) async => _metadataResponse(entry.value));
        addTearDown(client.close);

        await expectLater(
          resolveAccountManagementUri(
            client,
            pdsEndpoint: 'https://pds.example.com',
            did: 'did:plc:test',
          ),
          throwsFormatException,
        );
      });
    }

    test(
      'reports failed metadata requests instead of guessing a URL',
      () async {
        final client = MockClient(
          (_) async => http.Response('unavailable', 503),
        );
        addTearDown(client.close);

        await expectLater(
          resolveAccountManagementUri(
            client,
            pdsEndpoint: 'https://pds.example.com',
            did: 'did:plc:test',
          ),
          throwsA(isA<http.ClientException>()),
        );
      },
    );
  });

  group('AuthRepositoryImpl.getAccountManagementUri', () {
    test('uses the restored account PDS and DID', () async {
      final storage = InMemoryStorage();
      await _storeSignedInAccount(storage);
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://pds.sprk.so/.well-known/oauth-protected-resource',
        );
        return _metadataResponse(['https://accounts.example.com']);
      });
      addTearDown(client.close);
      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: client,
      );

      final uri = await repository.getAccountManagementUri();

      expect(repository.isAuthenticated, isTrue);
      expect(uri.origin, 'https://accounts.example.com');
      expect(uri.pathSegments, ['account', 'u', 'did:plc:test', 'manage']);
    });

    test('rejects a signed-out account without making a request', () async {
      final client = MockClient((_) async {
        fail('Signed-out accounts must not start discovery');
      });
      addTearDown(client.close);
      final repository = createAuthRepository(
        secureStorage: InMemoryStorage(),
        httpClient: client,
      );

      await expectLater(repository.getAccountManagementUri(), throwsStateError);
    });

    test('discards discovery completed after logout', () async {
      final storage = InMemoryStorage();
      await _storeSignedInAccount(storage);
      final requestStarted = Completer<void>();
      final response = Completer<http.Response>();
      final client = MockClient((_) {
        requestStarted.complete();
        return response.future;
      });
      addTearDown(client.close);
      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: client,
      );

      final result = repository.getAccountManagementUri();
      final expectation = expectLater(result, throwsStateError);
      await requestStarted.future;
      await repository.logout();
      response.complete(_metadataResponse(['https://accounts.example.com']));

      await expectation;
      expect(repository.isAuthenticated, isFalse);
    });
  });
}

http.Response _metadataResponse(List<Object?> authorizationServers) {
  return http.Response(
    jsonEncode({'authorization_servers': authorizationServers}),
    200,
    headers: {'content-type': 'application/json'},
  );
}

Future<void> _storeSignedInAccount(InMemoryStorage storage) {
  return storeSnapshot(
    storage,
    AuthSnapshot(
      pdsSessionCache: pdsSessionCache(
        accessToken: pdsJwt(clientId: 'client-1'),
        expiresAt: DateTime.utc(2030, 1, 1),
      ),
    ),
  );
}
