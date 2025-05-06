/// Storage keys used throughout the application
class StorageKeys {
  /// Authentication related keys
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String username = 'username';
  static const String email = 'email';
  static const String userSession = 'user_session';
  
  /// App settings
  static const String theme = 'app_theme';
  static const String locale = 'app_locale';
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  
  /// User preferences
  static const String notificationsEnabled = 'notifications_enabled';
  static const String cacheSize = 'cache_size';
  static const String videoQuality = 'video_quality';
  static const String audioQuality = 'audio_quality';
  
  /// Content related
  static const String savedPosts = 'saved_posts';
  static const String recentSearches = 'recent_searches';
  static const String draftPosts = 'draft_posts';
  
  // Private constructor to prevent instantiation
  StorageKeys._();
} 