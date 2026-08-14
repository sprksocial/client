import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/features/feed/providers/visible_pinned_feeds_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  test('conceals labeled generators while moderation is pending', () {
    final moderation = Completer<ModerationEngine>();
    final timeline = _timeline();
    final labeled = _feed('labeled', generatorLabels: [_label()]);
    final unlabeled = _feed('unlabeled');
    final container = ProviderContainer.test(
      overrides: [
        settingsProvider.overrideWithValue(
          SettingsState(
            activeFeed: timeline,
            feeds: [timeline, labeled, unlabeled],
          ),
        ),
        moderationEngineProvider.overrideWith((ref) => moderation.future),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(visiblePinnedFeedsProvider), [timeline, unlabeled]);
  });

  test('uses one ordered list with profile-aware creator moderation', () async {
    final timeline = _timeline();
    final accountLabeled = _feed(
      'account-labeled',
      creatorLabels: [_label(account: true)],
    );
    final profileLabeled = _feed('profile-labeled', creatorLabels: [_label()]);
    final generatorLabeled = _feed(
      'generator-labeled',
      generatorLabels: [_label()],
    );
    final visible = _feed('visible');
    final container = ProviderContainer.test(
      overrides: [
        settingsProvider.overrideWithValue(
          SettingsState(
            activeFeed: timeline,
            feeds: [
              timeline,
              accountLabeled,
              profileLabeled,
              generatorLabeled,
              visible,
            ],
          ),
        ),
        moderationEngineProvider.overrideWith((ref) async => _engine()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(moderationEngineProvider.future);

    expect(container.read(visiblePinnedFeedsProvider), [
      timeline,
      profileLabeled,
      visible,
    ]);
  });
}

final _indexedAt = DateTime.utc(2026, 8, 11);

Feed _timeline() => Feed(
  type: 'timeline',
  config: makeSavedFeed(
    type: 'timeline',
    value: 'following',
    pinned: true,
    id: 'timeline',
  ),
);

Feed _feed(
  String id, {
  List<Label>? generatorLabels,
  List<Label>? creatorLabels,
}) {
  final creator = ProfileView(
    did: 'did:plc:creator',
    handle: 'creator.sprk.so',
    labels: creatorLabels,
  );
  return Feed(
    type: 'feed',
    config: makeSavedFeed(
      type: 'feed',
      value: 'at://did:plc:feed/so.sprk.feed.generator/$id',
      pinned: true,
      id: id,
    ),
    view: GeneratorView(
      uri: AtUri('at://did:plc:feed/so.sprk.feed.generator/$id'),
      cid: 'cid-$id',
      did: 'did:plc:feed',
      creator: creator,
      displayName: id,
      labels: generatorLabels,
      indexedAt: _indexedAt,
    ),
  );
}

Label _label({bool account = false}) => Label(
  src: 'did:plc:moderator',
  uri: account
      ? 'did:plc:creator'
      : 'at://did:plc:creator/app.bsky.actor.profile/self',
  val: 'blocked',
  cts: _indexedAt,
);

ModerationEngine _engine() => ModerationEngine(
  definitions: ModerationLabelDefinitions(
    definitions: [
      ModerationLabelDefinition(
        identifier: 'blocked',
        severity: ModerationSeverity.alert,
        blurs: ModerationBlur.content,
        defaultSetting: ModerationSetting.hide,
        configurable: true,
        flags: const {ModerationLabelFlag.noSelf},
        locales: const [],
        behaviors: {
          ModerationTarget.content: ModerationBehavior({
            ModerationContext.contentList: ModerationAction.blur,
          }),
          ModerationTarget.account: ModerationBehavior({
            ModerationContext.contentList: ModerationAction.blur,
          }),
          ModerationTarget.profile: ModerationBehavior({
            ModerationContext.profileList: ModerationAction.blur,
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
