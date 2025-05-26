import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/settings_service.dart';
import '../../services/labeler_manager.dart';
import '../../utils/app_colors.dart';

class FeedSettingsSheet extends StatefulWidget {
  final List<FeedSetting> feedSettings;
  final Function(String, bool) onToggleChanged;

  const FeedSettingsSheet({super.key, required this.feedSettings, required this.onToggleChanged});

  @override
  State<FeedSettingsSheet> createState() => _FeedSettingsSheetState();
}

class _FeedSettingsSheetState extends State<FeedSettingsSheet> with SingleTickerProviderStateMixin {
  late List<FeedSetting> _feedSettings;
  late TabController _tabController;
  Map<String, Map<String, dynamic>> _labelDefinitions = {};
  bool _isLoadingLabels = false;
  String? _labelsError;

  @override
  void initState() {
    super.initState();
    _feedSettings = List.from(widget.feedSettings);
    _tabController = TabController(length: 2, vsync: this);
    _loadLabelDefinitions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load label definitions from the default labeler
  Future<void> _loadLabelDefinitions() async {
    // Use Future.microtask para o primeiro setState para evitar chamar durante o build
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _isLoadingLabels = true;
          _labelsError = null;
        });
      }
    });

    try {
      final labelerManager = Provider.of<LabelerManager>(context, listen: false);
      
      // O LabelerManager agora trata erros internamente com fallbacks
      await labelerManager.loadLabelerData(LabelerManager.defaultLabelerDid);
      
      // Get label definitions from the labeler manager
      final definitions = labelerManager.getLabelDefinitions(LabelerManager.defaultLabelerDid);
      
      // Verificar se o widget ainda está na árvore antes de chamar setState
      if (mounted) {
        setState(() {
          _labelDefinitions = definitions;
          _isLoadingLabels = false;
        });
      }
    } catch (e) {
      // Verificar se o widget ainda está na árvore antes de chamar setState
      if (mounted) {
        setState(() {
          _labelsError = 'Failed to load content labels: $e';
          _isLoadingLabels = false;
        });
      }
    }
  }

  // Update adult content label preferences based on hideAdultContent setting
  Future<void> _updateAdultContentPreferences(bool hideAdultContent) async {
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    
    // For each label definition that has adultOnly: true
    for (final entry in _labelDefinitions.entries) {
      final labelValue = entry.key;
      final definition = entry.value;
      
      // Check if this is an adult-only label
      final bool isAdultOnly = definition['adultOnly'] as bool? ?? false;
      
      if (isAdultOnly) {
        // Set the preference based on the hideAdultContent setting
        final newPreference = hideAdultContent 
          ? LabelPreference.hide 
          : LabelPreference.show;
        
        await settingsService.setLabelPreference(
          LabelerManager.defaultLabelerDid,
          labelValue,
          newPreference
        );
      }
    }
    
    // Force rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : AppColors.background;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;

    // Make sure we have adequate padding for the notch/dynamic island
    final topPadding = MediaQuery.of(context).padding.top + 24.0;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Add extra padding at the top for the notch/camera hole
            SizedBox(height: topPadding),
            _buildHeader(context, textColor),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: textColor,
              unselectedLabelColor: textColor.withAlpha(127),
              tabs: const [
                Tab(text: "Feed"),
                Tab(text: "Content"),
              ],
            ),
            
            // Tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedList(isDark),
                  _buildContentSettings(isDark, textColor),
                ],
              ),
            ),

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.close, color: textColor), onPressed: () => Navigator.pop(context)),
          Text('Feed Settings', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 48), // For balance
        ],
      ),
    );
  }

  Widget _buildFeedList(bool isDark) {
    final itemColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;

    return ListView.builder(
      itemCount: _feedSettings.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final setting = _feedSettings[index];

        // If this is the feed blur setting, get its value from the SettingsService
        if (setting.settingType == 'feed_blur') {
          final settingsService = Provider.of<SettingsService>(context);
          final isBlurEnabled = settingsService.feedBlurEnabled;

          // Update local state if it differs from service
          if (setting.isEnabled != isBlurEnabled) {
            _feedSettings[index] = FeedSetting(
              feedName: setting.feedName,
              description: setting.description,
              settingType: setting.settingType,
              isEnabled: isBlurEnabled,
            );
          }
        }

        return FeedSettingItem(
          feedName: setting.feedName,
          description: setting.description,
          isEnabled: setting.isEnabled,
          itemColor: itemColor,
          textColor: textColor,
          onToggleChanged: (value) {
            // Update local state first
            setState(() {
              _feedSettings[index] = FeedSetting(
                feedName: setting.feedName,
                description: setting.description,
                settingType: setting.settingType,
                isEnabled: value,
              );
            });

            // If this is the feed blur setting, update the SettingsService
            if (setting.settingType == 'feed_blur') {
              final settingsService = Provider.of<SettingsService>(context, listen: false);
              settingsService.setFeedBlur(value);
            }

            // Then call the parent callback
            widget.onToggleChanged(setting.settingType, value);
          },
        );
      },
    );
  }

  Widget _buildContentSettings(bool isDark, Color textColor) {
    final itemColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    
    if (_isLoadingLabels) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_labelsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_labelsError!, style: TextStyle(color: AppColors.red, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadLabelDefinitions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_labelDefinitions.isEmpty) {
      return Center(
        child: Text(
          'No content labels available',
          style: TextStyle(color: textColor),
        ),
      );
    }
    
    // Sort labels: adult content first, then regular content
    List<String> sortedLabels = _labelDefinitions.keys.toList();
    sortedLabels.sort((a, b) {
      bool isAdultA = _labelDefinitions[a]?['adultOnly'] as bool? ?? false;
      bool isAdultB = _labelDefinitions[b]?['adultOnly'] as bool? ?? false;
      
      // Adult labels first (true before false)
      if (isAdultA && !isAdultB) return -1;
      if (!isAdultA && isAdultB) return 1;
      
      // If both are adult or both are not adult, sort alphabetically
      return a.compareTo(b);
    });
    
    return ListView.builder(
      itemCount: _labelDefinitions.length + 1, // +1 for the Adult Content switch
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        // Add the Adult Content switch at the top
        if (index == 0) {
          return Consumer<SettingsService>(
            builder: (context, settingsService, _) {
              final hideAdultContent = settingsService.hideAdultContent;
              
              return FeedSettingItem(
                feedName: 'Hide Adult Content',
                description: 'Hide all posts with adult content labels',
                isEnabled: hideAdultContent,
                itemColor: itemColor,
                textColor: textColor,
                onToggleChanged: (value) async {
                  // Update the setting
                  await settingsService.setHideAdultContent(value);
                  
                  // Update all adult-only label preferences
                  await _updateAdultContentPreferences(value);
                },
              );
            },
          );
        }
        
        // Adjust index for label definitions using our sorted list
        final labelsIndex = index - 1;
        final labelValue = sortedLabels[labelsIndex];
        final definition = _labelDefinitions[labelValue];
        
        // Extract info from the updated label definition format
        String displayName = labelValue;
        String description = '';
        
        if (definition != null) {
          // Check for the new format with locales
          if (definition['locales'] != null) {
            final locales = definition['locales'] as List<dynamic>;
            if (locales.isNotEmpty) {
              // Get the first locale (assumed to be English)
              final enLocale = locales.first;
              displayName = enLocale['name'] as String? ?? definition['displayName'] as String? ?? labelValue;
              description = enLocale['description'] as String? ?? definition['description'] as String? ?? '';
            }
          } else {
            // Fall back to the old format
            displayName = definition['displayName'] as String? ?? labelValue;
            description = definition['description'] as String? ?? '';
          }
        }
        
        return ContentLabelPreference(
          labelValue: labelValue,
          displayName: displayName,
          description: description,
          itemColor: itemColor,
          textColor: textColor,
        );
      },
    );
  }
}

class ContentLabelPreference extends StatefulWidget {
  final String labelValue;
  final String displayName;
  final String description;
  final Color itemColor;
  final Color textColor;

  const ContentLabelPreference({
    super.key,
    required this.labelValue,
    required this.displayName,
    required this.description,
    required this.itemColor,
    required this.textColor,
  });

  @override
  State<ContentLabelPreference> createState() => _ContentLabelPreferenceState();
}

class _ContentLabelPreferenceState extends State<ContentLabelPreference> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, _) {
        // Get the label definition to check if it's adult-only
        final labelerManager = Provider.of<LabelerManager>(context);
        final definitions = labelerManager.getLabelDefinitions(LabelerManager.defaultLabelerDid);
        final definition = definitions[widget.labelValue];
        
        // Use defaultSetting from the label definition if no user preference is set
        final preference = settingsService.getLabelPreferenceOrDefault(
          LabelerManager.defaultLabelerDid, 
          widget.labelValue, 
          definition
        );
        final selectedValue = preference.name;
        
        // Get default setting to display in UI
        String defaultSetting = 'warn'; // Fallback default
        if (definition != null && definition.containsKey('defaultSetting')) {
          defaultSetting = definition['defaultSetting'] as String;
        }
        
        final bool isAdultOnly = definition?['adultOnly'] as bool? ?? false;
        
        // If adult content is hidden, disable adult-only labels
        final hideAdultContent = settingsService.hideAdultContent;
        final bool isDisabled = isAdultOnly && hideAdultContent;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: widget.itemColor,
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
                          widget.displayName,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isAdultOnly)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(51),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Adult',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: widget.textColor.withAlpha(179),
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
                          color: widget.textColor.withAlpha(179),
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getColorForSetting(defaultSetting).withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          defaultSetting.capitalize(),
                          style: TextStyle(
                            color: _getColorForSetting(defaultSetting),
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
                    segments: [
                      ButtonSegment<String>(
                        value: 'show',
                        label: const Text('Show'),
                        icon: const Icon(Icons.visibility),
                      ),
                      ButtonSegment<String>(
                        value: 'warn',
                        label: const Text('Warn'),
                        icon: const Icon(Icons.warning),
                      ),
                      ButtonSegment<String>(
                        value: 'hide',
                        label: const Text('Hide'),
                        icon: const Icon(Icons.visibility_off),
                      ),
                    ],
                    selected: {isDisabled ? 'hide' : selectedValue},
                    onSelectionChanged: isDisabled 
                      ? null  // Disable selection change if adult content is hidden
                      : (selection) async {
                          final newPreference = LabelPreference.values.firstWhere(
                            (pref) => pref.name == selection.first,
                          );
                          
                          await settingsService.setLabelPreference(
                            LabelerManager.defaultLabelerDid, 
                            widget.labelValue, 
                            newPreference,
                          );
                          
                          // Force rebuild to reflect the new selection
                          setState(() {});
                        },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: widget.textColor.withAlpha(26),
                      selectedBackgroundColor: AppColors.pink,
                      selectedForegroundColor: Colors.white,
                      foregroundColor: widget.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Helper to get color based on setting
  Color _getColorForSetting(String setting) {
    switch (setting) {
      case 'show':
        return Colors.green;
      case 'warn':
        return Colors.orange;
      case 'hide':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class FeedSetting {
  final String feedName;
  final String settingType;
  final String? description;
  final bool isEnabled;

  const FeedSetting({required this.feedName, required this.isEnabled, this.description, required this.settingType});
}

class FeedSettingItem extends StatelessWidget {
  final String feedName;
  final String? description;
  final bool isEnabled;
  final Color itemColor;
  final Color textColor;
  final ValueChanged<bool> onToggleChanged;

  const FeedSettingItem({
    super.key,
    required this.feedName,
    this.description,
    required this.isEnabled,
    required this.itemColor,
    required this.textColor,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(color: itemColor, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(feedName, style: TextStyle(color: textColor, fontSize: 16)),
            subtitle:
                description != null
                    ? Text(description!, style: TextStyle(color: textColor.withAlpha(179), fontSize: 12))
                    : null,
            trailing: Switch(
              value: isEnabled,
              onChanged: onToggleChanged,
              activeColor: AppColors.pink,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade600,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
            onTap: () {
              // Toggle when tapping anywhere on the list tile
              onToggleChanged(!isEnabled);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ),
      ),
    );
  }
}
