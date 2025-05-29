/// Storage keys used throughout the application
class StorageKeys {
  static const String userSession = 'user_session';

  static const String themeKey = 'app_theme_mode';

  /// Settings
  static const String feedBlurKey = 'feed_blur_enabled';
  static const String hideAdultContentKey = 'hide_adult_content';

  static const String feedsKey = 'feeds';
  static const String selectedFeedIndexKey = 'selected_feed_index';

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
