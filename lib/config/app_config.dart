import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get videoServiceUrl => dotenv.env['VIDEO_SERVICE_URL'] ?? 'http://localhost:3000';
  static String get appViewUrl => dotenv.env['SPRK_APPVIEW_URL'] ?? 'http://localhost:3000';
  static bool get signupsDisabled => (dotenv.env['SIGNUPS_DISABLED']?.toLowerCase() ?? 'false') == 'true';
}
