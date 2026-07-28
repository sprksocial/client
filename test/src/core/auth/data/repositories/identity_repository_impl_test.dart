import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spark/src/core/auth/data/repositories/identity_repository_impl.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';
import 'package:spark/src/core/storage/preferences/storage_manager.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import '../../../../../support/in_memory_storage.dart';

void main() {
  final now = DateTime.utc(2026, 7, 22, 12);
  late InMemoryStorage storage;

  setUp(() {
    storage = InMemoryStorage();
  });

  test('creation waits for persisted cache restoration', () async {
    final gatedStorage = _GatedStorage();
    await gatedStorage.setInt(
      StorageKeys.identityCacheTtl,
      now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
    );
    await gatedStorage.setString(
      StorageKeys.didToHandleCache,
      jsonEncode({'did:plc:alice': 'alice.test'}),
    );

    var creationCompleted = false;
    final creation = _repository(gatedStorage, now: now)
      ..then((_) {
        creationCompleted = true;
      });
    await gatedStorage.readStarted.future;

    expect(creationCompleted, isFalse);

    gatedStorage.allowRead.complete();
    final repository = await creation;

    expect(await repository.resolveDidToHandle('did:plc:alice'), 'alice.test');
  });

  test(
    'restores valid persisted mappings before serving resolutions',
    () async {
      await storage.setInt(
        StorageKeys.identityCacheTtl,
        now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );
      await storage.setString(
        StorageKeys.didToHandleCache,
        jsonEncode({'did:plc:alice': 'alice.test'}),
      );
      await storage.setString(
        StorageKeys.handleToDidCache,
        jsonEncode({'alice.test': 'did:plc:alice'}),
      );
      var resolverCalls = 0;
      final repository = await _repository(
        storage,
        now: now,
        handleResolver: (_) async {
          resolverCalls++;
          return 'did:plc:unexpected';
        },
      );

      expect(
        await repository.resolveDidToHandle('did:plc:alice'),
        'alice.test',
      );
      expect(
        await repository.resolveHandleToDid('alice.test'),
        'did:plc:alice',
      );
      expect(resolverCalls, 0);
    },
  );

  test('expired persisted caches are cleared deterministically', () async {
    await storage.setInt(
      StorageKeys.identityCacheTtl,
      now.subtract(const Duration(seconds: 1)).millisecondsSinceEpoch,
    );
    await storage.setString(
      StorageKeys.didToHandleCache,
      jsonEncode({'did:plc:alice': 'alice.test'}),
    );
    await storage.setString(
      StorageKeys.handleToDidCache,
      jsonEncode({'alice.test': 'did:plc:alice'}),
    );
    await storage.setString(
      StorageKeys.didDocCache,
      jsonEncode({
        'did:plc:alice': {'id': 'did:plc:alice'},
      }),
    );
    await _repository(storage, now: now);

    expect(await storage.containsKey(StorageKeys.identityCacheTtl), isFalse);
    expect(await storage.containsKey(StorageKeys.didToHandleCache), isFalse);
    expect(await storage.containsKey(StorageKeys.handleToDidCache), isFalse);
    expect(await storage.containsKey(StorageKeys.didDocCache), isFalse);
  });

  test(
    'fetches a DID document once and caches its at handle in both directions',
    () async {
      var requests = 0;
      final client = MockClient((request) async {
        requests++;
        expect(request.url, Uri.parse('https://plc.directory/did:plc:alice'));
        return http.Response(
          jsonEncode({
            'id': 'did:plc:alice',
            'alsoKnownAs': ['https://example.com/alice', 'at://alice.test'],
          }),
          200,
        );
      });
      final repository = await _repository(
        storage,
        now: now,
        httpClient: client,
      );

      expect(
        await repository.resolveDidToHandle('did:plc:alice'),
        'alice.test',
      );
      expect(
        await repository.resolveDidToHandle('did:plc:alice'),
        'alice.test',
      );
      expect(
        await repository.resolveHandleToDid('alice.test'),
        'did:plc:alice',
      );

      expect(requests, 1);
      expect(
        await storage.getInt(StorageKeys.identityCacheTtl),
        now.add(const Duration(hours: 2)).millisecondsSinceEpoch,
      );
      expect(
        jsonDecode((await storage.getString(StorageKeys.didToHandleCache))!),
        {'did:plc:alice': 'alice.test'},
      );
    },
  );

  test(
    'uses the handle resolver once and supports cached bulk lookups',
    () async {
      final calls = <String>[];
      final repository = await _repository(
        storage,
        now: now,
        handleResolver: (handle) async {
          calls.add(handle);
          return 'did:plc:${handle.split('.').first}';
        },
      );
      final first = await repository.resolveHandlesToDids([
        'alice.test',
        'bob.test',
      ]);
      final second = await repository.resolveHandlesToDids([
        'alice.test',
        'bob.test',
      ]);

      expect(first, {'alice.test': 'did:plc:alice', 'bob.test': 'did:plc:bob'});
      expect(second, first);
      expect(calls, ['alice.test', 'bob.test']);
    },
  );

  test(
    'returns null for failed DID document requests without caching them',
    () async {
      var requests = 0;
      final repository = await _repository(
        storage,
        now: now,
        httpClient: MockClient((_) async {
          requests++;
          return http.Response('unavailable', 503);
        }),
      );
      expect(await repository.resolveDidToDidDoc('did:plc:alice'), isNull);
      expect(await repository.resolveDidToDidDoc('did:plc:alice'), isNull);

      expect(requests, 2);
      expect(await storage.getString(StorageKeys.didDocCache), isNull);
    },
  );

  test(
    'clearCache removes memory and every persisted identity entry',
    () async {
      final repository = await _repository(
        storage,
        now: now,
        handleResolver: (_) async => 'did:plc:alice',
      );
      expect(
        await repository.resolveHandleToDid('alice.test'),
        'did:plc:alice',
      );

      await repository.clearCache();

      expect(await storage.containsKey(StorageKeys.identityCacheTtl), isFalse);
      expect(await storage.containsKey(StorageKeys.didToHandleCache), isFalse);
      expect(await storage.containsKey(StorageKeys.handleToDidCache), isFalse);
      expect(await storage.containsKey(StorageKeys.didDocCache), isFalse);
    },
  );
}

class _GatedStorage extends InMemoryStorage {
  final Completer<void> readStarted = Completer<void>();
  final Completer<void> allowRead = Completer<void>();

  @override
  Future<int?> getInt(String key) async {
    readStarted.complete();
    await allowRead.future;
    return super.getInt(key);
  }
}

Future<IdentityRepositoryImpl> _repository(
  InMemoryStorage storage, {
  required DateTime now,
  http.Client? httpClient,
  Future<String> Function(String handle)? handleResolver,
}) {
  return IdentityRepositoryImpl.create(
    StorageManager.instance,
    preferences: storage,
    logger: SparkLogger(name: 'IdentityRepositoryTest'),
    now: () => now,
    httpClient: httpClient,
    handleResolver: handleResolver,
  );
}
