import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';

/// Default preferences to use when setting up a new user
class DefaultPreferences {
  DefaultPreferences._();

  /// Get default preferences including default feeds and label preferences
  /// [modServiceDid] The DID of the mod service labeler (required)
  static Preferences defaultPreferences({required String modServiceDid}) {
    final labelerDid = modServiceDid;
    // Default feeds: timeline, forYou, latest
    final defaultFeeds = [
      makeSavedFeed(type: 'timeline', value: 'following', pinned: true),
      makeSavedFeed(
        type: 'feed',
        value:
            'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids',
        pinned: true,
      ),
      makeSavedFeed(
        type: 'feed',
        value:
            'at://did:plc:cveom2iroj3mt747sd4qqnr2/so.sprk.feed.generator/discover',
        pinned: true,
      ),
    ];

    // Default label preferences
    final defaultLabelPrefs = [
      contentLabelPreference(
        labelerDid: labelerDid,
        label: '!hide',
        visibility: 'hide',
      ),
      contentLabelPreference(
        labelerDid: labelerDid,
        label: '!no-promote',
        visibility: 'hide',
      ),
      contentLabelPreference(
        labelerDid: labelerDid,
        label: '!warn',
        visibility: 'warn',
      ),
      contentLabelPreference(
        labelerDid: labelerDid,
        label: '!no-unauthenticated',
        visibility: 'ignore',
      ),
      contentLabelPreference(
        labelerDid: labelerDid,
        label: 'dmca-violation',
        visibility: 'hide',
      ),
      contentLabelPreference(
        labelerDid: labelerDid,
        label: 'doxxing',
        visibility: 'warn',
      ),
      contentLabelPreference(
        labelerDid: labelerDid,
        label: 'nsfl',
        visibility: 'warn',
      ),
      contentLabelPreference(
        labelerDid: labelerDid,
        label: 'gore',
        visibility: 'warn',
      ),
    ];

    // Default labelers
    final defaultLabelers = [LabelerPrefItem(did: labelerDid)];

    return Preferences(
      preferences: [
        savedFeedsPreference(defaultFeeds),
        labelersPreference(defaultLabelers),
        ...defaultLabelPrefs,
      ],
    );
  }
}
