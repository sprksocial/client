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
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: CupertinoApp(
        title: 'TikTok Clone',
        theme: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.systemPink,
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const MainScreen(),
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

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    // Creating the list of screens for navigation
    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      const SizedBox.shrink(), // Placeholder for create button
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
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
                color: navigationProvider.currentIndex == 0 
                    ? CupertinoColors.black 
                    : CupertinoColors.systemBackground,
                border: const Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey5,
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
                        Ionicons.search_outline, 
                        Ionicons.search,
                      ),
                      _buildCreateButton(context),
                      _buildNavItem(
                        context, 
                        3, 
                        'Inbox', 
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
    final bool isDarkMode = navigationProvider.currentIndex == 0;
    
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        navigationProvider.updateIndex(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? iconFilled : iconOutline,
            color: isSelected 
                ? (isDarkMode ? CupertinoColors.white : CupertinoColors.activeBlue)
                : (isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected 
                  ? (isDarkMode ? CupertinoColors.white : CupertinoColors.activeBlue)
                  : (isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final bool isDarkMode = navigationProvider.currentIndex == 0;

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
          gradient: const LinearGradient(
            colors: [
              CupertinoColors.systemPink,
              CupertinoColors.systemBlue,
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(
            Ionicons.add,
            color: CupertinoColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
