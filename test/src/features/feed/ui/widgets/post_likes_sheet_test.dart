import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/feed/ui/widgets/post_likes_sheet.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('filters account-hidden actors from the likes list', (
    tester,
  ) async {
    final repository = _FakeFeedRepository([
      _like('visible'),
      _like('hidden', hidden: true),
    ]);
    GetIt.I
      ..registerSingleton<SprkRepository>(_FakeSprkRepository(repository))
      ..registerSingleton<LogService>(LogService());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moderationEngineProvider.overrideWith((ref) async => _engine()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showPostLikesSheet(
                  context: context,
                  uri: 'at://did:plc:author/so.sprk.feed.post/post',
                ),
                child: const Text('Show likes'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show likes'));
    await tester.pumpAndSettle();

    expect(find.text('Visible'), findsOneWidget);
    expect(find.text('Hidden'), findsNothing);
  });
}

PostLike _like(String name, {bool hidden = false}) {
  final did = 'did:plc:$name';
  return PostLike(
    indexedAt: DateTime.utc(2026, 8, 17),
    createdAt: DateTime.utc(2026, 8, 17),
    actor: ProfileView(
      did: did,
      handle: '$name.sprk.so',
      displayName: name[0].toUpperCase() + name.substring(1),
      labels: hidden
          ? [
              Label(
                src: 'did:plc:moderator',
                uri: did,
                val: '!hide',
                cts: DateTime.utc(2026, 8, 17),
              ),
            ]
          : null,
    ),
  );
}

ModerationEngine _engine() => ModerationEngine(
  definitions: ModerationLabelDefinitions(),
  preferences: ModerationPreferences(
    labels: const [],
    adultContentEnabled: true,
    authenticated: true,
  ),
);

class _FakeFeedRepository implements FeedRepository {
  const _FakeFeedRepository(this.likes);

  final List<PostLike> likes;

  @override
  Future<({List<PostLike> likes, String? cursor})> getLikes(
    AtUri uri, {
    String? cid,
    int limit = 50,
    String? cursor,
  }) async => (likes: likes, cursor: null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSprkRepository implements SprkRepository {
  const _FakeSprkRepository(this.feedRepository);

  final FeedRepository feedRepository;

  @override
  FeedRepository get feed => feedRepository;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
