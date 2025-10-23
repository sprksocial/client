import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:fvp/fvp.dart' as fvp;
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparksocial/src/core/di/service_locator.dart';
import 'package:sparksocial/src/core/ui/theme/data/models/app_theme.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/core/utils/logging/riverpod_logger.dart';
import 'package:sparksocial/src/sprk_app.dart';

// Global RouteObserver instance
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Force dark status bar and navigation bar
  SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemUiStyle);

  fvp.registerWith();

  await initServiceLocator();

  // Setup logging for production/debug
  _setupLogging();

  // Initialize auth repository
  await _initializeAuth();

  // Create a ProviderContainer with the Riverpod logger
  final container = riverpod.ProviderContainer(observers: [SparkRiverpodLogger()]);
  runApp(riverpod.UncontrolledProviderScope(container: container, child: const SprkApp()));
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

/// Initialize auth repository and wait for it to be ready
Future<void> _initializeAuth() async {
  final logService = sl<LogService>();
  final logger = logService.getLogger('AppInitialization');
  
  try {
    final authRepository = sl<AuthRepository>();
    
    if (authRepository is AuthRepositoryImpl) {
      logger.d('Waiting for AuthRepository initialization...');
      await authRepository.initializationComplete;
      logger.d('AuthRepository initialized successfully');
    }
  } catch (e) {
    logger.e('AuthRepository initialization failed', error: e);
  }
}
