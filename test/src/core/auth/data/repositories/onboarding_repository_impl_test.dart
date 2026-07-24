import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

void main() {
  final now = DateTime.utc(2026, 7, 22, 12, 34, 56);

  test(
    'profile lookups return absent when authentication is unavailable',
    () async {
      final repository = _repository(
        auth: _FakeAuthRepository(did: null, atproto: null),
        now: now,
      );

      expect(await repository.hasSparkProfile(), isFalse);
      expect(await repository.getBskyProfile(), isNull);
      expect(await repository.getBskyAvatarUrl(), isNull);
    },
  );

  test('hasSparkProfile queries the current Spark profile record', () async {
    final transport = _Transport(
      (_) => {
        'uri': 'at://did:plc:viewer/so.sprk.actor.profile/self',
        'cid': 'profile-cid',
        'value': {r'$type': 'so.sprk.actor.profile', 'displayName': 'Viewer'},
      },
    );
    final repository = _repository(
      auth: _FakeAuthRepository(
        did: 'did:plc:viewer',
        atproto: _anonymousClient(transport),
      ),
      now: now,
    );

    expect(await repository.hasSparkProfile(), isTrue);

    final request = transport.requests.single;
    expect(request.url.path, '/xrpc/com.atproto.repo.getRecord');
    expect(request.url.queryParameters, {
      'repo': 'did:plc:viewer',
      'collection': 'so.sprk.actor.profile',
      'rkey': 'self',
    });
  });

  test('hasSparkProfile treats record-not-found as no profile', () async {
    final transport = _Transport(
      (_) => {'error': 'RecordNotFound', 'message': 'record not found'},
      statusCode: 404,
    );
    final repository = _repository(
      auth: _FakeAuthRepository(
        did: 'did:plc:viewer',
        atproto: _anonymousClient(transport),
      ),
      now: now,
    );

    expect(await repository.hasSparkProfile(), isFalse);
  });

  test('getBskyProfile parses the stored Bluesky profile record', () async {
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
      now: now,
    );

    final profile = await repository.getBskyProfile();

    expect(profile?.displayName, 'Viewer');
    expect(profile?.description, 'From Bluesky');
  });

  test(
    'getBskyAvatarUrl uses the OAuth-backed Bluesky profile endpoint',
    () async {
      final transport = _Transport(
        (_) => {
          'did': 'did:plc:viewer',
          'handle': 'viewer.test',
          'avatar': 'https://cdn.test/avatar.jpg',
        },
      );
      final authClient = PoptartClient.fromOAuthSession(_oauthSession());
      final repository = _repository(
        auth: _FakeAuthRepository(did: 'did:plc:viewer', atproto: authClient),
        now: now,
        oauthClient: (_) => _anonymousClient(transport),
      );

      expect(
        await repository.getBskyAvatarUrl(),
        'https://cdn.test/avatar.jpg',
      );
      expect(
        transport.requests.single.url.queryParameters['actor'],
        'did:plc:viewer',
      );
    },
  );

  test(
    'createSparkProfile uploads byte avatars and writes the profile record',
    () async {
      final repo = _FakeRepoRepository();
      final repository = _repository(
        auth: _FakeAuthRepository(did: 'did:plc:viewer', atproto: null),
        repo: repo,
        now: now,
      );
      final avatar = Uint8List.fromList([1, 2, 3]);

      await repository.createSparkProfile(
        displayName: 'Viewer',
        description: 'A profile',
        avatar: avatar,
      );

      expect(repo.uploads.single, avatar);
      final call = repo.createCalls.single;
      expect(call.collection, 'so.sprk.actor.profile');
      expect(call.rkey, 'self');
      expect(call.record, {
        r'$type': 'so.sprk.actor.profile',
        'displayName': 'Viewer',
        'description': 'A profile',
        'avatar': _blobJson(),
      });
    },
  );

  test('createSparkProfile omits an absent avatar without uploading', () async {
    final repo = _FakeRepoRepository();
    final repository = _repository(
      auth: _FakeAuthRepository(did: 'did:plc:viewer', atproto: null),
      repo: repo,
      now: now,
    );

    await repository.createSparkProfile(displayName: 'Viewer', description: '');

    expect(repo.uploads, isEmpty);
    expect(repo.createCalls.single.record, {
      r'$type': 'so.sprk.actor.profile',
      'displayName': 'Viewer',
      'description': '',
    });
  });

  test(
    'createSparkFollow writes the subject with the injected clock',
    () async {
      final repo = _FakeRepoRepository();
      final repository = _repository(
        auth: _FakeAuthRepository(did: 'did:plc:viewer', atproto: null),
        repo: repo,
        now: now,
      );

      await repository.createSparkFollow('did:plc:subject');

      final call = repo.createCalls.single;
      expect(call.collection, 'so.sprk.graph.follow');
      expect(call.record, {
        r'$type': 'so.sprk.graph.follow',
        'subject': 'did:plc:subject',
        'createdAt': now.toIso8601String(),
      });
    },
  );

  test(
    'getBskyFollows maps the Bluesky response and forwards its cursor',
    () async {
      final transport = _Transport(
        (_) => {
          'subject': {'did': 'did:plc:viewer', 'handle': 'viewer.test'},
          'follows': [
            {'did': 'did:plc:alice', 'handle': 'alice.test'},
          ],
          'cursor': 'next-page',
        },
      );
      final repository = _repository(
        auth: _FakeAuthRepository(
          did: 'did:plc:viewer',
          atproto: _anonymousClient(_Transport((_) => const {})),
        ),
        now: now,
        anonymousBskyClient: () => _anonymousClient(transport),
      );

      final result = await repository.getBskyFollows(cursor: 'page-1');

      expect(result.subject.did, 'did:plc:viewer');
      expect(result.follows.single.did, 'did:plc:alice');
      expect(result.cursor, 'next-page');
      final request = transport.requests.single;
      expect(request.url.queryParameters['actor'], 'did:plc:viewer');
      expect(request.url.queryParameters['cursor'], 'page-1');
      expect(request.url.queryParameters['limit'], '100');
    },
  );
}

OnboardingRepositoryImpl _repository({
  required _FakeAuthRepository auth,
  required DateTime now,
  _FakeRepoRepository? repo,
  PoptartClient Function(OAuthSession session)? oauthClient,
  PoptartClient Function()? anonymousBskyClient,
}) {
  return OnboardingRepositoryImpl(
    repoRepository: repo ?? _FakeRepoRepository(),
    authRepository: auth,
    logger: SparkLogger(name: 'OnboardingRepositoryTest'),
    now: () => now,
    oauthClient: oauthClient,
    anonymousBskyClient: anonymousBskyClient,
  );
}

PoptartClient _anonymousClient(_Transport transport) =>
    PoptartClient.anonymous(service: 'pds.test', getClient: transport.get);

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

Map<String, dynamic> _blobJson() => {
  r'$type': 'blob',
  'mimeType': 'image/jpeg',
  'size': 3,
  'ref': {r'$link': 'bafk-avatar'},
};

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

class _FakeRepoRepository implements RepoRepository {
  final List<Uint8List> uploads = [];
  final List<_CreateCall> createCalls = [];

  @override
  Future<Blob> uploadBlob(Uint8List data) async {
    uploads.add(data);
    return Blob.fromJson(_blobJson());
  }

  @override
  Future<RepoStrongRef> createRecord({
    required String collection,
    required Map<String, dynamic> record,
    String? rkey,
    String? repo,
  }) async {
    createCalls.add(
      _CreateCall(collection: collection, record: record, rkey: rkey),
    );
    return RepoStrongRef(
      uri: AtUri.parse('at://did:plc:viewer/$collection/${rkey ?? 'result'}'),
      cid: 'result-cid',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CreateCall {
  const _CreateCall({
    required this.collection,
    required this.record,
    required this.rkey,
  });

  final String collection;
  final Map<String, dynamic> record;
  final String? rkey;
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
