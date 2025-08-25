import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/l10n/app_localizations.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/theme/data/models/app_theme.dart';
import 'package:sparksocial/src/core/ui/theme/providers/theme_provider.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    // Force dark status bar and navigation bar
    SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemUiStyle);

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Spark',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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
