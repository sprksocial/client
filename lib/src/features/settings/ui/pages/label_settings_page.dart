import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class LabelSettingsPage extends ConsumerStatefulWidget {
  const LabelSettingsPage({super.key});

  @override
  ConsumerState<LabelSettingsPage> createState() => _LabelSettingsPageState();
}

class _LabelSettingsPageState extends ConsumerState<LabelSettingsPage> {
  late final SettingsRepository _settingsRepository;
  late final SparkLogger _logger;
  Map<String, LabelPreference> _labelPreferences = {};
  List<String> _followedLabelers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _settingsRepository = GetIt.instance<SettingsRepository>();
    _logger = GetIt.instance<LogService>().getLogger('LabelSettingsPage');
    _loadLabelSettings();
  }

  Future<void> _loadLabelSettings() async {
    try {
      setState(() => _isLoading = true);

      final followedLabelers = await _settingsRepository.getFollowedLabelers();
      final Map<String, LabelPreference> preferences = {};

      _logger.d('Loading preferences for ${defaultLabels.length} default labels');

      // Load preferences for default labels
      for (final label in defaultLabels) {
        try {
          final pref = await _settingsRepository.getLabelPreference(label);
          preferences[label] = pref;
        } catch (e) {
          _logger.w('Could not load preference for label: $label - Error: $e');
          // Create a default preference for missing labels
          try {
            _logger.d('Creating default preference for missing label: $label');
            final defaultPref = _createDefaultLabelPreference(label);
            await _settingsRepository.setLabelPreference(
              label,
              defaultPref.blurs,
              defaultPref.severity,
              defaultPref.adultOnly,
              defaultPref.setting,
            );
            preferences[label] = defaultPref;
            _logger.d('Created and saved default preference for label: $label');
          } catch (createError) {
            _logger.e('Failed to create default preference for label $label: $createError');
          }
        }
      }

      setState(() {
        _followedLabelers = followedLabelers;
        _labelPreferences = preferences;
        _isLoading = false;
      });

      _logger.d('Loaded ${preferences.length} label preferences successfully');
    } catch (e) {
      _logger.e('Error loading label settings: $e');
      setState(() => _isLoading = false);
    }
  }

  LabelPreference _createDefaultLabelPreference(String label) {
    // Create sensible defaults based on label type
    switch (label) {
      case '!hide':
      case 'dmca-violation':
        return LabelPreference(
          value: label,
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.hide,
          setting: Setting.hide,
          adultOnly: false,
        );
      case '!no-promote':
        return LabelPreference(
          value: label,
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.hide,
          setting: Setting.hide,
          adultOnly: false,
        );
      case '!warn':
      case 'doxxing':
      case 'porn':
      case 'sexual':
      case 'nsfl':
      case 'gore':
        return LabelPreference(
          value: label,
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: label == 'porn' || label == 'sexual' || label == 'nsfl' || label == 'gore',
        );
      case '!no-unauthenticated':
        return LabelPreference(
          value: label,
          blurs: Blurs.none,
          severity: Severity.none,
          defaultSetting: Setting.ignore,
          setting: Setting.ignore,
          adultOnly: false,
        );
      case 'nudity':
        return LabelPreference(
          value: label,
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.ignore,
          setting: Setting.ignore,
          adultOnly: false,
        );
      default:
        return LabelPreference(
          value: label,
          blurs: Blurs.content,
          severity: Severity.inform,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: false,
        );
    }
  }

  Future<void> _setupDefaultPreferences() async {
    _logger.d('Setting up default label preferences manually');
    for (final label in defaultLabels) {
      try {
        final defaultPref = _createDefaultLabelPreference(label);
        await _settingsRepository.setLabelPreference(
          label,
          defaultPref.blurs,
          defaultPref.severity,
          defaultPref.adultOnly,
          defaultPref.setting,
        );
        _logger.d('Set up default preference for label: $label');
      } catch (e) {
        _logger.e('Failed to set up default preference for label $label: $e');
      }
    }
  }

  Future<void> _updateLabelPreference(String label, {Setting? setting, Blurs? blurs, Severity? severity}) async {
    try {
      final currentPref = _labelPreferences[label];
      if (currentPref != null) {
        final newSetting = setting ?? currentPref.setting;
        final newBlurs = blurs ?? currentPref.blurs;
        final newSeverity = severity ?? currentPref.severity;

        await _settingsRepository.setLabelPreference(label, newBlurs, newSeverity, currentPref.adultOnly, newSetting);

        setState(() {
          _labelPreferences[label] = currentPref.copyWith(setting: newSetting, blurs: newBlurs, severity: newSeverity);
        });
      }
    } catch (e) {
      _logger.e('Error updating label preference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update preference: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settingsState = ref.watch(settingsProvider);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadLabelSettings,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Labels',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure how different types of content are handled in your feeds.',
                    style: TextStyle(color: colorScheme.onSurface.withAlpha(178), fontSize: 14),
                  ),
                ],
              ),
            ),

            // Followed Labelers section
            if (_followedLabelers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Active Labelers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _followedLabelers.map((labeler) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.verified, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(labeler, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withAlpha(178))),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Label preferences
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Label Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                  ),
                  if (settingsState.hideAdultContent)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Adult content labels are hidden. Disable "Hide Adult Content" in the Your Feeds tab to show them.',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withAlpha(140), fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),

            // Build label setting tiles (filter out labels starting with !)
            if (_labelPreferences.isEmpty)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber, size: 48, color: colorScheme.error),
                      const SizedBox(height: 8),
                      Text(
                        'No Label Preferences Found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.error),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'There was an issue loading your label preferences. Try refreshing or resetting to defaults.',
                        style: TextStyle(color: colorScheme.onSurface.withAlpha(178)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            // Force setup of default preferences
                            await _setupDefaultPreferences();
                            await _loadLabelSettings();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to setup defaults: $e')));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
                        child: Text('Setup Default Preferences', style: TextStyle(color: colorScheme.onPrimary)),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Filter out labels starting with "!" and optionally adult content
              ..._labelPreferences.entries
                  .where((entry) {
                    // Always filter out system labels starting with "!"
                    if (entry.key.startsWith('!')) return false;

                    // If hide adult content is enabled, filter out adult-only labels
                    if (settingsState.hideAdultContent && entry.value.adultOnly) return false;

                    return true;
                  })
                  .map((entry) {
                    return LabelSettingTile(
                      label: entry.key,
                      preference: entry.value,
                      onPreferenceUpdate: _updateLabelPreference,
                    );
                  }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class LabelSettingTile extends StatelessWidget {
  final String label;
  final LabelPreference preference;
  final Function(String label, {Setting? setting, Blurs? blurs, Severity? severity}) onPreferenceUpdate;

  const LabelSettingTile({
    super.key,
    required this.label,
    required this.preference,
    required this.onPreferenceUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
        subtitle: Text(
          'Setting: ${preference.setting.value}${preference.adultOnly ? ' • Adult Only' : ''}',
          style: TextStyle(color: colorScheme.onSurface.withAlpha(178), fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Action',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Row(
                  children: Setting.values.map((setting) {
                    final isSelected = preference.setting == setting;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () => onPreferenceUpdate(label, setting: setting),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
                            foregroundColor: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                            elevation: isSelected ? 2 : 0,
                            side: BorderSide(color: colorScheme.outline, width: 0.5),
                          ),
                          child: Text(setting.value.toUpperCase(), style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Severity Settings
                Text(
                  'Severity Level',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Row(
                  children: Severity.values.map((sev) {
                    final isSelected = preference.severity == sev;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () => onPreferenceUpdate(label, severity: sev),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? colorScheme.tertiary : colorScheme.surface,
                            foregroundColor: isSelected ? colorScheme.onTertiary : colorScheme.onSurface,
                            elevation: isSelected ? 2 : 0,
                            side: BorderSide(color: colorScheme.outline, width: 0.5),
                          ),
                          child: Text(sev.value.toUpperCase(), style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Only show blur settings if setting is 'warn'
                if (preference.setting == Setting.warn) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Blur Level',
                    style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: Blurs.values.where((blur) => blur != Blurs.media).map((blur) {
                      final isSelected = preference.blurs == blur;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => onPreferenceUpdate(label, blurs: blur),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? colorScheme.secondary : colorScheme.surface,
                              foregroundColor: isSelected ? colorScheme.onSecondary : colorScheme.onSurface,
                              elevation: isSelected ? 2 : 0,
                              side: BorderSide(color: colorScheme.outline, width: 0.5),
                            ),
                            child: Text(blur.value.toUpperCase(), style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
