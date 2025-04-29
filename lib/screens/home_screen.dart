import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

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
      setState(() {});
    }
  }

  Future<void> _initializeScreen() async {
    await _feedSettings.loadPreferences();
    _pageController.addListener(_onPageChanged);

    // Initialize selected tab index and ensure page controller is at the correct position
    final feedOptions = _buildFeedOptions();
    _selectedTabIndex = feedOptions.indexWhere((option) => option.value == _feedSettings.selectedFeedType);
    if (_selectedTabIndex == -1) {
      _selectedTabIndex = 0; // Fallback to first tab if not found
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
    final feedOptions = _buildFeedOptions();
    if (currentPage < feedOptions.length) {
      _selectedTabIndex = currentPage;
      _feedSettings.setSelectedFeedType(feedOptions[currentPage].value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final List<FeedOption> feedOptions = _buildFeedOptions();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [_buildMainContent(), _buildTopBar(topPadding, isDarkMode, feedOptions)]),
    );
  }

  List<FeedOption> _buildFeedOptions() {
    final options = <FeedOption>[];

    if (_feedSettings.followingFeedEnabled) {
      options.add(const FeedOption(label: 'Following', value: 0));
    }

    if (_feedSettings.forYouFeedEnabled) {
      options.add(const FeedOption(label: 'For You', value: 1));
    }

    if (_feedSettings.latestFeedEnabled) {
      options.add(const FeedOption(label: 'Latest', value: 2));
    }

    return options;
  }

  Widget _buildMainContent() {
    final feedOptions = _buildFeedOptions();
    return PageView.builder(
      controller: _pageController,
      itemCount: feedOptions.length,
      onPageChanged: (index) {
        if (index < feedOptions.length) {
          _feedSettings.setSelectedFeedType(feedOptions[index].value);
        }
      },
      itemBuilder: (context, index) {
        final feedType = feedOptions[index].value;
        return ChangeNotifierProvider<FeedSettingsService>.value(value: _feedSettings, child: FeedScreen(feedType: feedType));
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
                            selectedValue: feedOptions[_selectedTabIndex].value,
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
    final feedOptions = _buildFeedOptions();
    final index = feedOptions.indexWhere((option) => option.value == value);
    if (index != -1) {
      setState(() {
        _selectedTabIndex = index;
      });
      await _feedSettings.setSelectedFeedType(value);
      if (_pageController.hasClients) {
        await _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
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
