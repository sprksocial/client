import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/network/atproto/data/repositories/bluesky_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

void main() {
  test('profile data is absent when authentication is unavailable', () async {
    final repository = _repository(
      auth: _FakeAuthRepository(did: null, atproto: null),
    );

    expect(await repository.getProfileRecord(), isNull);
    expect(await repository.getAvatarUrl(), isNull);
  });

  test('getProfileRecord parses the stored Bluesky profile', () async {
    final transport = _Transport(
      (_) => {
        'uri': 'at://did:plc:viewer/app.bsky.actor.profile/self',
        'cid': 'profile-cid',
        'value': {
          r'$type': 'app.bsky.actor.profile',
          'displayName': 'Viewer',
          'description': 'From Bluesky',
        },
      },
    );
    final repository = _repository(
      auth: _FakeAuthRepository(
        did: 'did:plc:viewer',
        atproto: _anonymousClient(transport),
      ),
    );

    final profile = await repository.getProfileRecord();

    expect(profile?.displayName, 'Viewer');
    expect(profile?.description, 'From Bluesky');
  });

  test('getProfileRecord treats record-not-found as absent', () async {
    final transport = _Transport(
      (_) => {'error': 'RecordNotFound', 'message': 'record not found'},
      statusCode: 404,
    );
    final repository = _repository(
      auth: _FakeAuthRepository(
        did: 'did:plc:viewer',
        atproto: _anonymousClient(transport),
      ),
    );

    expect(await repository.getProfileRecord(), isNull);
  });

  test('getProfileRecord preserves service failures', () async {
    final transport = _Transport(
      (_) => {'error': 'InternalServerError', 'message': 'unavailable'},
      statusCode: 500,
    );
    final repository = _repository(
      auth: _FakeAuthRepository(
        did: 'did:plc:viewer',
        atproto: _anonymousClient(transport),
      ),
    );

    await expectLater(repository.getProfileRecord(), throwsA(anything));
  });

  test('getAvatarUrl uses the OAuth-backed profile endpoint', () async {
    final transport = _Transport(
      (_) => {
        'did': 'did:plc:viewer',
        'handle': 'viewer.test',
        'avatar': 'https://cdn.test/avatar.jpg',
      },
    );
    final repository = _repository(
      auth: _FakeAuthRepository(
        did: 'did:plc:viewer',
        atproto: PoptartClient.fromOAuthSession(_oauthSession()),
      ),
      oauthClient: (_) => _anonymousClient(transport),
    );

    expect(await repository.getAvatarUrl(), 'https://cdn.test/avatar.jpg');
    expect(
      transport.requests.single.url.queryParameters['actor'],
      'did:plc:viewer',
    );
  });

  test('getFollows uses the public AppView when OAuth is available', () async {
    final transport = _Transport(
      (_) => {
        'subject': {'did': 'did:plc:viewer', 'handle': 'viewer.test'},
        'follows': [
          {'did': 'did:plc:alice', 'handle': 'alice.test'},
        ],
        'cursor': 'next-page',
      },
    );
    final appView = Uri.parse(AppConfig.bskyAppViewUrl);
    Uri? requestedAppView;
    final repository = _repository(
      auth: _FakeAuthRepository(
        did: 'did:plc:viewer',
        atproto: PoptartClient.fromOAuthSession(_oauthSession()),
      ),
      oauthClient: (_) => throw StateError('OAuth PDS client was used'),
      anonymousClient: (configuredAppView) {
        requestedAppView = configuredAppView;
        return _anonymousClient(transport, service: configuredAppView.host);
      },
    );

    final result = await repository.getFollows(cursor: 'page-1');

    expect(result.subject.did, 'did:plc:viewer');
    expect(result.follows.single.did, 'did:plc:alice');
    expect(result.cursor, 'next-page');
    final request = transport.requests.single;
    expect(request.url.queryParameters['actor'], 'did:plc:viewer');
    expect(request.url.queryParameters['cursor'], 'page-1');
    expect(request.url.queryParameters['limit'], '100');
    expect(request.url.host, appView.host);
    expect(requestedAppView, appView);
  });
}

BlueskyRepositoryImpl _repository({
  required _FakeAuthRepository auth,
  PoptartClient Function(OAuthSession session)? oauthClient,
  PoptartClient Function(Uri appView)? anonymousClient,
}) {
  return BlueskyRepositoryImpl(
    auth,
    logger: SparkLogger(name: 'BlueskyRepositoryTest'),
    oauthClient: oauthClient,
    anonymousClient: anonymousClient,
  );
}

PoptartClient _anonymousClient(
  _Transport transport, {
  String service = 'pds.test',
}) => PoptartClient.anonymous(service: service, getClient: transport.get);

OAuthSession _oauthSession() => restoreOAuthSession(
  accessToken: 'opaque-access-token',
  refreshToken: 'opaque-refresh-token',
  scope: 'atproto',
  expiresAt: DateTime.utc(2030),
  sub: 'did:plc:viewer',
  clientId: 'https://spark.test/client-metadata.json',
  pdsEndpoint: 'pds.test',
  publicKey: 'unused-public-key',
  privateKey: 'unused-private-key',
);

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.did, required this.atproto});

  @override
  final String? did;

  @override
  final PoptartClient? atproto;

  @override
  Future<void> get initializationComplete => Future<void>.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transport {
  _Transport(this.response, {this.statusCode = 200});

  final Map<String, dynamic> Function(Uri uri) response;
  final int statusCode;
  final List<http.Request> requests = [];

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    final request = http.Request('GET', uri)
      ..headers.addAll(headers ?? const {});
    requests.add(request);
    return http.Response(
      jsonEncode(response(uri)),
      statusCode,
      headers: const {'content-type': 'application/json'},
      request: request,
    );
  }
}
