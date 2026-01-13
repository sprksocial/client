/// Storage keys used throughout the application
class StorageKeys {
  // Private constructor to prevent instantiation
  StorageKeys._();
  static const String userSession = 'user_session';
  static const String dmAccessToken = 'dm_access_token';
  static const String dmRefreshToken = 'dm_refresh_token';

  /// OAuth keys
  static const String oauthAccessToken = 'oauth_access_token';
  static const String oauthRefreshToken = 'oauth_refresh_token';
  static const String oauthPublicKey = 'oauth_public_key';
  static const String oauthPrivateKey = 'oauth_private_key';
  static const String oauthDpopNonce = 'oauth_dpop_nonce';
  static const String oauthPendingContext = 'oauth_pending_context';
  static const String oauthDid = 'oauth_did';
  static const String oauthHandle = 'oauth_handle';
  static const String oauthPdsEndpoint = 'oauth_pds_endpoint';
  static const String oauthServer = 'oauth_server';

  static const String themeKey = 'app_theme_mode';

  /// Settings
  static const String feedsKey = 'feeds';
  static const String activeFeedKey = 'active_feed';
  static const String preferencesKey = 'preferences';

  /// Labelers
  static const String labelers = 'labelers';
  static const String labelPreferenceKey = 'label_preference';
  static const String defaultLabelsAreSetupKey = 'default_labels_are_setup';

  /// Identity cache
  static const String didToHandleCache = 'did_to_handle_cache';
  static const String handleToDidCache = 'handle_to_did_cache';
  static const String didDocCache = 'did_doc_cache';
  static const String identityCacheTtl = 'identity_cache_ttl';

  /// Post to Bluesky
  static const String postToBskyKey = 'post_to_bsky_enabled';

  /// Story auto deletion
  static const String storyAutoDeleteEnabled = 'story_auto_delete_enabled';
}
