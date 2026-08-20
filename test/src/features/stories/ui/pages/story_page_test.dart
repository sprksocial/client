import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderated_content.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/moderated_story_view.dart';
import 'package:spark/src/features/stories/ui/pages/author_stories_page.dart';
import 'package:spark/src/features/stories/ui/pages/story_page.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  testWidgets('inactive neighbor cannot resume a concealed active story', (
    tester,
  ) async {
    var pauseRequests = 0;
    var resumeRequests = 0;
    final callbacks = (
      pause: () => pauseRequests += 1,
      resume: () => resumeRequests += 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moderationEngineProvider.overrideWith((ref) async => _engine()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Stack(
            children: [
              StoryPage(
                story: _story('active', authorLabeled: true),
                isActive: true,
                onPauseRequested: callbacks.pause,
                onResumeRequested: callbacks.resume,
              ),
              Offstage(
                child: StoryPage(
                  story: _story('neighbor'),
                  isActive: false,
                  onPauseRequested: callbacks.pause,
                  onResumeRequested: callbacks.resume,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(pauseRequests, greaterThan(0));
    expect(resumeRequests, 0);
  });

  testWidgets('service-issued story labels conceal story media', (
    tester,
  ) async {
    var pauseRequests = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moderationEngineProvider.overrideWith((ref) async => _engine()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoryPage(
            story: _story('service-labeled', storyLabeled: true),
            isActive: true,
            onPauseRequested: () => pauseRequests += 1,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(pauseRequests, greaterThan(0));
  });

  testWidgets('concealed story stays paused after its media finishes loading', (
    tester,
  ) async {
    const avatarUrl = 'https://example.com/cached-avatar.png';
    await tester.runAsync(() => _cacheImage(avatarUrl));
    final story = _story(
      'concealed-load',
      authorLabeled: true,
      avatar: avatarUrl,
    );
    var nextAuthorRequests = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moderationEngineProvider.overrideWith((ref) async => _engine()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthorStoriesPage(
            author: story.author,
            stories: [story],
            onNextAuthor: () => nextAuthorRequests += 1,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.byType(ModeratedProfileAvatar), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump(const Duration(seconds: 6));

    expect(nextAuthorRequests, 0);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0,
    );
  });
}

Future<void> _cacheImage(String url) async {
  final bytes = Uint8List.fromList(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
      '+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  );
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final provider = CachedNetworkImageProvider(url);
  final key = await provider.obtainKey(ImageConfiguration.empty);
  PaintingBinding.instance.imageCache.putIfAbsent(
    key,
    () => OneFrameImageStreamCompleter(
      Future.value(ImageInfo(image: frame.image)),
    ),
  );
  addTearDown(() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    codec.dispose();
    frame.image.dispose();
  });
}

ModeratedStoryView _story(
  String id, {
  bool authorLabeled = false,
  bool storyLabeled = false,
  String avatar = 'https://example.com/avatar.jpg',
}) {
  final author = ProfileViewBasic(
    did: 'did:plc:author',
    handle: 'author.sprk.so',
    avatar: avatar,
    labels: authorLabeled
        ? [
            Label(
              src: 'did:plc:moderator',
              uri: 'did:plc:author',
              val: 'sexual',
              cts: DateTime.utc(2026, 8, 12),
            ),
          ]
        : null,
  );
  final story = StoryView(
    uri: AtUri('at://did:plc:author/so.sprk.story.post/$id'),
    cid: 'cid-$id',
    author: author,
    record: const {},
    indexedAt: DateTime.utc(2026, 8, 12),
  );
  return ModeratedStoryView(
    story: story,
    moderationLabels: storyLabeled
        ? [
            Label(
              src: 'did:plc:moderator',
              uri: story.uri.toString(),
              val: 'sexual',
              cts: DateTime.utc(2026, 8, 12),
            ),
          ]
        : const [],
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
