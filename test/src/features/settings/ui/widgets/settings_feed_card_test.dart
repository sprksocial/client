import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/features/settings/ui/widgets/settings_feed_card.dart';

void main() {
  testWidgets('only pinned feeds can be selected', (tester) async {
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
                    value: 'at://did:plc:feed/app.bsky.feed.generator/test',
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
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);

    await pumpCard(pinned: true);
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNotNull);
  });
}
