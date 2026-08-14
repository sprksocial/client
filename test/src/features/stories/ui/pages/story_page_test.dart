import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
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
                story: _story('active', labeled: true),
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
}

StoryView _story(String id, {bool labeled = false}) {
  final author = ProfileViewBasic(
    did: 'did:plc:author',
    handle: 'author.sprk.so',
    avatar: 'https://example.com/avatar.jpg',
    labels: labeled
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
  return StoryView(
    uri: AtUri('at://did:plc:author/so.sprk.story.post/$id'),
    cid: 'cid-$id',
    author: author,
    record: const {},
    indexedAt: DateTime.utc(2026, 8, 12),
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
