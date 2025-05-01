import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _feedSettings.addListener(_onFeedSettingsChanged);
  }

  @override
  void dispose() {
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
      setState(() {
        // If the previously selected feed still exists, keep its index.
        // Otherwise, default to the first available feed.
        _selectedTabIndex = (newIndex != -1) ? newIndex : 0;
        // Jump controller to the new index without animation if the page count changed
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_selectedTabIndex);
        }
      });
    }
  }

  Future<void> _initializeScreen() async {
    await _feedSettings.loadPreferences();
    _buildFeedScreens(); // Build screens after loading preferences
    _pageController.addListener(_onPageChanged);

    // Initialize selected tab index and ensure page controller is at the correct position
    _selectedTabIndex = _currentFeedOptions.indexWhere((option) => option.value == _feedSettings.selectedFeedType);
    if (_selectedTabIndex == -1 && _currentFeedOptions.isNotEmpty) {
      _selectedTabIndex = 0; // Fallback to first tab if not found or no options
    }

    // Ensure page controller is at the correct position
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
      setState(() {
        _selectedTabIndex = currentPage;
      });
      _feedSettings.setSelectedFeedType(_currentFeedOptions[currentPage].value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [_buildMainContent(), _buildTopBar(topPadding, isDarkMode, _currentFeedOptions)]),
    );
  }

  void _buildFeedScreens() {
    final options = <FeedOption>[];
    final screens = <Widget>[];

    if (_feedSettings.followingFeedEnabled) {
      options.add(const FeedOption(label: 'Following', value: 0));
      screens.add(
        ChangeNotifierProvider<FeedSettingsService>.value(
          key: const ValueKey('feed_0'),
          value: _feedSettings,
          child: const FeedScreen(feedType: 0),
        ),
      );
    }

    if (_feedSettings.forYouFeedEnabled) {
      options.add(const FeedOption(label: 'For You', value: 1));
      screens.add(
        ChangeNotifierProvider<FeedSettingsService>.value(
          key: const ValueKey('feed_1'),
          value: _feedSettings,
          child: const FeedScreen(feedType: 1),
        ),
      );
    }

    if (_feedSettings.latestFeedEnabled) {
      options.add(const FeedOption(label: 'Latest', value: 2));
      screens.add(
        ChangeNotifierProvider<FeedSettingsService>.value(
          key: const ValueKey('feed_2'),
          value: _feedSettings,
          child: const FeedScreen(feedType: 2),
        ),
      );
    }

    // Update the state variables
    _currentFeedOptions = options;
    _feedScreens = screens;
  }

  Widget _buildMainContent() {
    // Use PageView with the pre-built list of screens
    return PageView(
      controller: _pageController,
      children: _feedScreens,
      onPageChanged: (index) {
        // Directly update state and settings here
        if (index < _currentFeedOptions.length) {
          setState(() {
            _selectedTabIndex = index;
          });
          _feedSettings.setSelectedFeedType(_currentFeedOptions[index].value);
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
                            selectedValue:
                                feedOptions.isNotEmpty
                                    ? feedOptions[_selectedTabIndex].value
                                    : 0, // Ensure selectedValue is valid
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
      // Animate to the selected page
      if (_pageController.hasClients) {
        await _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
      // The onPageChanged listener will handle updating the state and settings
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
    );
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

    if (mounted) {
      setState(() {});

      if (!isEnabled && _feedSettings.getFeedTypeFromSetting(settingType) == _feedSettings.selectedFeedType) {
        _pageController.jumpToPage(0);
      }
    }
  }
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}
