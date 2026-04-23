import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConfig manages application-wide configuration settings
/// loaded from environment variables or .env files.
///
/// All app configuration should be accessed through this class
/// to maintain a single source of truth for application settings.
class AppConfig {
  /// Base URL for the video processing service.
  static String get videoServiceUrl =>
      _getStringValue('VIDEO_SERVICE_URL', 'https://video.sprk.so');

  /// License key for the img.ly editor.
  static String get license => _getStringValue('SHOWCASES_LICENSE_FLUTTER', '');

  /// URL for the app view (web view display).
  static String get appViewUrl =>
      _getStringValue('SPRK_APPVIEW_URL', 'https://api.sprk.so');

  /// Base URL for the Bluesky appview.
  static String get bskyAppViewUrl =>
      _getStringValue('BSKY_APPVIEW_URL', 'https://api.bsky.app');

  /// DID for the Spark moderation service.
  static String get modDid => _getStringValue(
    'MOD_DID',
    'did:plc:pbgyr67hftvpoqtvaurpsctc#atproto_labeler',
  );

  /// DID for the Bluesky moderation service.
  static String get bskyModDid => _getStringValue(
    'BSKY_MOD_DID',
    'did:plc:ar7c4by46qjdydhdevvrndac#atproto_labeler',
  );

  /// Base URL for the messages service (chat service).
  static String get messagesServiceUrl =>
      _getStringValue('MESSAGES_SERVICE_URL', 'https://chat.sprk.so');

  /// Base URL for the AIP OAuth server.
  static String get aipBaseUrl =>
      _getStringValue('AIP_BASE_URL', 'https://auth.sprk.so');

  /// Service DID for the chat service (used for service auth).
  static String get chatServiceDid =>
      _getStringValue('CHAT_SERVICE_DID', 'did:web:chat.sprk.so');

  /// Whether new user registrations are disabled.
  static bool get signupsDisabled => _getBoolValue('SIGNUPS_DISABLED', false);

  /// API request timeout in seconds.
  static int get apiTimeoutSeconds => _getIntValue('API_TIMEOUT_SECONDS', 30);

  /// Maximum upload file size in MB.
  static double get maxUploadSizeMB =>
      _getDoubleValue('MAX_UPLOAD_SIZE_MB', 100);

  /// The current application environment (development, production, etc.)
  static String get environment =>
      _getStringValue('ENVIRONMENT', 'development');

  /// Checks if the app is running in development mode.
  static bool get isDevelopment => environment == 'development';

  /// Checks if the app is running in production mode.
  static bool get isProduction => environment == 'production';

  /// Helper method to retrieve string values from environment with defaults
  static String _getStringValue(String key, String defaultValue) {
    try {
      return dotenv.env[key] ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Helper method to retrieve boolean values from environment with defaults
  static bool _getBoolValue(String key, bool defaultValue) {
    String? value;
    try {
      value = dotenv.env[key]?.toLowerCase();
    } catch (_) {
      return defaultValue;
    }
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Helper method to retrieve integer values from environment with defaults
  static int _getIntValue(String key, int defaultValue) {
    String? value;
    try {
      value = dotenv.env[key];
    } catch (_) {
      return defaultValue;
    }
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Helper method to retrieve double values from environment with defaults
  static double _getDoubleValue(String key, double defaultValue) {
    String? value;
    try {
      value = dotenv.env[key];
    } catch (_) {
      return defaultValue;
    }
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Validates that all required configuration values are provided
  static bool validateConfig() {
    // Add validation logic as needed
    return videoServiceUrl.isNotEmpty && appViewUrl.isNotEmpty;
  }
}
