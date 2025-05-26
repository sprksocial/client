import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_settings_list.dart';
import 'package:sparksocial/widgets/feed_settings/feed_settings_sheet.dart';

@RoutePage()
class FeedSettingsTabPage extends ConsumerWidget {
  final List<FeedSetting> feedSettings;
  final Function(String, bool) onToggleChanged;

  const FeedSettingsTabPage({super.key, required this.feedSettings, required this.onToggleChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FeedSettingsList(
      onSettingChanged: (settingType, value) {
        onToggleChanged(settingType, value);
      },
    );
  }
}
