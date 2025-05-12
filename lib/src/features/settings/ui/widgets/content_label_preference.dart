import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/settings/data/models/label_preference.dart';
import 'package:sparksocial/src/features/settings/providers/labeler_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/utils/string_extensions.dart';

class ContentLabelPreference extends ConsumerWidget {

  final String labelValue;
  final String displayName;
  final String description;
  final String labelDid;

  const ContentLabelPreference({
    super.key,
    required this.labelValue,
    required this.displayName,
    required this.description,
    required this.labelDid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final labelerDetailsAsync = ref.watch(labelerDetailsProvider(labelDid));
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = colorScheme.surfaceContainerLow;
    final textColor = colorScheme.onSurface;
    
    return labelerDetailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
      data: (labeler) {
        // Get the label definition to check if it's adult-only
        final definition = labeler.labelDefinitions[labelValue];
        
        if (definition == null) return const SizedBox();
        
        // Use defaultSetting from the label definition if no user preference is set
        final preference = settingsState.getLabelPreferenceOrDefault(
          labelDid, 
          labelValue, 
          {
            'defaultSetting': definition.defaultSetting,
            'adultOnly': definition.adultOnly,
          }
        );
        final selectedValue = preference.name;
        
        // Get default setting to display in UI
        final defaultSetting = definition.defaultSetting;
        
        final bool isAdultOnly = definition.adultOnly;
        
        // If adult content is hidden, disable adult-only labels
        final hideAdultContent = settingsState.hideAdultContent;
        final bool isDisabled = isAdultOnly && hideAdultContent;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: itemColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isAdultOnly)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.red.withAlpha(51),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Adult',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: textColor.withAlpha(179),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  
                  // Show default setting info
                  Row(
                    children: [
                      Text(
                        'Default: ',
                        style: TextStyle(
                          color: textColor.withAlpha(179),
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: switch (defaultSetting) {
                            'show' => Colors.green.withAlpha(51),
                            'warn' => Colors.orange.withAlpha(51),
                            'hide' => Colors.red.withAlpha(51),
                            _ => Colors.grey.withAlpha(51),
                          },
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          defaultSetting.capitalize(),
                          style: TextStyle(
                            color: switch (defaultSetting) {
                              'show' => Colors.green,
                              'warn' => Colors.orange,
                              'hide' => Colors.red,
                              _ => Colors.grey,
                            },
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // SegmentedButton for content preference
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'show',
                        label: Text('Show'),
                        icon: Icon(Icons.visibility),
                      ),
                      ButtonSegment<String>(
                        value: 'warn',
                        label: Text('Warn'),
                        icon: Icon(Icons.warning),
                      ),
                      ButtonSegment<String>(
                        value: 'hide',
                        label: Text('Hide'),
                        icon: Icon(Icons.visibility_off),
                      ),
                    ],
                    selected: {isDisabled ? 'hide' : selectedValue},
                    onSelectionChanged: isDisabled 
                      ? null  // Disable selection change if adult content is hidden
                      : (selection) async {
                          final newPreference = LabelPreference.values.firstWhere(
                            (pref) => pref.name == selection.first,
                          );
                          
                          await ref.read(settingsProvider.notifier).setLabelPreference(
                            labelDid, 
                            labelValue, 
                            newPreference,
                          );
                        },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: textColor.withAlpha(26),
                      selectedBackgroundColor: AppColors.pink,
                      selectedForegroundColor: AppColors.white,
                      foregroundColor: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
} 