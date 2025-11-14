import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/design_system/theme/app_theme.dart';
import 'package:sparksocial/src/core/l10n/app_localizations.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/theme/providers/theme_provider.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class SprkApp extends ConsumerStatefulWidget {
  const SprkApp({super.key});

  @override
  ConsumerState<SprkApp> createState() => _SprkAppState();
}

class _SprkAppState extends ConsumerState<SprkApp> {
  final _appRouter = AppRouter();
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('SprkApp');

  @override
  void initState() {
    super.initState();
    ref.read(themeProvider.notifier).initialize();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      _logger.d('Syncing user preferences from server...');
      final settingsNotifier = ref.read(settingsProvider.notifier);
      await settingsNotifier.syncPreferencesFromServer();
      _logger.d('User preferences synced successfully');

      _logger.d('Loading settings...');
      await settingsNotifier.loadSettings();

      if (!mounted) return;

      final activeFeed = ref.read(settingsProvider).activeFeed;
      _logger.d('Active feed: ${activeFeed.config.value}');

      final feedNotifier = ref.read(feedNotifierProvider(activeFeed).notifier);
      feedNotifier.loadAndUpdateFirstLoad();
      _logger.d('Feed loading started');
    } catch (e) {
      _logger.w('Error during app initialization', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force dark status bar and navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Spark',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      routerConfig: _appRouter.config(),
    );
  }
}
