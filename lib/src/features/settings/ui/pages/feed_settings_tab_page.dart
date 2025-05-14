import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/storage/storage_constants.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_settings_list.dart';

@RoutePage()
class FeedSettingsTabPage extends ConsumerWidget {
  final List<FeedSetting> feedSettings;
  final Function(String, bool) onToggleChanged;

  const FeedSettingsTabPage({
    super.key, 
    required this.feedSettings, 
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FeedSettingsList(
      feedSettings: feedSettings,
      onSettingChanged: (index, value) {
        // If this is the feed blur setting, update settings
        final setting = feedSettings[index];
        if (setting.settingType == StorageKeys.feedBlurKey) {
          ref.read(settingsProvider.notifier).setFeedBlur(value);
        }

        // Then call the parent callback
        onToggleChanged(setting.settingType, value);
      },
    );
  }
} 