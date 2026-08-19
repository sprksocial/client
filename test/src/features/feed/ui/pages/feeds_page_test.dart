import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/feed_state.dart';
import 'package:spark/src/features/feed/ui/pages/feeds_page.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  testWidgets('does not persist a fallback while feed moderation is pending', (
    tester,
  ) async {
    final moderation = Completer<ModerationEngine>();
    final timeline = _timeline();
    final labeled = _feed('labeled');
    final container = _container(
      moderation: moderation,
      timeline: timeline,
      labeled: labeled,
    );
    addTearDown(container.dispose);

    await _pumpFeedsPage(tester, container);

    final settings = container.read(settingsProvider.notifier) as _FakeSettings;
    expect(settings.selectedFeeds, isEmpty);
    expect(container.read(settingsProvider).activeFeed, labeled);
    expect(
      (container.read(feedProvider(timeline).notifier) as _FakeFeedNotifier)
          .loadCalls,
      1,
    );

    moderation.complete(_engine(hideLabeledFeed: false));
    await tester.pump();
    await tester.pump();

    expect(settings.selectedFeeds, isEmpty);
    expect(container.read(settingsProvider).activeFeed, labeled);

    await _disposeFeedsPage(tester);
  });

  testWidgets('persists a fallback after moderation hides the active feed', (
    tester,
  ) async {
    final moderation = Completer<ModerationEngine>();
    final timeline = _timeline();
    final labeled = _feed('labeled');
    final container = _container(
      moderation: moderation,
      timeline: timeline,
      labeled: labeled,
    );
    addTearDown(container.dispose);

    await _pumpFeedsPage(tester, container);

    final settings = container.read(settingsProvider.notifier) as _FakeSettings;
    expect(settings.selectedFeeds, isEmpty);

    moderation.complete(_engine(hideLabeledFeed: true));
    await tester.pump();
    await tester.pump();

    expect(settings.selectedFeeds, [timeline]);
    expect(container.read(settingsProvider).activeFeed, timeline);

    await _disposeFeedsPage(tester);
  });

  testWidgets(
    'persists a non-moderation fallback while moderation is pending',
    (tester) async {
      final moderation = Completer<ModerationEngine>();
      final timeline = _timeline();
      final unpinned = _feed('unpinned', pinned: false);
      final container = _container(
        moderation: moderation,
        timeline: timeline,
        labeled: unpinned,
      );
      addTearDown(container.dispose);

      await _pumpFeedsPage(tester, container);

      final settings =
          container.read(settingsProvider.notifier) as _FakeSettings;
      expect(settings.selectedFeeds, [timeline]);
      expect(container.read(settingsProvider).activeFeed, timeline);

      await _disposeFeedsPage(tester);
    },
  );
}

ProviderContainer _container({
  required Completer<ModerationEngine> moderation,
  required Feed timeline,
  required Feed labeled,
}) {
  return ProviderContainer.test(
    overrides: [
      settingsProvider.overrideWith(
        () => _FakeSettings(
          SettingsState(activeFeed: labeled, feeds: [timeline, labeled]),
        ),
      ),
      moderationEngineProvider.overrideWith((ref) => moderation.future),
      feedProvider.overrideWith2((feed) => _FakeFeedNotifier()),
    ],
  );
}

Future<void> _pumpFeedsPage(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FeedsPage(),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _disposeFeedsPage(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

class _FakeSettings extends Settings {
  _FakeSettings(this.initialState);

  final SettingsState initialState;
  final List<Feed> selectedFeeds = [];

  @override
  SettingsState build() => initialState;

  @override
  Future<void> setActiveFeed(Feed feed) async {
    selectedFeeds.add(feed);
    state = state.copyWith(activeFeed: feed);
  }
}

class _FakeFeedNotifier extends FeedNotifier {
  int loadCalls = 0;

  @override
  FeedState build(Feed feed) => FeedState(
    active: false,
    loadedPosts: const [],
    index: 0,
    isEndOfNetworkFeed: false,
    cursor: null,
    loadingFirstLoad: false,
    error: false,
    extraInfo: LinkedHashMap(),
  );

  @override
  Future<void> loadAndUpdateFirstLoad() async {
    loadCalls++;
  }

  @override
  Future<void> setActive(bool active) async {
    state = state.copyWith(active: active);
  }
}

final _indexedAt = DateTime.utc(2026, 8, 14);

Feed _timeline() => Feed(
  type: 'timeline',
  config: makeSavedFeed(
    type: 'timeline',
    value: 'following',
    pinned: true,
    id: 'timeline',
  ),
);

Feed _feed(String id, {bool pinned = true}) {
  final creator = ProfileView(
    did: 'did:plc:creator',
    handle: 'creator.sprk.so',
  );
  return Feed(
    type: 'feed',
    config: makeSavedFeed(
      type: 'feed',
      value: 'at://did:plc:feed/so.sprk.feed.generator/$id',
      pinned: pinned,
      id: id,
    ),
    view: GeneratorView(
      uri: AtUri('at://did:plc:feed/so.sprk.feed.generator/$id'),
      cid: 'cid-$id',
      did: 'did:plc:feed',
      creator: creator,
      displayName: id,
      labels: [
        Label(
          src: 'did:plc:moderator',
          uri: 'at://did:plc:feed/so.sprk.feed.generator/$id',
          val: 'blocked',
          cts: _indexedAt,
        ),
      ],
      indexedAt: _indexedAt,
    ),
  );
}

ModerationEngine _engine({required bool hideLabeledFeed}) => ModerationEngine(
  definitions: ModerationLabelDefinitions(
    definitions: [
      ModerationLabelDefinition(
        identifier: 'blocked',
        severity: ModerationSeverity.alert,
        blurs: ModerationBlur.content,
        defaultSetting: hideLabeledFeed
            ? ModerationSetting.hide
            : ModerationSetting.warn,
        configurable: true,
        flags: const {ModerationLabelFlag.noSelf},
        locales: const [],
        behaviors: {
          ModerationTarget.content: ModerationBehavior({
            ModerationContext.contentList: ModerationAction.blur,
          }),
        },
      ),
    ],
  ),
  preferences: ModerationPreferences(
    labels: const [],
    adultContentEnabled: true,
    authenticated: true,
  ),
);
