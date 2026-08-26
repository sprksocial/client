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
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/feed/ui/pages/standalone_post_page.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

const _postUri = 'at://did:plc:author/so.sprk.feed.post/root';
const _replyUri = 'at://did:plc:reply/so.sprk.feed.reply/highlighted';

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('waits for reveal before opening a highlighted reply', (
    tester,
  ) async {
    final post = _post(
      labels: [
        Label(
          src: 'did:plc:author',
          uri: _postUri,
          val: 'sexual',
          cts: DateTime.utc(2026, 8, 26),
        ),
      ],
    );
    await _pumpPage(tester, post);

    expect(find.text('Content warning'), findsOneWidget);
    expect(find.text('Comments destination'), findsNothing);

    await tester.tap(find.text('View content'));
    await tester.pumpAndSettle();

    expect(find.text('Comments destination'), findsOneWidget);
  });

  testWidgets('opens an unmoderated highlighted reply automatically', (
    tester,
  ) async {
    await _pumpPage(tester, _post());

    expect(find.text('Comments destination'), findsOneWidget);
  });

  testWidgets('comment bar waits for concealed content to be revealed', (
    tester,
  ) async {
    final post = _post(
      labels: [
        Label(
          src: 'did:plc:author',
          uri: _postUri,
          val: 'sexual',
          cts: DateTime.utc(2026, 8, 26),
        ),
      ],
    );
    await _pumpPage(tester, post, highlightedReplyUri: null);

    await tester.tap(find.text('Add comment...'));
    await tester.pump();
    expect(find.text('Comments destination'), findsNothing);

    await tester.tap(find.text('View content'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add comment...'));
    await tester.pumpAndSettle();

    expect(find.text('Comments destination'), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  PostView post, {
  String? highlightedReplyUri = _replyUri,
}) async {
  final feedRepository = _FakeFeedRepository(post);
  GetIt.I.registerSingleton<SprkRepository>(
    _FakeSprkRepository(feedRepository),
  );
  GetIt.I.registerSingleton<AuthRepository>(_FakeAuthRepository());

  final router = RootStackRouter.build(
    routes: [
      AutoRoute(
        page: PageInfo.builder(
          StandalonePostRoute.name,
          builder: (context, data) => StandalonePostPage(
            postUri: _postUri,
            highlightedReplyUri: highlightedReplyUri,
          ),
        ),
        path: '/',
        initial: true,
      ),
      AutoRoute(
        page: PageInfo.builder(
          CommentsRoute.name,
          builder: (context, data) =>
              const Scaffold(body: Center(child: Text('Comments destination'))),
        ),
        path: '/comments',
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        moderationEngineProvider.overrideWith((ref) async => _engine()),
      ],
      child: MaterialApp.router(
        routerConfig: router.config(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

PostView _post({List<Label>? labels}) {
  return PostView(
    uri: AtUri.parse(_postUri),
    cid: 'cid-root',
    author: const ProfileViewBasic(
      did: 'did:plc:author',
      handle: 'author.sprk.so',
    ),
    record: const {r'$type': 'so.sprk.feed.post', 'text': 'root post'},
    indexedAt: DateTime.utc(2026, 8, 26),
    labels: labels,
  );
}

ModerationEngine _engine() {
  return ModerationEngine(
    definitions: ModerationLabelDefinitions.fromLabelers({
      'did:plc:author': const [],
    }),
    preferences: ModerationPreferences(
      labels: const [],
      adultContentEnabled: true,
      authenticated: true,
    ),
  );
}

class _FakeSprkRepository implements SprkRepository {
  const _FakeSprkRepository(this.feed);

  @override
  final FeedRepository feed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  String? get did => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFeedRepository implements FeedRepository {
  const _FakeFeedRepository(this.post);

  final PostView post;

  @override
  Future<Thread> getThread(
    AtUri uri, {
    int depth = 2,
    int parentHeight = 0,
    bool bluesky = false,
  }) async {
    return ThreadViewPost(post: ThreadPost.post(post: post));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
