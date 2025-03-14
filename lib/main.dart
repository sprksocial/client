import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
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
import 'services/auth_service.dart';
import 'services/profile_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We'll use a builder to get access to the platform brightness
    return CupertinoTheme(
      data: AppTheme.theme,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProxyProvider<AuthService, ProfileService>(
            create: (context) => ProfileService(context.read<AuthService>()),
            update: (_, authService, previousProfileService) =>
              previousProfileService ?? ProfileService(authService),
          ),
        ],
        child: CupertinoApp(
          title: 'Spark',
          theme: AppTheme.theme,
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const MainScreen(),
            '/login': (context) => const LoginScreen(),
            '/auth': (context) => const AuthPromptScreen(),
          },
        ),
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

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final bool isHomePage = navigationProvider.currentIndex == 0;

    // Creating the list of screens for navigation
    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      const SizedBox.shrink(), // Placeholder for create button
      const MessagesScreen(),
      ProfileScreen(did: authService.session?.did),
    ];

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(context, isHomePage),
      child: Stack(
        children: [
          // Main content
          IndexedStack(
            index: navigationProvider.currentIndex,
            children: screens,
          ),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getNavBackgroundColor(context, isHomePage),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        context,
                        0,
                        'Home',
                        Ionicons.home_outline,
                        Ionicons.home,
                      ),
                      _buildNavItem(
                        context,
                        1,
                        'Discover',
                        Ionicons.compass_outline,
                        Ionicons.compass,
                      ),
                      _buildCreateButton(context),
                      _buildNavItem(
                        context,
                        3,
                        'Messages',
                        Ionicons.chatbubble_outline,
                        Ionicons.chatbubble,
                      ),
                      _buildNavItem(
                        context,
                        4,
                        'Profile',
                        Ionicons.person_outline,
                        Ionicons.person,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String label, IconData iconOutline, IconData iconFilled) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final bool isSelected = navigationProvider.currentIndex == index;

    final bool isHomePage = navigationProvider.currentIndex == 0;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        navigationProvider.updateIndex(index);
      },
      child: Icon(
        isSelected ? iconFilled : iconOutline,
        color: isSelected
            ? AppTheme.getSelectedIconColor(context, isHomePage)
            : AppTheme.getUnselectedIconColor(context, isHomePage),
        size: 26,
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) => const CreateVideoScreen(),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(
            Ionicons.add,
            color: AppColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
