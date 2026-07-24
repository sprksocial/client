import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';

class RepositoryHarness {
  RepositoryHarness({
    bool authenticated = true,
    bool atprotoInitialized = true,
    String? did = 'did:plc:viewer',
    Map<String, dynamic>? getResponse,
  }) : transport = TestTransport() {
    auth = FakeAuthRepository(
      authenticated: authenticated,
      did: did,
      atproto: atprotoInitialized
          ? PoptartClient.anonymous(
              service: 'pds.test',
              getClient: transport.get,
              postClient: transport.post,
            )
          : null,
    );
    repo = FakeRepoRepository();
    sprk = FakeSprkRepository(auth: auth, repo: repo);
    if (atprotoInitialized && getResponse != null) {
      transport.enqueueGet(getResponse);
    }
  }

  final TestTransport transport;
  late final FakeAuthRepository auth;
  late final FakeRepoRepository repo;
  late final FakeSprkRepository sprk;
}

Blob testBlob(String mimeType) => Blob.fromJson({
  r'$type': 'blob',
  'mimeType': mimeType,
  'size': 42,
  'ref': {r'$link': 'bafkreigh2akiscaildc2'},
});

class TestTransport {
  final List<QueuedResponse> getResponses = [];
  final List<QueuedResponse> postResponses = [];
  final List<TestRequest> requests = [];

  TestRequest get singleRequest => requests.single;

  void enqueueGet(Map<String, dynamic> body, {int statusCode = 200}) {
    getResponses.add(QueuedResponse(statusCode, jsonEncode(body)));
  }

  void enqueuePost(Map<String, dynamic> body, {int statusCode = 200}) {
    postResponses.add(QueuedResponse(statusCode, jsonEncode(body)));
  }

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    requests.add(
      TestRequest(method: 'GET', uri: uri, headers: headers ?? const {}),
    );
    return _response(getResponses, 'GET', uri);
  }

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    requests.add(
      TestRequest(
        method: 'POST',
        uri: uri,
        headers: headers ?? const {},
        body: body,
      ),
    );
    return _response(postResponses, 'POST', uri);
  }

  http.Response _response(
    List<QueuedResponse> responses,
    String method,
    Uri uri,
  ) {
    if (responses.isEmpty) {
      throw StateError('No queued $method response for $uri');
    }
    final response = responses.removeAt(0);
    return http.Response(
      response.body,
      response.statusCode,
      headers: const {'content-type': 'application/json'},
      request: http.Request(method, uri),
    );
  }
}

class QueuedResponse {
  const QueuedResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

class TestRequest {
  const TestRequest({
    required this.method,
    required this.uri,
    required this.headers,
    this.body,
  });

  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final Object? body;

  Map<String, dynamic> get jsonBody {
    final value = body;
    if (value is String) {
      return jsonDecode(value) as Map<String, dynamic>;
    }
    return Map<String, dynamic>.from(value! as Map);
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this.authenticated,
    required this.did,
    required this.atproto,
  });

  final bool authenticated;

  @override
  final String? did;

  @override
  final PoptartClient? atproto;

  @override
  bool get isAuthenticated => authenticated;

  @override
  Future<void> get initializationComplete => Future<void>.value();

  @override
  Future<bool> refreshToken() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSprkRepository implements SprkRepository {
  FakeSprkRepository({required this.auth, required this.repo});

  final FakeAuthRepository auth;

  @override
  final RepoRepository repo;

  @override
  AuthRepository get authRepository => auth;

  @override
  String get sprkDid => 'did:web:sprk.test#sprk_appview';

  @override
  String get bskyDid => 'did:web:bsky.test#bsky_appview';

  @override
  String get modDid => 'did:web:mod.sprk.test';

  @override
  String get bskyModDid => 'did:web:mod.bsky.test';

  @override
  Future<T> executeWithRetry<T>(Future<T> Function() apiCall) => apiCall();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRepoRepository implements RepoRepository {
  final List<CreateRecordCall> createCalls = [];
  final List<DeleteRecordCall> deleteCalls = [];

  @override
  Future<RepoStrongRef> createRecord({
    required String collection,
    required Map<String, dynamic> record,
    String? rkey,
    String? repo,
  }) async {
    createCalls.add(
      CreateRecordCall(
        collection: collection,
        record: record,
        rkey: rkey,
        repo: repo,
      ),
    );
    return RepoStrongRef(
      uri: AtUri('at://did:plc:viewer/$collection/result'),
      cid: 'result-cid',
    );
  }

  @override
  Future<void> deleteRecord({
    required AtUri uri,
    bool skipBskyCrosspostCleanup = false,
  }) async {
    deleteCalls.add(
      DeleteRecordCall(
        uri: uri,
        skipBskyCrosspostCleanup: skipBskyCrosspostCleanup,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class CreateRecordCall {
  const CreateRecordCall({
    required this.collection,
    required this.record,
    required this.rkey,
    required this.repo,
  });

  final String collection;
  final Map<String, dynamic> record;
  final String? rkey;
  final String? repo;
}

class DeleteRecordCall {
  const DeleteRecordCall({
    required this.uri,
    required this.skipBskyCrosspostCleanup,
  });

  final AtUri uri;
  final bool skipBskyCrosspostCleanup;
}
