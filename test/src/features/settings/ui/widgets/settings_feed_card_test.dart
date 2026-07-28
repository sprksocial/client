import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/features/settings/ui/widgets/settings_feed_card.dart';

void main() {
  testWidgets('only pinned feeds expose a selection action', (tester) async {
    const feedUri = 'at://did:plc:feed/app.bsky.feed.generator/test';
    final semanticsHandle = tester.ensureSemantics();

    Future<void> pumpCard({required bool pinned}) {
      return tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SettingsFeedCard(
                feed: Feed(
                  type: 'feed',
                  config: makeSavedFeed(
                    type: 'feed',
                    value: feedUri,
                    pinned: pinned,
                  ),
                ),
                mode: SettingsFeedCardMode.display,
                index: 0,
              ),
            ),
          ),
        ),
      );
    }

    await pumpCard(pinned: false);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel(feedUri))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );

    await pumpCard(pinned: true);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel(feedUri))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    semanticsHandle.dispose();
  });
}
