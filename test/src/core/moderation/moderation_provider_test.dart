import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

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

  test('preserves labeler handles for moderation details', () async {
    GetIt.I
      ..registerSingleton<PrefRepository>(_FakePrefRepository())
      ..registerSingleton<SprkRepository>(
        _FakeSprkRepository(_SuccessfulLabelerRepository()),
      )
      ..registerSingleton<LogService>(LogService());
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    final engine = await container.read(moderationEngineProvider.future);
    final decision = engine.evaluate(
      [
        Label(
          src: 'did:plc:moderator',
          uri: 'at://did:plc:author/so.sprk.feed.post/example',
          val: 'porn',
          cts: DateTime.utc(2026),
        ),
      ],
      target: ModerationTarget.content,
      subjectDid: 'did:plc:author',
    );

    expect(decision.causes.single.sourceHandle, 'moderator.test');
  });

  test('only accepts labels from currently configured labelers', () async {
    GetIt.I
      ..registerSingleton<PrefRepository>(
        _FakePrefRepository(
          Preferences(
            preferences: [
              labelersPreference(const [
                LabelerPrefItem(did: ' did:plc:selected#atproto_labeler '),
              ]),
            ],
          ),
        ),
      )
      ..registerSingleton<SprkRepository>(
        _FakeSprkRepository(_SuccessfulLabelerRepository()),
      )
      ..registerSingleton<LogService>(LogService());
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    final engine = await container.read(moderationEngineProvider.future);
    final decision = engine.evaluate(
      [
        _label(src: 'did:plc:removed', value: '!hide'),
        _label(src: 'did:plc:removed', value: 'porn'),
        _label(src: 'did:plc:selected', value: '!warn'),
        _label(src: 'did:plc:moderator', value: 'sexual'),
      ],
      target: ModerationTarget.content,
      subjectDid: 'did:plc:author',
    );

    expect(decision.causes.map((cause) => cause.sourceDid).toSet(), {
      'did:plc:selected',
      'did:plc:moderator',
    });
  });
}

class _FakePrefRepository implements PrefRepository {
  _FakePrefRepository([this.preferences = const Preferences(preferences: [])]);

  final Preferences preferences;

  @override
  Future<Preferences> getPreferences() async => preferences;

  @override
  Future<void> putPreferences(Preferences preferences) async {}
}

Label _label({required String src, required String value}) => Label(
  src: src,
  uri: 'at://did:plc:author/so.sprk.feed.post/example',
  val: value,
  cts: DateTime.utc(2026),
);

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.labeler);

  @override
  final LabelerRepository labeler;

  @override
  final AuthRepository authRepository = _FakeAuthRepository();

  @override
  String get modDid => 'did:plc:moderator#atproto_labeler';

  @override
  void configureLabelers(Iterable<String> labelerDids) {}

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

class _SuccessfulLabelerRepository implements LabelerRepository {
  @override
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids) async {
    final did = dids.single;
    return LabelerViewDetailed(
      uri: AtUri.parse('at://$did/app.bsky.labeler.service/self'),
      cid: 'cid',
      creator: ProfileView(did: did, handle: 'moderator.test'),
      policies: LabelerPolicies(
        labelValues: const [LabelValue.knownValue(data: KnownLabelValue.porn)],
      ),
      indexedAt: DateTime.utc(2026),
    );
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
