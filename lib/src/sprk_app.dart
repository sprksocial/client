import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/di/service_locator.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';

/// SprkApp is the root widget of the new architecture.
/// As features are migrated, they will be integrated here.
class SprkApp extends ConsumerWidget {
  SprkApp({super.key}) : _appRouter = AppRouter();
  
  final AppRouter _appRouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force dark status bar and navigation bar
    SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemUiStyle);
    
    return MaterialApp.router(
      title: 'Spark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Configure theme according to the app's design system
      ),
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}

/// This method configures all dependencies required for the new architecture.
/// It should be called before the app starts.
Future<void> configureDependencies() async {
  // Initialize GetIt
  await initServiceLocator();
}
