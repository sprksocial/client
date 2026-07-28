import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<LogService>(LogService());
  });

  tearDown(() => GetIt.I.reset());

  test('waits for auth initialization before executing a request', () async {
    final initialization = Completer<void>();
    final auth = _FakeAuthRepository(initialization.future);
    final repository = SprkRepositoryImpl(auth, logger: SparkLogger());
    var executed = false;

    final result = repository.executeWithRetry(() async {
      executed = true;
      return 42;
    });
    await Future<void>.value();
    expect(executed, isFalse);

    initialization.complete();
    expect(await result, 42);
    expect(executed, isTrue);
  });

  test('returns non-auth failures without refreshing', () async {
    final auth = _FakeAuthRepository(Future.value());
    final repository = SprkRepositoryImpl(auth, logger: SparkLogger());

    await expectLater(
      repository.executeWithRetry<void>(
        () async => throw StateError('server unavailable'),
      ),
      throwsA(isA<StateError>()),
    );
    expect(auth.refreshCalls, 0);
  });

  test('refreshes a 401 unauthorized response and retries once', () async {
    final auth = _FakeAuthRepository(Future.value())..refreshResult = true;
    final repository = SprkRepositoryImpl(auth, logger: SparkLogger());
    var calls = 0;

    final value = await repository.executeWithRetry(() async {
      calls += 1;
      if (calls == 1) throw Exception('401 Unauthorized');
      return 'success';
    });

    expect(value, 'success');
    expect(calls, 2);
    expect(auth.refreshCalls, 1);
  });

  test('turns a failed refresh into an expired-session error', () async {
    final auth = _FakeAuthRepository(Future.value())..refreshResult = false;
    final repository = SprkRepositoryImpl(auth, logger: SparkLogger());

    await expectLater(
      repository.executeWithRetry<void>(
        () async => throw Exception('401 Unauthorized'),
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Session expired'),
        ),
      ),
    );
    expect(auth.refreshCalls, 1);
  });

  test('does not recursively refresh when the single retry fails', () async {
    final auth = _FakeAuthRepository(Future.value())..refreshResult = true;
    final repository = SprkRepositoryImpl(auth, logger: SparkLogger());
    var calls = 0;

    await expectLater(
      repository.executeWithRetry<void>(() async {
        calls += 1;
        throw Exception('401 Unauthorized attempt $calls');
      }),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('attempt 2'),
        ),
      ),
    );
    expect(calls, 2);
    expect(auth.refreshCalls, 1);
  });

  test('derives service DIDs and lazily caches feature repositories', () {
    final repository = SprkRepositoryImpl(
      _FakeAuthRepository(Future.value()),
      logger: SparkLogger(),
    );

    expect(repository.sprkDid, 'did:web:api.sprk.so#sprk_appview');
    expect(repository.bskyDid, 'did:web:api.bsky.app#bsky_appview');
    expect(identical(repository.actor, repository.actor), isTrue);
    expect(identical(repository.repo, repository.repo), isTrue);
    expect(identical(repository.story, repository.story), isTrue);
    expect(identical(repository.sound, repository.sound), isTrue);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.initializationComplete);

  @override
  final Future<void> initializationComplete;
  bool refreshResult = false;
  int refreshCalls = 0;

  @override
  Future<bool> refreshToken() async {
    refreshCalls += 1;
    return refreshResult;
  }

  @override
  PoptartClient? get atproto => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
