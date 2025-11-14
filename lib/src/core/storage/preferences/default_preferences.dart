import 'package:sparksocial/src/core/network/atproto/data/models/pref_models.dart';

/// Default preferences to use when setting up a new user
class DefaultPreferences {
  DefaultPreferences._();

  /// Get default preferences including default feeds and label preferences
  static Preferences get defaultPreferences {
    // Default feeds: timeline, forYou, latest
    final defaultFeeds = [
      SavedFeed(
        type: 'timeline',
        value: 'following',
        pinned: true,
      ),
      SavedFeed(
        type: 'feed',
        value: 'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids',
        pinned: true,
      ),
      SavedFeed(
        type: 'feed',
        value: 'at://did:plc:cveom2iroj3mt747sd4qqnr2/so.sprk.feed.generator/latest',
        pinned: true,
      ),
    ];

    // Default label preferences
    final defaultLabelPrefs = [
      const Preference.contentLabelPref(
        labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc', // mod.sprk.team
        label: '!hide',
        visibility: 'hide',
      ),
      const Preference.contentLabelPref(
        labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc',
        label: '!no-promote',
        visibility: 'hide',
      ),
      const Preference.contentLabelPref(
        labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc',
        label: '!warn',
        visibility: 'warn',
      ),
      const Preference.contentLabelPref(
        labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc',
        label: '!no-unauthenticated',
        visibility: 'ignore',
      ),
      const Preference.contentLabelPref(
        labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc',
        label: 'dmca-violation',
        visibility: 'hide',
      ),
      const Preference.contentLabelPref(
        labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc',
        label: 'doxxing',
        visibility: 'warn',
      ),
      const Preference.contentLabelPref(
        labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc',
        label: 'nsfl',
        visibility: 'warn',
      ),
      const Preference.contentLabelPref(
        labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc',
        label: 'gore',
        visibility: 'warn',
      ),
    ];

    // Default labelers (mod.sprk.team)
    final defaultLabelers = [
      const LabelerPrefItem(did: 'did:plc:pbgyr67hftvpoqtvaurpsctc'),
    ];

    return Preferences(
      preferences: [
        Preference.savedFeedsPref(items: defaultFeeds),
        Preference.labelersPref(labelers: defaultLabelers),
        ...defaultLabelPrefs,
      ],
    );
  }
}
