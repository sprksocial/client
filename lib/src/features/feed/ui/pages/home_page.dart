import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/home/feed_pages_view.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/home/feed_settings_handler.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/home/feed_type_helper.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/home/home_app_bar.dart';
import 'package:visibility_detector/visibility_detector.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController();
  bool _isHomeScreenVisible = true;
  late final FeedTypeHelper _feedTypeHelper;
  
  @override
  void initState() {
    super.initState();
    _feedTypeHelper = FeedTypeHelper(ref, _pageController);
    _feedTypeHelper.initializePageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    return VisibilityDetector(
      key: const Key('home_screen_visibility'),
      onVisibilityChanged: (visibilityInfo) {
        final isVisible = visibilityInfo.visibleFraction > 0;
        if (_isHomeScreenVisible != isVisible) {
          setState(() {
            _isHomeScreenVisible = isVisible;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            FeedPagesView(
              pageController: _pageController,
              isHomeScreenVisible: _isHomeScreenVisible,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HomeAppBar(
                onSettingsTap: () {
                  final settingsHandler = FeedSettingsHandler(context, ref);
                  settingsHandler.showFeedSettingsSheet();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 