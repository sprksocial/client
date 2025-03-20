import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/create_video_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/auth_prompt_screen.dart';
import 'screens/test_actions_screen.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/identity_service.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  fvp.registerWith();
  runApp(const MyApp());
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
        ChangeNotifierProxyProvider<AuthService, ProfileService>(
          create: (context) => ProfileService(context.read<AuthService>()),
          update: (_, authService, previousProfileService) => previousProfileService ?? ProfileService(authService),
        ),
      ],
      child: MaterialApp(
        title: 'Spark',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.light(primary: AppColors.primary, secondary: AppColors.accent),
          textTheme: Typography.blackMountainView.apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        darkTheme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.darkBackground,
          colorScheme: ColorScheme.dark(primary: AppColors.primary, secondary: AppColors.accent),
          textTheme: Typography.whiteMountainView.apply(bodyColor: AppColors.textLight, displayColor: AppColors.textLight),
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const MainScreen(),
          '/login': (context) => const LoginScreen(),
          '/auth': (context) => const AuthPromptScreen(),
          '/test': (context) => const TestActionsScreen(),
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
  final List<Widget?> _screens = List.filled(5, null);

  Widget _getScreen(int index, BuildContext context) {
    if (_screens[index] != null) {
      return _screens[index]!;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    switch (index) {
      case 0:
        _screens[0] = const HomeScreen();
        break;
      case 1:
        _screens[1] = const SearchScreen();
        break;
      case 2:
        _screens[2] = const SizedBox.shrink();
        break;
      case 3:
        _screens[3] = const MessagesScreen();
        break;
      case 4:
        _screens[4] = ProfileScreen(key: Key(authService.session?.did ?? ''), did: authService.session?.did);
        break;
    }

    return _screens[index]!;
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black, //esta eh a porra da cor mais importante desse caralho de aplicativo.
      body: _getScreen(navigationProvider.currentIndex, context),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          backgroundColor: AppTheme.getNavBackgroundColor(context),
          height: 60,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: AppTheme.getSelectedIconColor(context), size: 26);
            }
            return IconThemeData(color: AppTheme.getUnselectedIconColor(context), size: 26);
          }),
        ),
        child: NavigationBar(
          selectedIndex: navigationProvider.currentIndex == 2 ? 0 : navigationProvider.currentIndex,
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
              icon: Icon(FluentIcons.chat_24_regular),
              selectedIcon: Icon(FluentIcons.chat_24_filled),
              label: 'Messages',
            ),
            const NavigationDestination(
              icon: Icon(FluentIcons.person_24_regular),
              selectedIcon: Icon(FluentIcons.person_24_filled),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
