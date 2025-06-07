import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:fvp/fvp.dart' as fvp;

import 'src/core/di/service_locator.dart';
import 'src/core/theme/data/models/app_theme.dart';
import 'src/core/utils/logging/logging.dart';
import 'src/core/utils/logging/riverpod_logger.dart';
import 'src/sprk_app.dart';

// Global RouteObserver instance
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Initialize IMGLY Video Editor SDK
  // Note: You need to add a license file to assets folder and reference it in pubspec.yaml
  // VESDK.unlockWithLicense("assets/licenses/vesdk_license");

  // Force dark status bar and navigation bar
  SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemUiStyle);

  fvp.registerWith();

  // Initialize dependencies for new architecture
  await configureDependencies();

  // Setup logging for production/debug
  _setupLogging();

  // Create a ProviderContainer with the Riverpod logger
  final container = riverpod.ProviderContainer(observers: [SparkRiverpodLogger()]);
  runApp(riverpod.UncontrolledProviderScope(container: container, child: SprkApp()));
}

/// Setup logging framework based on environment
void _setupLogging() {
  final logService = sl<LogService>();

  // Set log level based on debug mode
  if (kDebugMode) {
    logService.setGlobalLogLevel(LogLevel.debug);
    logService.appLogger.i('Debug logging enabled');
  } else {
    logService.setGlobalLogLevel(LogLevel.info);
    logService.appLogger.i('Production logging enabled');
  }
}
