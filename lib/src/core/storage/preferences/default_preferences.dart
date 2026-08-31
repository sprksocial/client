import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';

/// Default preferences to use when setting up a new user
class DefaultPreferences {
  DefaultPreferences._();

  static const theVidsFeedUri =
      'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids';
  static const discoverFeedUri =
      'at://did:plc:cveom2iroj3mt747sd4qqnr2/so.sprk.feed.generator/discover';

  /// Get default preferences including default feeds and label preferences
  /// [modServiceDid] The DID of the mod service labeler (required)
  static Preferences defaultPreferences({required String modServiceDid}) {
    final labelerDid = modServiceDid;
    // Default feeds: timeline, forYou, latest
    final defaultFeeds = [
      makeSavedFeed(type: 'timeline', value: 'following', pinned: true),
      makeSavedFeed(type: 'feed', value: theVidsFeedUri, pinned: true),
      makeSavedFeed(type: 'feed', value: discoverFeedUri, pinned: true),
    ];

    // Default labelers
    final defaultLabelers = [LabelerPrefItem(did: labelerDid)];

    return Preferences(
      preferences: [
        savedFeedsPreference(defaultFeeds),
        labelersPreference(defaultLabelers),
      ],
    );
  }
}
