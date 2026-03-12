import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConfig manages application-wide configuration settings
/// loaded from environment variables or .env files.
///
/// All app configuration should be accessed through this class
/// to maintain a single source of truth for application settings.
class AppConfig {
  /// Base URL for the video processing service.
  static String get videoServiceUrl =>
      _getStringValue('VIDEO_SERVICE_URL', 'http://localhost:3000');

  /// License key for the img.ly editor.
  static String get license => _getStringValue('SHOWCASES_LICENSE_FLUTTER', '');

  /// URL for the app view (web view display).
  static String get appViewUrl =>
      _getStringValue('SPRK_APPVIEW_URL', 'http://localhost:3000');

  /// Base URL for the messages service (chat service).
  static String get messagesServiceUrl =>
      _getStringValue('MESSAGES_SERVICE_URL', 'http://localhost:3000');

  /// Allowed web auth callback origin for localhost OAuth testing.
  static String get webAuthOrigin => _getStringValue('WEB_AUTH_ORIGIN', '');

  /// Optional OAuth client metadata URL override.
  ///
  /// Used for testing with an alternative registered OAuth client.
  static String get oauthClientMetadataUrl =>
      _getStringValue('OAUTH_CLIENT_METADATA_URL', '');

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
    return dotenv.env[key] ?? defaultValue;
  }

  /// Helper method to retrieve boolean values from environment with defaults
  static bool _getBoolValue(String key, bool defaultValue) {
    final value = dotenv.env[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Helper method to retrieve integer values from environment with defaults
  static int _getIntValue(String key, int defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Helper method to retrieve double values from environment with defaults
  static double _getDoubleValue(String key, double defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Validates that all required configuration values are provided
  static bool validateConfig() {
    // Add validation logic as needed
    return videoServiceUrl.isNotEmpty && appViewUrl.isNotEmpty;
  }
}
