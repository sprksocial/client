import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/profile/providers/profile_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/viewer_state.dart'
    as actor_viewer;

void main() {
  late _FakeAuthRepository authRepository;
  late _FakeActorRepository actorRepository;
  late _FakeGraphRepository graphRepository;

  setUp(() async {
    await GetIt.I.reset();
    authRepository = _FakeAuthRepository();
    actorRepository = _FakeActorRepository();
    graphRepository = _FakeGraphRepository();
    GetIt.I
      ..registerSingleton<AuthRepository>(authRepository)
      ..registerSingleton<ActorRepository>(actorRepository)
      ..registerSingleton<SprkRepository>(_FakeSprkRepository(graphRepository))
      ..registerSingleton<LogService>(LogService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  ProviderContainer createContainer() =>
      ProviderContainer.test(retry: (retryCount, error) => null);

  test('loads the authenticated user when no DID is supplied', () async {
    actorRepository.result = _profile(authRepository.did!);
    final container = createContainer();
    final provider = profileProvider();

    final state = await container.read(provider.future);

    expect(state.profile, actorRepository.result);
    expect(state.currentViewDid, authRepository.did);
    expect(container.read(provider.notifier).isCurrentUser(), isTrue);
    expect(actorRepository.calls, [(authRepository.did!, false)]);
  });

  test('loads another user with the selected API source', () async {
    actorRepository.result = _profile('did:plc:other');
    final container = createContainer();
    final provider = profileProvider(did: 'did:plc:other', bsky: true);

    final state = await container.read(provider.future);

    expect(state.profile?.did, 'did:plc:other');
    expect(container.read(provider.notifier).isCurrentUser(), isFalse);
    expect(actorRepository.calls, [('did:plc:other', true)]);
  });

  test('shows the auth prompt when no user or DID is available', () async {
    authRepository
      ..isAuthenticated = false
      ..did = null;
    final container = createContainer();
    final provider = profileProvider();

    final state = await container.read(provider.future);

    expect(state.profile, isNull);
    expect(state.showAuthPrompt, isTrue);
    expect(actorRepository.calls, isEmpty);
  });

  test('exposes initial profile load failures', () async {
    final error = StateError('profile failed');
    actorRepository.error = error;
    final container = createContainer();

    await expectLater(
      container.read(profileProvider(did: 'did:plc:other').future),
      throwsA(same(error)),
    );
  });

  test('refresh reloads the current profile', () async {
    actorRepository.result = _profile('did:plc:other', displayName: 'Before');
    final container = createContainer();
    final provider = profileProvider(did: 'did:plc:other');
    await container.read(provider.future);
    actorRepository.result = _profile('did:plc:other', displayName: 'After');

    await container.read(provider.notifier).refreshProfile();

    expect(container.read(provider).value?.profile?.displayName, 'After');
    expect(actorRepository.calls, [
      ('did:plc:other', false),
      ('did:plc:other', false),
    ]);
  });

  test('unauthenticated relationship actions show the auth prompt', () async {
    actorRepository.result = _profile('did:plc:other');
    final container = createContainer();
    final provider = profileProvider(did: 'did:plc:other');
    await container.read(provider.future);
    authRepository.isAuthenticated = false;

    await container.read(provider.notifier).setFollowing(following: true);

    expect(container.read(provider).value?.showAuthPrompt, isTrue);
    expect(graphRepository.followCalls, isEmpty);
  });

  test('follow and unfollow update relationship and follower count', () async {
    actorRepository.result = _profile('did:plc:other', followersCount: 3);
    final container = createContainer();
    final provider = profileProvider(did: 'did:plc:other', bsky: true);
    await container.read(provider.future);
    final notifier = container.read(provider.notifier);

    await notifier.setFollowing(following: true);

    final followed = container.read(provider).value!.profile!;
    expect(followed.viewer?.following, _followUri);
    expect(followed.followersCount, 4);
    expect(graphRepository.followCalls, [('did:plc:other', true)]);

    await notifier.setFollowing(following: false);

    final unfollowed = container.read(provider).value!.profile!;
    expect(unfollowed.viewer?.following, isNull);
    expect(unfollowed.followersCount, 3);
    expect(graphRepository.unfollowCalls, [_followUri]);
  });

  test('follow and unfollow failures restore the original state', () async {
    actorRepository.result = _profile('did:plc:other', followersCount: 3);
    final container = createContainer();
    final provider = profileProvider(did: 'did:plc:other');
    await container.read(provider.future);
    final notifier = container.read(provider.notifier);
    final beforeFollow = container.read(provider).value!;
    graphRepository.followError = StateError('follow failed');

    await expectLater(
      notifier.setFollowing(following: true),
      throwsA(isA<Exception>()),
    );
    expect(container.read(provider).value, beforeFollow);

    actorRepository.result = _profile(
      'did:plc:other',
      followersCount: 3,
      following: _followUri,
    );
    await notifier.loadProfileData('did:plc:other', beforeFollow);
    final beforeUnfollow = container.read(provider).value!;
    graphRepository.unfollowError = StateError('unfollow failed');

    await expectLater(
      notifier.setFollowing(following: false),
      throwsA(isA<Exception>()),
    );
    expect(container.read(provider).value, beforeUnfollow);
  });

  test('toggleBlock updates the relationship in both directions', () async {
    actorRepository.result = _profile('did:plc:other');
    final container = createContainer();
    final provider = profileProvider(did: 'did:plc:other');
    await container.read(provider.future);
    final notifier = container.read(provider.notifier);
    graphRepository.toggleBlockResult = _blockUri.toString();

    expect(await notifier.toggleBlock(), _blockUri.toString());
    expect(
      container.read(provider).value?.profile?.viewer?.blocking,
      _blockUri,
    );

    graphRepository.toggleBlockResult = null;
    expect(await notifier.toggleBlock(), isNull);
    expect(container.read(provider).value?.profile?.viewer?.blocking, isNull);
    expect(graphRepository.toggleBlockCalls, [
      ('did:plc:other', null),
      ('did:plc:other', _blockUri),
    ]);
  });

  test('toggleBlock failure restores the original state', () async {
    actorRepository.result = _profile('did:plc:other');
    final container = createContainer();
    final provider = profileProvider(did: 'did:plc:other');
    await container.read(provider.future);
    final notifier = container.read(provider.notifier);
    final original = container.read(provider).value!;
    graphRepository.toggleBlockError = StateError('block failed');

    await expectLater(notifier.toggleBlock(), throwsA(isA<Exception>()));

    expect(container.read(provider).value, original);
  });
}

final AtUri _followUri = AtUri.parse(
  'at://did:plc:me/so.sprk.graph.follow/follow',
);
final AtUri _blockUri = AtUri.parse(
  'at://did:plc:me/so.sprk.graph.block/block',
);

ProfileViewDetailed _profile(
  String did, {
  String? displayName,
  int followersCount = 0,
  AtUri? following,
}) => ProfileViewDetailed(
  did: did,
  handle: '${did.split(':').last}.test',
  displayName: displayName,
  followersCount: followersCount,
  viewer: actor_viewer.ViewerState(following: following),
);

class _FakeActorRepository implements ActorRepository {
  ProfileViewDetailed result = _profile('did:plc:default');
  Object? error;
  final List<(String, bool)> calls = [];

  @override
  Future<ProfileViewDetailed> getProfile(
    String did, {
    bool useBluesky = false,
  }) async {
    calls.add((did, useBluesky));
    final loadError = error;
    if (loadError != null) throw loadError;
    return result;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeGraphRepository implements GraphRepository {
  Object? followError;
  Object? unfollowError;
  Object? toggleBlockError;
  String? toggleBlockResult;
  final List<(String, bool)> followCalls = [];
  final List<AtUri> unfollowCalls = [];
  final List<(String, AtUri?)> toggleBlockCalls = [];

  @override
  Future<RepoStrongRef> followUser(String did, {bool bsky = false}) async {
    followCalls.add((did, bsky));
    final error = followError;
    if (error != null) throw error;
    return RepoStrongRef(uri: _followUri, cid: 'follow-cid');
  }

  @override
  Future<void> unfollowUser(AtUri followUri) async {
    unfollowCalls.add(followUri);
    final error = unfollowError;
    if (error != null) throw error;
  }

  @override
  Future<String?> toggleBlock(String did, AtUri? currentBlockUri) async {
    toggleBlockCalls.add((did, currentBlockUri));
    final error = toggleBlockError;
    if (error != null) throw error;
    return toggleBlockResult;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.graph);

  @override
  final GraphRepository graph;

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not used');
}

class _FakeAuthRepository implements AuthRepository {
  @override
  bool isAuthenticated = true;

  @override
  String? did = 'did:plc:me';

  @override
  PoptartClient? get atproto => null;

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
  Future<void> logout() async {
    isAuthenticated = false;
    did = null;
  }

  @override
  Future<bool> refreshToken() async => false;

  @override
  Future<bool> validateSession() async => isAuthenticated;
}
