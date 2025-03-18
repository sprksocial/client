import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get videoServiceUrl => dotenv.env['VIDEO_SERVICE_URL'] ?? 'http://localhost:3000';
}