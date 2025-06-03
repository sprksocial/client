import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/di/service_locator.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:flutter/services.dart';

import 'core/theme/data/models/app_theme.dart';
import 'core/theme/domain/theme_provider.dart';
import 'features/settings/providers/settings_provider.dart';

/// SprkApp is the root widget of the new architecture.
/// As features are migrated, they will be integrated here.
class SprkApp extends ConsumerStatefulWidget {
  const SprkApp({super.key});

  @override
  ConsumerState<SprkApp> createState() => _SprkAppState();
}

class _SprkAppState extends ConsumerState<SprkApp> {
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    // Initialize theme provider
    ref.read(themeProvider.notifier).initialize();
    ref.read(settingsProvider.notifier).loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    // Force dark status bar and navigation bar
    SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemUiStyle);

    // Watch theme mode from the provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Spark',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      routerConfig: _appRouter.config(),
    );
  }
}

/// This method configures all dependencies required for the new architecture.
/// It should be called before the app starts.
Future<void> configureDependencies() async {
  // Initialize GetIt
  await initServiceLocator();
}
