import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spark/src/core/auth/data/models/auth_snapshot.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';

import '../../../../../support/in_memory_storage.dart';
import 'auth_repository_test_support.dart';

const _expectedAipScope =
    'atproto '
    'include:so.sprk.authFullApp?aud=did:web:api.sprk.so#sprk_appview '
    'include:chat.sprk.authFull?aud=did:web:api.sprk.chat#sprk_chat '
    'include:app.bsky.authViewAll?aud=did:web:api.bsky.app#bsky_appview '
    'include:app.bsky.authCreatePosts?aud=did:web:api.bsky.app#bsky_appview '
    'include:app.bsky.authDeleteContent?aud=did:web:api.bsky.app#bsky_appview '
    'blob:*/* '
    'repo:app.bsky.feed.like '
    'repo:app.bsky.feed.repost '
    'repo:app.bsky.graph.follow '
    'rpc:com.atproto.repo.uploadBlob?aud=* '
    'rpc:com.atproto.moderation.createReport?aud=*';

void main() {
  group('AuthRepositoryImpl OAuth bootstrap', () {
    test(
      'initiateOAuth and completeOAuth create a direct PDS session',
      () async {
        final storage = InMemoryStorage();
        var registrationCalls = 0;
        var tokenCalls = 0;
        var sessionCalls = 0;

        final client = MockClient((request) async {
          switch (request.url.path) {
            case '/.well-known/oauth-authorization-server':
              return _authorizationServerMetadata();
            case '/oauth/clients/register':
              registrationCalls += 1;
              final registrationBody =
                  json.decode(request.body) as Map<String, dynamic>;
              expect(
                registrationBody['grant_types'],
                containsAll(<String>['authorization_code', 'refresh_token']),
              );
              expect(registrationBody['scope'] as String, _expectedAipScope);
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
                json.encode(sessionResponseBody(pdsJwt(clientId: null))),
                200,
              );
            default:
              return http.Response('unexpected request', 500);
          }
        });

        final repository = createAuthRepository(
          secureStorage: storage,
          httpClient: client,
        );

        await repository.initializationComplete;
        final authUrl = await repository.initiateOAuth('alice.sprk.so');
        final authUri = Uri.parse(authUrl);

        expect(authUri.queryParameters['login_hint'], 'alice.sprk.so');
        expect(authUri.queryParameters['code_challenge'], isNotEmpty);
        expect(authUri.queryParameters['state'], isNotEmpty);
        expect(authUri.queryParameters['scope'], _expectedAipScope);

        final callbackUrl = Uri.parse(redirectUri)
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

    test('completeOAuth surfaces the AIP bootstrap failure reason', () async {
      final storage = InMemoryStorage();

      final client = MockClient((request) async {
        switch (request.url.path) {
          case '/.well-known/oauth-authorization-server':
            return _authorizationServerMetadata();
          case '/oauth/clients/register':
            return http.Response(
              json.encode({
                'client_id': 'client-1',
                'client_secret': 'secret-1',
              }),
              201,
            );
          case '/oauth/token':
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
            return http.Response(
              json.encode({
                'error': 'invalid_dpop_proof',
                'error_description': 'DPoP proof is missing ath',
              }),
              400,
            );
          default:
            return http.Response('unexpected request', 500);
        }
      });

      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: client,
      );

      await repository.initializationComplete;
      final authUri = Uri.parse(await repository.initiateOAuth('alice'));
      final callbackUrl = Uri.parse(redirectUri)
          .replace(
            queryParameters: {
              'code': 'code-123',
              'state': authUri.queryParameters['state']!,
            },
          )
          .toString();

      final result = await repository.completeOAuth(callbackUrl);

      expect(result.isSuccess, isFalse);
      expect(
        result.error,
        'Failed to bootstrap a direct PDS session from AIP: '
        'AIP session request failed: DPoP proof is missing ath.',
      );
    });

    test('stale cached client scope causes re-registration', () async {
      final storage = InMemoryStorage();
      await storeSnapshot(
        storage,
        const AuthSnapshot(
          aipClientRegistration: AipClientRegistration(
            clientId: 'stale-client',
            clientSecret: 'secret-1',
            scope: 'atproto',
          ),
        ),
      );

      var registrationCalls = 0;
      final client = MockClient((request) async {
        switch (request.url.path) {
          case '/.well-known/oauth-authorization-server':
            return _authorizationServerMetadata();
          case '/oauth/clients/register':
            registrationCalls += 1;
            final registrationBody =
                json.decode(request.body) as Map<String, dynamic>;
            expect(registrationBody['scope'] as String, _expectedAipScope);
            return http.Response(
              json.encode({
                'client_id': 'client-2',
                'client_secret': 'secret-2',
              }),
              201,
            );
          default:
            return http.Response('unexpected request', 500);
        }
      });

      final repository = createAuthRepository(
        secureStorage: storage,
        httpClient: client,
      );

      await repository.initializationComplete;
      final authUrl = await repository.initiateOAuth('alice.sprk.so');
      final authUri = Uri.parse(authUrl);

      expect(registrationCalls, 1);
      expect(authUri.queryParameters['scope'], _expectedAipScope);

      final savedSnapshot = AuthSnapshot.fromJsonString(
        (await storage.getString(StorageKeys.account))!,
      );
      expect(savedSnapshot.aipClientRegistration?.clientId, 'client-2');
      expect(savedSnapshot.aipClientRegistration?.scope, _expectedAipScope);
    });

    test(
      'initiateOAuthWithoutLoginHint sends blank login_hint in AIP mode',
      () async {
        final storage = InMemoryStorage();
        final client = MockClient((request) async {
          switch (request.url.path) {
            case '/.well-known/oauth-authorization-server':
              return _authorizationServerMetadata();
            case '/oauth/clients/register':
              return http.Response(json.encode({'client_id': 'client-1'}), 201);
            default:
              return http.Response('unexpected request', 500);
          }
        });

        final repository = createAuthRepository(
          secureStorage: storage,
          httpClient: client,
        );

        await repository.initializationComplete;
        final authUrl = await repository.initiateOAuthWithoutLoginHint();

        final authUri = Uri.parse(authUrl);

        expect(authUri.queryParameters.containsKey('login_hint'), isTrue);
        expect(authUri.queryParameters['login_hint'], isEmpty);
      },
    );
  });
}

http.Response _authorizationServerMetadata() {
  return http.Response(
    json.encode({
      'authorization_endpoint': 'https://auth.sprk.so/oauth/authorize',
      'token_endpoint': 'https://auth.sprk.so/oauth/token',
      'registration_endpoint': 'https://auth.sprk.so/oauth/clients/register',
    }),
    200,
  );
}
