import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConfig manages application-wide configuration settings
/// loaded from environment variables or .env files.
/// Not to be confused with the settings feature, which is a separate feature that manages user settings.
///
/// All app configuration should be accessed through this class
/// to maintain a single source of truth for application settings.
class AppConfig {
  /// Base URL for the video processing service.
  static String get videoServiceUrl =>
      _getStringValue('VIDEO_SERVICE_URL', 'http://localhost:3000');

  /// URL for the app view (web view display).
  static String get appViewUrl =>
      _getStringValue('SPRK_APPVIEW_URL', 'http://localhost:3000');

  /// Whether new user registrations are disabled.
  static bool get signupsDisabled =>
      _getBoolValue('SIGNUPS_DISABLED', false);

  /// API request timeout in seconds.
  static int get apiTimeoutSeconds =>
      _getIntValue('API_TIMEOUT_SECONDS', 30);

  /// Maximum upload file size in MB.
  static double get maxUploadSizeMB =>
      _getDoubleValue('MAX_UPLOAD_SIZE_MB', 100.0);

  /// The current application environment (development, production, etc.)
  static String get environment =>
      _getStringValue('ENVIRONMENT', 'development');

  /// Checks if the app is running in development mode.
  static bool get isDevelopment => environment == 'development';

  /// Checks if the app is running in production mode.
  static bool get isProduction => environment == 'production';

  /// Base URL for the chat service (Socket.io server).
  static String get chatServiceUrl =>
      _getStringValue('CHAT_SERVICE_URL', 'http://localhost:3000');

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
