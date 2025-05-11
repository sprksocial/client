/// Storage keys used throughout the application
class StorageKeys {
  static const String userSession = 'user_session';

  static const String themeKey = 'app_theme_mode';

  /// Settings
  static const String feedBlurKey = 'feed_blur_enabled';
  static const String hideAdultContentKey = 'hide_adult_content';
  static const String followingFeedEnabledKey = 'following_feed_enabled';
  static const String forYouFeedEnabledKey = 'for_you_feed_enabled';
  static const String latestFeedEnabledKey = 'latest_feed_enabled';
  static const String selectedFeedTypeKey = 'selected_feed_type';

  /// Profile cache keys
  static const String bskyProfileCachePrefix = 'bsky_profile_';
  static const String sprkProfileCachePrefix = 'sprk_profile_';

  /// Labelers
  static const String followedLabelers = 'followed_labelers';
  static const String labelerPrefix = 'labeler_';
  static const String labelPreferencePrefix = 'label_pref_';

  /// Identity cache
  static const String didToHandleCache = 'did_to_handle_cache';
  static const String handleToDidCache = 'handle_to_did_cache';
  static const String didDocCache = 'did_doc_cache';
  static const String identityCacheTtl = 'identity_cache_ttl';

  // Private constructor to prevent instantiation
  StorageKeys._();
}
