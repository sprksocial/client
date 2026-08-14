import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('definition fetch failures keep the engine unavailable', () async {
    final error = StateError('policy unavailable');
    GetIt.I
      ..registerSingleton<PrefRepository>(_FakePrefRepository())
      ..registerSingleton<SprkRepository>(
        _FakeSprkRepository(_FailingLabelerRepository(error)),
      )
      ..registerSingleton<LogService>(LogService());
    final container = ProviderContainer.test(
      retry: (retryCount, error) => null,
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(moderationEngineProvider.future),
      throwsA(same(error)),
    );

    expect(container.read(moderationEngineProvider).hasError, isTrue);
  });
}

class _FakePrefRepository implements PrefRepository {
  @override
  Future<Preferences> getPreferences() async => Preferences(preferences: []);

  @override
  Future<void> putPreferences(Preferences preferences) async {}
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.labeler);

  @override
  final LabelerRepository labeler;

  @override
  final AuthRepository authRepository = _FakeAuthRepository();

  @override
  String get modDid => 'did:plc:moderator#atproto_labeler';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingLabelerRepository implements LabelerRepository {
  _FailingLabelerRepository(this.error);

  final Object error;

  @override
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids) async {
    throw error;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> initializationComplete = Future<void>.value();

  @override
  bool get isAuthenticated => true;

  @override
  String get did => 'did:plc:me';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
