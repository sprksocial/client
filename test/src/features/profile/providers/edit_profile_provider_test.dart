import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/profile/providers/edit_profile_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  late _FakeAuthRepository authRepository;
  late _FakeActorRepository actorRepository;

  setUp(() async {
    await GetIt.I.reset();
    authRepository = _FakeAuthRepository();
    actorRepository = _FakeActorRepository();
    GetIt.I
      ..registerSingleton<AuthRepository>(authRepository)
      ..registerSingleton<ActorRepository>(actorRepository)
      ..registerSingleton<LogService>(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  ProviderContainer createContainer() => ProviderContainer.test();

  test('initializes and edits text fields from the profile', () {
    final profile = _profile(displayName: 'Before', description: 'Original');
    final container = createContainer();
    final provider = editProfileProvider(profile);
    final subscription = container.listen(provider, (previous, next) {});
    addTearDown(subscription.close);
    final notifier = container.read(provider.notifier);

    notifier
      ..updateDisplayName('After')
      ..updateDescription('Updated');

    final state = container.read(provider);
    expect(state.profile, profile);
    expect(state.displayName, 'After');
    expect(state.description, 'Updated');
    expect(state.isSaving, isFalse);
  });

  test('save rejects unauthenticated users and resets saving state', () async {
    authRepository.isAuthenticated = false;
    final container = createContainer();
    final provider = editProfileProvider(_profile());
    final subscription = container.listen(provider, (previous, next) {});
    addTearDown(subscription.close);

    final saved = await container.read(provider.notifier).saveProfile();

    expect(saved, isFalse);
    expect(container.read(provider).isSaving, isFalse);
    expect(actorRepository.updateCalls, isEmpty);
  });

  test('save trims fields and sends a cleared avatar', () async {
    final container = createContainer();
    final provider = editProfileProvider(_profile());
    final subscription = container.listen(provider, (previous, next) {});
    addTearDown(subscription.close);
    final notifier = container.read(provider.notifier);
    notifier
      ..updateDisplayName('  Display Name  ')
      ..updateDescription('  Description  ');

    final saved = await notifier.saveProfile();

    expect(saved, isTrue);
    expect(actorRepository.updateCalls.single, (
      displayName: 'Display Name',
      description: 'Description',
      avatar: null,
    ));
    expect(container.read(provider).isSaving, isFalse);
  });

  test('save failure returns false and resets saving state', () async {
    actorRepository.updateError = StateError('update failed');
    final container = createContainer();
    final provider = editProfileProvider(_profile());
    final subscription = container.listen(provider, (previous, next) {});
    addTearDown(subscription.close);

    final saved = await container.read(provider.notifier).saveProfile();

    expect(saved, isFalse);
    expect(container.read(provider).isSaving, isFalse);
    expect(actorRepository.updateCalls, hasLength(1));
  });
}

ProfileViewDetailed _profile({String? displayName, String? description}) =>
    ProfileViewDetailed(
      did: 'did:plc:me',
      handle: 'me.test',
      displayName: displayName,
      description: description,
    );

class _FakeActorRepository implements ActorRepository {
  final List<({String displayName, String description, Blob? avatar})>
  updateCalls = [];
  Object? updateError;

  @override
  Future<void> updateProfile({
    required String displayName,
    required String description,
    Blob? avatar,
  }) async {
    updateCalls.add((
      displayName: displayName,
      description: description,
      avatar: avatar,
    ));
    final error = updateError;
    if (error != null) throw error;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeAuthRepository implements AuthRepository {
  @override
  bool isAuthenticated = true;

  @override
  PoptartClient? atproto = PoptartClient.anonymous();

  @override
  String? get did => isAuthenticated ? 'did:plc:me' : null;

  @override
  String? get handle => isAuthenticated ? 'me.test' : null;

  @override
  Future<void> get initializationComplete async {}

  @override
  String? get lastKnownHandle => handle;

  @override
  String? get pdsEndpoint => null;

  @override
  Future<LoginResult> completeOAuth(String callbackUrl) =>
      throw UnsupportedError('completeOAuth is not used');

  @override
  Future<String> initiateOAuth(String handle) =>
      throw UnsupportedError('initiateOAuth is not used');

  @override
  Future<String> initiateOAuthWithoutLoginHint() =>
      throw UnsupportedError('initiateOAuthWithoutLoginHint is not used');

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshToken() async => false;

  @override
  Future<bool> validateSession() async => isAuthenticated;
}
