import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/storage_constants.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

class FeedSettingsHandler {
  final BuildContext context;
  final WidgetRef ref;
  
  FeedSettingsHandler(this.context, this.ref);

  void showFeedSettingsSheet() {
    final settings = ref.read(settingsProvider);
    
    final feedSettings = [
      FeedSetting(
        feedName: 'Following', 
        settingType: StorageKeys.followingFeedEnabledKey, 
        isEnabled: settings.followingFeedEnabled
      ),
      FeedSetting(
        feedName: 'For You', 
        settingType: StorageKeys.forYouFeedEnabledKey, 
        isEnabled: settings.forYouFeedEnabled
      ),
      FeedSetting(
        feedName: 'Latest', 
        settingType: StorageKeys.latestFeedEnabledKey, 
        isEnabled: settings.latestFeedEnabled
      ),
      FeedSetting(
        feedName: 'Disable Background Blur',
        settingType: StorageKeys.feedBlurKey,
        description: 'Turn off the background blur effect on media',
        isEnabled: !settings.feedBlurEnabled,
      ),
    ];

    context.router.push(
      FeedSettingsTabRoute(
        feedSettings: feedSettings,
        onToggleChanged: _handleSettingToggle,
      )
    );
  }
  
  Future<void> _handleSettingToggle(String settingType, bool isEnabled) async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    
    if (settingType == StorageKeys.feedBlurKey) {
      await settingsNotifier.setFeedBlur(!isEnabled); // Inverted logic
      return;
    }
    
    if (!isEnabled && !settingsNotifier.canDisableFeed(settingType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot disable this feed')),
      );
      return;
    }
    
    if (settingType == StorageKeys.followingFeedEnabledKey) {
      await settingsNotifier.setFollowingFeedEnabled(isEnabled);
    } else if (settingType == StorageKeys.forYouFeedEnabledKey) {
      await settingsNotifier.setForYouFeedEnabled(isEnabled);
    } else if (settingType == StorageKeys.latestFeedEnabledKey) {
      await settingsNotifier.setLatestFeedEnabled(isEnabled);
    }
    
    // Update the selected feed if needed
    if (!settingsNotifier.isSelectedFeedEnabled()) {
      await settingsNotifier.selectFirstEnabledFeed();
    }
  }
} 