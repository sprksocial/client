import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/storage/preferences/default_preferences.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/feed_state.dart';
import 'package:spark/src/features/feed/providers/visible_pinned_feeds_provider.dart';
import 'package:spark/src/features/feed/ui/pages/feed_page.dart';
import 'package:spark/src/features/feed/ui/widgets/feed/cacheable_page_view.dart';
import 'package:spark/src/features/feed/ui/widgets/post/feed_terminal_state.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';

void main() {
  testWidgets('an empty Following feed explains how to populate it', (
    tester,
  ) async {
    final following = _followingFeed();
    final discover = _discoverFeed();
    final settings = _FakeSettings(
      SettingsState(activeFeed: following, feeds: [following, discover]),
    );
    final container = _container(
      feedState: _emptyFeedState(),
      settings: settings,
      visibleFeeds: [following, discover],
    );
    addTearDown(container.dispose);

    await _pumpFeedPage(tester, container, following);

    expect(find.text('Your Following feed is empty'), findsOneWidget);
    expect(find.text('Follow people to see their posts here.'), findsOneWidget);
    expect(find.text('Find people'), findsOneWidget);
    expect(find.text('Explore Discover'), findsOneWidget);
    expect(find.text("You're all caught up!"), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Explore Discover'));
    await tester.pump();

    expect(settings.selectedFeeds, [discover]);
    await _disposeFeedPage(tester);
  });

  testWidgets('a concealed Discover feed is not offered', (tester) async {
    final following = _followingFeed();
    final discover = _discoverFeed();
    final container = _container(
      feedState: _emptyFeedState(),
      settings: _FakeSettings(
        SettingsState(activeFeed: following, feeds: [following, discover]),
      ),
      visibleFeeds: [following],
    );
    addTearDown(container.dispose);

    await _pumpFeedPage(tester, container, following);

    expect(find.text('Explore Discover'), findsNothing);
    await _disposeFeedPage(tester);
  });

  testWidgets('feed errors remain distinct from empty content', (tester) async {
    final feed = _discoverFeed();
    final container = _container(
      feedState: _emptyFeedState().copyWith(error: true),
      settings: _FakeSettings(SettingsState(activeFeed: feed, feeds: [feed])),
      visibleFeeds: [feed],
    );
    addTearDown(container.dispose);

    await _pumpFeedPage(tester, container, feed);

    expect(find.text('Error loading feed'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsNothing);
    await _disposeFeedPage(tester);
  });

  testWidgets('an empty custom feed offers a refresh without follow guidance', (
    tester,
  ) async {
    final feed = _customFeed();
    final container = _container(
      feedState: _emptyFeedState(),
      settings: _FakeSettings(SettingsState(activeFeed: feed, feeds: [feed])),
      visibleFeeds: [feed],
    );
    addTearDown(container.dispose);

    await _pumpFeedPage(tester, container, feed);

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(
      find.text('This feed doesn’t have any posts right now.'),
      findsOneWidget,
    );
    expect(find.text('Refresh'), findsOneWidget);
    expect(find.text('Find people'), findsNothing);

    final notifier =
        container.read(feedProvider(feed).notifier) as _FakeFeedNotifier;
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(notifier.loadCalls, 1);
    await _disposeFeedPage(tester);
  });

  testWidgets('caught-up state refreshes without claiming the feed is empty', (
    tester,
  ) async {
    var refreshCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FeedTerminalState(
          variant: FeedTerminalStateVariant.caughtUp,
          onRefresh: () => refreshCalls++,
        ),
      ),
    );

    expect(find.text("You're all caught up!"), findsOneWidget);
    expect(find.text('Refresh to check for new posts.'), findsOneWidget);
    expect(find.text('Your Following feed is empty'), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Refresh'));
    await tester.pump();

    expect(refreshCalls, 1);
  });

  testWidgets('caught-up state yields vertical drags to the feed pager', (
    tester,
  ) async {
    final controller = PageController(initialPage: 1);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CacheablePageView(
          controller: controller,
          scrollDirection: Axis.vertical,
          children: [
            const ColoredBox(key: Key('previous-post'), color: Colors.black),
            FeedTerminalState(
              variant: FeedTerminalStateVariant.caughtUp,
              onRefresh: () {},
            ),
          ],
        ),
      ),
    );

    await tester.drag(find.text("You're all caught up!"), const Offset(0, 500));
    await tester.pumpAndSettle();

    expect(controller.page, 0);
    expect(find.byKey(const Key('previous-post')), findsOneWidget);
  });
}

Future<void> _disposeFeedPage(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

ProviderContainer _container({
  required FeedState feedState,
  required _FakeSettings settings,
  required List<Feed> visibleFeeds,
}) => ProviderContainer.test(
  overrides: [
    settingsProvider.overrideWith(() => settings),
    feedProvider.overrideWith2((feed) => _FakeFeedNotifier(feedState)),
    visiblePinnedFeedsProvider.overrideWithValue((
      effectiveActiveFeed: settings.initialState.activeFeed,
      feeds: visibleFeeds,
      shouldPersistEffectiveActiveFeed: false,
    )),
  ],
);

Future<void> _pumpFeedPage(
  WidgetTester tester,
  ProviderContainer container,
  Feed feed,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FeedPage(feed: feed, isActive: true),
      ),
    ),
  );
  await tester.pump();
}

FeedState _emptyFeedState() => FeedState(
  active: true,
  loadedPosts: const [],
  index: 0,
  isEndOfNetworkFeed: true,
  cursor: null,
  loadingFirstLoad: false,
  error: false,
  extraInfo: LinkedHashMap(),
);

Feed _followingFeed() => Feed(
  type: 'timeline',
  config: makeSavedFeed(
    id: 'following',
    type: 'timeline',
    value: 'following',
    pinned: true,
  ),
);

Feed _discoverFeed() => Feed(
  type: 'feed',
  config: makeSavedFeed(
    id: 'discover',
    type: 'feed',
    value: DefaultPreferences.discoverFeedUri,
    pinned: true,
  ),
);

Feed _customFeed() => Feed(
  type: 'feed',
  config: makeSavedFeed(
    id: 'custom',
    type: 'feed',
    value: 'at://did:plc:feed/so.sprk.feed.generator/custom',
    pinned: true,
  ),
);

class _FakeFeedNotifier extends FeedNotifier {
  _FakeFeedNotifier(this.initialState);

  final FeedState initialState;
  int loadCalls = 0;

  @override
  FeedState build(Feed feed) => initialState;

  @override
  Future<void> loadAndUpdateFirstLoad() async {
    loadCalls++;
  }

  @override
  Future<void> setActive(bool active) async {
    state = state.copyWith(active: active);
  }
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
