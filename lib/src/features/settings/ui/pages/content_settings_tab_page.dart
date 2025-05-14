import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/content_settings_list.dart';

@RoutePage()
class ContentSettingsTabPage extends ConsumerWidget {
  final bool isLoadingLabels;
  final String? labelsError;
  final Function() onRetryLabels;
  final Function(bool) onUpdateAdultContentPreferences;

  const ContentSettingsTabPage({
    super.key,
    required this.isLoadingLabels,
    this.labelsError,
    required this.onRetryLabels,
    required this.onUpdateAdultContentPreferences,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentSettingsList(
      isLoadingLabels: isLoadingLabels,
      labelsError: labelsError,
      onRetryLabels: onRetryLabels,
      onUpdateAdultContentPreferences: onUpdateAdultContentPreferences,
    );
  }
} 