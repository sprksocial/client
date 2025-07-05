/// Storage keys used throughout the application
class StorageKeys {
  // Private constructor to prevent instantiation
  StorageKeys._();
  static const String userSession = 'user_session';
  static const String dmAccessToken = 'dm_access_token';
  static const String dmRefreshToken = 'dm_refresh_token';

  static const String themeKey = 'app_theme_mode';

  /// Settings
  static const String feedBlurKey = 'feed_blur_enabled';
  static const String hideAdultContentKey = 'hide_adult_content';
  static const String followModeKey = 'follow_mode';

  static const String feedsKey = 'feeds';
  static const String activeFeedKey = 'active_feed';

  /// Labelers
  static const String followedLabelers = 'followed_labelers';
  static const String labelPreferenceKey = 'label_preference';
  static const String defaultLabelsAreSetupKey = 'default_labels_are_setup';

  /// Identity cache
  static const String didToHandleCache = 'did_to_handle_cache';
  static const String handleToDidCache = 'handle_to_did_cache';
  static const String didDocCache = 'did_doc_cache';
  static const String identityCacheTtl = 'identity_cache_ttl';

  /// Post to Bluesky
  static const String postToBskyKey = 'post_to_bsky_enabled';
}
