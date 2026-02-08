import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:fvp/fvp.dart' as fvp;
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:spark/src/core/di/service_locator.dart';
import 'package:spark/src/core/ui/theme/data/models/app_theme.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/core/utils/logging/riverpod_logger.dart';
import 'package:spark/src/sprk_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Force dark status bar and navigation bar
  SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemUiStyle);

  fvp.registerWith();

  await initServiceLocator();

  // Setup logging for production/debug
  _setupLogging();

  // Initialize auth repository
  await _initializeAuth();

  // Create a ProviderContainer with the Riverpod logger
  final container = riverpod.ProviderContainer(
    observers: [SparkRiverpodLogger()],
  );
  runApp(
    riverpod.UncontrolledProviderScope(
      container: container,
      child: const SprkApp(),
    ),
  );
}

/// Setup logging framework based on environment
void _setupLogging() {
  sl<LogService>().setGlobalLogLevel(LogLevel.warning);
}

/// Initialize auth repository and wait for it to be ready
Future<void> _initializeAuth() async {
  final logService = sl<LogService>();
  final logger = logService.getLogger('AppInitialization');

  try {
    final authRepository = sl<AuthRepository>();

    if (authRepository is AuthRepositoryImpl) {
      await authRepository.initializationComplete;
    }
  } catch (e) {
    logger.e('AuthRepository initialization failed', error: e);
  }
}
