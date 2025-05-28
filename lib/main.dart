import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:fvp/fvp.dart' as fvp;
import 'package:provider/provider.dart';

import 'screens/auth_prompt_screen.dart';
import 'screens/create_video_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/splash_screen.dart';
import 'services/actions_service.dart';
import 'services/auth_service.dart';
import 'services/comments_service.dart';
import 'services/identity_service.dart';
import 'services/labeler_manager.dart';
import 'services/profile_service.dart';
import 'services/settings_service.dart';
import 'services/upload_service.dart';
import 'services/video_service.dart';
import 'src/core/di/service_locator.dart';
import 'src/core/theme/data/models/app_theme.dart';
import 'src/core/theme/data/models/colors.dart';
import 'src/core/utils/logging/logging.dart';
import 'src/core/utils/logging/riverpod_logger.dart';
import 'src/sprk_app.dart';
import 'widgets/upload/upload_progress_indicator.dart';

// Global RouteObserver instance
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

const bool useNewArchitecture = true;

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

  if (useNewArchitecture) {
    // Initialize dependencies for new architecture
    await configureDependencies();

    // Setup logging for production/debug
    _setupLogging();

    // Create a ProviderContainer with the Riverpod logger
    final container = riverpod.ProviderContainer(observers: [SparkRiverpodLogger()]);
    runApp(riverpod.UncontrolledProviderScope(container: container, child: SprkApp()));
  } else {
    // Run the legacy app
    runApp(const MyApp());
  }
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CachedIdentityService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => UploadService()),
        ChangeNotifierProxyProvider<AuthService, ProfileService>(
          create: (context) => ProfileService(context.read<AuthService>()),
          update: (_, authService, previousProfileService) => previousProfileService ?? ProfileService(authService),
        ),
        ChangeNotifierProxyProvider<AuthService, ActionsService>(
          create: (context) => ActionsService(context.read<AuthService>()),
          update: (_, authService, previousActionsService) => previousActionsService ?? ActionsService(authService),
        ),
        ChangeNotifierProxyProvider2<AuthService, ProfileService, CommentsService>(
          create: (context) => CommentsService(context.read<AuthService>(), context.read<ProfileService>()),
          update: (_, authService, profileService, previousCommentsService) =>
              previousCommentsService ?? CommentsService(authService, profileService),
        ),
        ProxyProvider<AuthService, VideoService>(
          create: (context) => VideoService(context.read<AuthService>()),
          update: (_, authService, previousVideoService) => previousVideoService ?? VideoService(authService),
        ),
        ChangeNotifierProxyProvider2<AuthService, SettingsService, LabelerManager>(
          create: (context) => LabelerManager(context.read<AuthService>(), context.read<SettingsService>()),
          update: (_, authService, settingsService, previousLabelerManager) =>
              previousLabelerManager ?? LabelerManager(authService, settingsService),
        ),
      ],
      child: MaterialApp(
        title: 'Spark',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.light(primary: AppColors.primary, secondary: AppColors.accent, surface: Colors.black),
          textTheme: Typography.blackMountainView.apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        darkTheme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.dark(primary: AppColors.primary, secondary: AppColors.accent, surface: Colors.black),
          textTheme: Typography.whiteMountainView.apply(bodyColor: AppColors.textLight, displayColor: AppColors.textLight),
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        themeMode: ThemeMode.system,
        navigatorObservers: [routeObserver],
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const MainScreen(),
          '/login': (context) => const LoginScreen(),
          '/auth': (context) => const AuthPromptScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
        },
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              // Global upload indicator positioned at bottom right
              Positioned(
                bottom: 20,
                right: 20,
                child: Consumer<UploadService>(
                  builder: (context, uploadService, _) {
                    return uploadService.isAnyTaskActive || uploadService.isAnyTaskCompleted
                        ? UploadProgressIndicator(
                            isUploading: uploadService.isAnyTaskActive,
                            isCompleted: uploadService.isAnyTaskCompleted && !uploadService.isAnyTaskActive,
                            onDismiss: () => uploadService.clearCompletedTasks(),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    final authService = Provider.of<AuthService>(context, listen: false);
    _screens.addAll([
      const HomeScreen(),
      const SearchScreen(),
      const SizedBox.shrink(), // Placeholder for index 2 (Create)
      const MessagesScreen(),
      ProfileScreen(key: Key(authService.session?.did ?? ''), did: authService.session?.did),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      // Use IndexedStack to keep screens alive
      body: IndexedStack(index: navigationProvider.currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationProvider.currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(fullscreenDialog: true, builder: (context) => const CreateVideoScreen()));
          } else {
            navigationProvider.updateIndex(index);
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(FluentIcons.home_24_regular),
            selectedIcon: Icon(FluentIcons.home_24_filled),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(FluentIcons.compass_northwest_24_regular),
            selectedIcon: Icon(FluentIcons.compass_northwest_24_filled),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Container(
              width: 48,
              height: 36,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Icon(FluentIcons.add_24_filled, color: AppColors.white, size: 24)),
            ),
            label: 'Create',
          ),
          const NavigationDestination(
            icon: Icon(FluentIcons.mail_inbox_all_24_regular),
            selectedIcon: Icon(FluentIcons.mail_inbox_all_24_filled),
            label: 'Inbox',
          ),
          const NavigationDestination(
            icon: Icon(FluentIcons.person_24_regular),
            selectedIcon: Icon(FluentIcons.person_24_filled),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
