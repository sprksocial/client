import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/storage/storage_constants.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_settings_sheet.dart';

class FeedSettingsHandler {
  final BuildContext context;
  final WidgetRef ref;
  
  FeedSettingsHandler(this.context, this.ref);

  void showFeedSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for full height sheet
      backgroundColor: Colors.transparent, // Let the sheet handle its own background
      builder: (context) => FeedSettingsSheet(
        onToggleChanged: _handleSettingToggle,
      ),
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