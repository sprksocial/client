import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/profile/ui/pages/profile_page.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

const _profileDid = 'did:plc:profile';

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('moderates the complete initial profile while loading', (
    tester,
  ) async {
    final actorRepository = _PendingActorRepository();
    GetIt.I
      ..registerSingleton<AuthRepository>(_FakeAuthRepository())
      ..registerSingleton<ActorRepository>(actorRepository)
      ..registerSingleton<SprkRepository>(
        const _FakeSprkRepository(_FakeFeedRepository()),
      )
      ..registerSingleton<LogService>(LogService());

    final initialProfile = ProfileViewBasic(
      did: _profileDid,
      handle: 'hidden.sprk.so',
      displayName: 'Hidden Person',
      labels: [
        Label(
          src: 'did:plc:moderator',
          uri: 'at://$_profileDid/so.sprk.actor.profile/self',
          val: '!hide',
          cts: DateTime.utc(2026, 8, 26),
        ),
      ],
    );
    final router = RootStackRouter.build(
      routes: [
        AutoRoute(
          page: PageInfo.builder(
            ProfileRoute.name,
            builder: (context, data) =>
                ProfilePage(did: _profileDid, initialProfile: initialProfile),
          ),
          path: '/',
          initial: true,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentDidProvider.overrideWith((ref) => null),
          moderationEngineProvider.overrideWith((ref) async => _engine()),
        ],
        child: MaterialApp.router(
          routerConfig: router.config(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Content warning'), findsOneWidget);
    expect(find.text('This restriction cannot be overridden.'), findsOneWidget);
    expect(find.text('View content'), findsNothing);
  });
}

ModerationEngine _engine() {
  return ModerationEngine(
    definitions: ModerationLabelDefinitions.fromLabelers(const {
      'did:plc:moderator': [],
    }),
    preferences: ModerationPreferences(
      labels: const [],
      adultContentEnabled: true,
      authenticated: true,
    ),
  );
}

class _PendingActorRepository implements ActorRepository {
  final Completer<ProfileViewDetailed> _profile =
      Completer<ProfileViewDetailed>();

  @override
  Future<ProfileViewDetailed> getProfile(
    String did, {
    bool useBluesky = false,
  }) => _profile.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  String? get did => null;

  @override
  bool get isAuthenticated => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSprkRepository implements SprkRepository {
  const _FakeSprkRepository(this.feed);

  @override
  final FeedRepository feed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFeedRepository implements FeedRepository {
  const _FakeFeedRepository();

  @override
  Future<({List<FeedViewPost> posts, String? cursor})> getAuthorFeed(
    AtUri actorUri, {
    int limit = 20,
    String? cursor,
    bool videosOnly = false,
    bool bluesky = false,
  }) async => (posts: <FeedViewPost>[], cursor: null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
