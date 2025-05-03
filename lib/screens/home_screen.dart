import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../main.dart';
import '../services/feed_settings_service.dart';
import '../utils/app_colors.dart';
import '../widgets/feed/feed_selector.dart';
import '../widgets/feed_settings/feed_settings_sheet.dart';
import 'feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FeedSettingsService _feedSettings = FeedSettingsService();
  final PageController _pageController = PageController();
  int _selectedTabIndex = 0;
  List<FeedOption> _currentFeedOptions = [];
  List<Widget> _feedScreens = [];
  late final NavigationProvider _navProvider;
  bool _isHomeScreenActive = true;
  bool _isHomeScreenVisible = true;

  @override
  void initState() {
    super.initState();
    _navProvider = Provider.of<NavigationProvider>(context, listen: false);
    _isHomeScreenActive = _navProvider.currentIndex == 0;
    _navProvider.addListener(_onNavIndexChanged);

    _initializeScreen();
    _feedSettings.addListener(_onFeedSettingsChanged);
  }

  /// Pause or resume media when home tab selection changes.
  void _onNavIndexChanged() {
    final isActive = _navProvider.currentIndex == 0;
    if (isActive != _isHomeScreenActive) {
      setState(() {
        _isHomeScreenActive = isActive;
        _buildFeedScreens();
      });
    }
  }

  @override
  void dispose() {
    _navProvider.removeListener(_onNavIndexChanged);
    _pageController.removeListener(_onPageChanged);
    _feedSettings.removeListener(_onFeedSettingsChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onFeedSettingsChanged() {
    if (mounted) {
      final oldSelectedFeedType = _currentFeedOptions.isNotEmpty ? _currentFeedOptions[_selectedTabIndex].value : -1;
      _buildFeedScreens();
      final newIndex = _currentFeedOptions.indexWhere((option) => option.value == oldSelectedFeedType);

      int targetIndex = (newIndex != -1) ? newIndex : (_currentFeedOptions.isNotEmpty ? 0 : -1);

      setState(() {
        _selectedTabIndex = targetIndex;
        if (_pageController.hasClients && targetIndex != -1) {
          _pageController.jumpToPage(_selectedTabIndex);
        }
      });
    }
  }

  Future<void> _initializeScreen() async {
    await _feedSettings.loadPreferences();
    _buildFeedScreens();
    _pageController.addListener(_onPageChanged);

    _selectedTabIndex = _currentFeedOptions.indexWhere((option) => option.value == _feedSettings.selectedFeedType.value);
    if (_selectedTabIndex == -1 && _currentFeedOptions.isNotEmpty) {
      _selectedTabIndex = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_selectedTabIndex);
      }
    });
  }

  void _onPageChanged() {
    if (_pageController.page == null) return;
    final currentPage = _pageController.page!.round();
    if (currentPage < _currentFeedOptions.length && currentPage != _selectedTabIndex) {
      _feedSettings.setSelectedFeedType(FeedType.fromValue(_currentFeedOptions[currentPage].value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return VisibilityDetector(
      key: const Key('home_screen_visibility'),
      onVisibilityChanged: (visibilityInfo) {
        final isVisible = visibilityInfo.visibleFraction > 0;
        if (_isHomeScreenVisible != isVisible) {
          setState(() {
            _isHomeScreenVisible = isVisible;
            _buildFeedScreens();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // TODO: why is the topbar not a topbar bro what the hell are we doing
        body: Stack(children: [_buildMainContent(), _buildTopBar(topPadding, isDarkMode, _currentFeedOptions)]),
      ),
    );
  }

  void _buildFeedScreens() {
    final options = <FeedOption>[];
    final screens = <Widget>[];
    int feedIndex = 0;

    if (_feedSettings.followingFeedEnabled) {
      final bool isVisible = _isHomeScreenActive && _isHomeScreenVisible && (_selectedTabIndex == feedIndex);
      options.add(const FeedOption(label: 'Following', value: 0));
      screens.add(
        ChangeNotifierProvider<FeedSettingsService>.value(
          key: const ValueKey('feed_0'),
          value: _feedSettings,
          child: FeedScreen(feedType: 0, isParentFeedVisible: isVisible),
        ),
      );
      feedIndex++;
    }

    if (_feedSettings.forYouFeedEnabled) {
      final bool isVisible = _isHomeScreenActive && _isHomeScreenVisible && (_selectedTabIndex == feedIndex);
      options.add(const FeedOption(label: 'For You', value: 1));
      screens.add(
        ChangeNotifierProvider<FeedSettingsService>.value(
          key: const ValueKey('feed_1'),
          value: _feedSettings,
          child: FeedScreen(feedType: 1, isParentFeedVisible: isVisible),
        ),
      );
      feedIndex++;
    }

    if (_feedSettings.latestFeedEnabled) {
      final bool isVisible = _isHomeScreenActive && _isHomeScreenVisible && (_selectedTabIndex == feedIndex);
      options.add(const FeedOption(label: 'Latest', value: 2));
      screens.add(
        ChangeNotifierProvider<FeedSettingsService>.value(
          key: const ValueKey('feed_2'),
          value: _feedSettings,
          child: FeedScreen(feedType: 2, isParentFeedVisible: isVisible),
        ),
      );
      feedIndex++;
    }

    _currentFeedOptions = options;
    if (!listEquals(_feedScreens, screens)) {
      _feedScreens = screens;
    }
  }

  Widget _buildMainContent() {
    return PageView(
      controller: _pageController,
      children: _feedScreens,
      onPageChanged: (index) {
        if (index < _currentFeedOptions.length) {
          setState(() {
            _selectedTabIndex = index;
            _buildFeedScreens();
          });
          _feedSettings.setSelectedFeedType(FeedType.fromValue(_currentFeedOptions[index].value));
        }
      },
    );
  }

  Widget _buildTopBar(double topPadding, bool isDarkMode, List<FeedOption> feedOptions) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding + 10, left: 16.0, right: 16.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 30),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
                  child:
                      feedOptions.isNotEmpty
                          ? FeedSelector(
                            options: feedOptions,
                            selectedValue: feedOptions.isNotEmpty ? feedOptions[_selectedTabIndex].value : 0,
                            onOptionSelected: _onFeedSelected,
                          )
                          : const SizedBox(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(FluentIcons.options_24_regular),
              color: AppColors.lightLavender,
              iconSize: 30,
              onPressed: () => _showFeedSettingsSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onFeedSelected(int value) async {
    final index = _currentFeedOptions.indexWhere((option) => option.value == value);
    if (index != -1 && index != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = index;
      });
      _buildFeedScreens();

      if (_pageController.hasClients) {
        await _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
      await _feedSettings.setSelectedFeedType(FeedType.fromValue(value));
    }
  }

  void _showFeedSettingsSheet(BuildContext context) {
    final feedSettings = [
      FeedSetting(feedName: 'Following', settingType: 'following_feed', isEnabled: _feedSettings.followingFeedEnabled),
      FeedSetting(feedName: 'For You', settingType: 'for_you_feed', isEnabled: _feedSettings.forYouFeedEnabled),
      FeedSetting(feedName: 'Latest', settingType: 'latest_feed', isEnabled: _feedSettings.latestFeedEnabled),
      FeedSetting(
        feedName: 'Disable Background Blur',
        settingType: 'disable_background_blur',
        description: 'Turn off the background blur effect on media',
        isEnabled: _feedSettings.disableVideoBackgroundBlur,
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: Navigator.of(context),
      ),
      builder:
          (context) => GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: FeedSettingsSheet(feedSettings: feedSettings, onToggleChanged: _handleSettingToggle),
          ),
    ).then((_) {
      // Rebuild feeds when the sheet is closed
      _onFeedSettingsChanged();
    });
  }

  Future<void> _handleSettingToggle(String settingType, bool isEnabled) async {
    if (settingType == 'disable_background_blur') {
      await _feedSettings.setBackgroundBlur(isEnabled);
      setState(() {});
      return;
    }

    if (!isEnabled && !_feedSettings.canDisableFeed(settingType)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot disable this feed')));
      return;
    }

    await _feedSettings.toggleFeed(settingType, isEnabled);

    _onFeedSettingsChanged();
  }
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}
