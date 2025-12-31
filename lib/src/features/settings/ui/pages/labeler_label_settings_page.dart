import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/widgets.dart';

@RoutePage()
class LabelerLabelSettingsPage extends ConsumerStatefulWidget {
  final String did;

  const LabelerLabelSettingsPage({
    required this.did,
    super.key,
  });

  @override
  ConsumerState<LabelerLabelSettingsPage> createState() => _LabelerLabelSettingsPageState();
}

class _LabelerLabelSettingsPageState extends ConsumerState<LabelerLabelSettingsPage> {
  late final SparkLogger _logger;
  final ActorRepository _actorRepository = GetIt.instance<ActorRepository>();
  final SprkRepository _sprkRepository = GetIt.instance<SprkRepository>();

  ProfileViewDetailed? _labelerProfile;
  Map<String, LabelPreference> _labelPreferences = {};
  Map<String, Map<String, dynamic>> _labelDefinitions = {};
  bool _isLoading = true;
  String? _errorMessage;

  String get _defaultModServiceDid {
    final modDid = _sprkRepository.modDid;
    return modDid.split('#').first;
  }

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('LabelerLabelSettingsPage');
    _loadLabelerSettings();
  }

  Future<void> _loadLabelerSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch labeler profile
      try {
        final profiles = await _actorRepository.getProfiles([widget.did]);
        if (profiles.isNotEmpty) {
          setState(() {
            _labelerProfile = profiles.firstWhere(
              (p) => p.did == widget.did,
              orElse: () => profiles.first,
            );
          });
        }
      } catch (e) {
        _logger.w('Could not fetch labeler profile: $e');
      }

      // Fetch labeler policies
      final rawResponse = await _sprkRepository.executeWithRetry(() async {
        if (!_sprkRepository.authRepository.isAuthenticated) {
          throw Exception('Not authenticated');
        }
        final atproto = _sprkRepository.authRepository.atproto;
        if (atproto == null) {
          throw Exception('AtProto not initialized');
        }
        final result = await atproto.get(
          NSID.parse('so.sprk.labeler.getServices'),
          parameters: {
            'dids': [widget.did],
            'detailed': true,
          },
          headers: {'atproto-proxy': _sprkRepository.sprkDid},
          to: (jsonMap) => jsonMap,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
        );
        if (result.status != HttpStatus.ok) {
          throw Exception('Failed to retrieve labeler services');
        }
        return result.data as Map<String, dynamic>;
      });

      final viewsJson = rawResponse['views'] as List<dynamic>?;
      if (viewsJson == null || viewsJson.isEmpty) {
        throw Exception('No labeler views returned');
      }

      final viewJson = viewsJson.first as Map<String, dynamic>;
      final policiesJson = viewJson['policies'] as Map<String, dynamic>?;

      if (policiesJson == null) {
        throw Exception('No policies found for labeler');
      }

      final labelValuesJson = policiesJson['labelValues'] as List<dynamic>?;
      if (labelValuesJson == null || labelValuesJson.isEmpty) {
        throw Exception('No label values found for labeler');
      }

      final labelValues = labelValuesJson.map((v) => v as String).toList();

      // Extract labelValueDefinitions
      final labelValueDefinitionsJson = policiesJson['labelValueDefinitions'] as List<dynamic>?;
      final labelDefinitionMap = <String, Map<String, dynamic>>{};
      if (labelValueDefinitionsJson != null) {
        for (final defJson in labelValueDefinitionsJson) {
          final def = defJson as Map<String, dynamic>;
          final identifier = def['identifier'] as String?;
          if (identifier != null) {
            labelDefinitionMap[identifier] = def;
          }
        }
      }

      // Get existing preferences for this labeler
      final settings = ref.read(settingsProvider.notifier);
      final existingPrefs = await settings.getLabelPreferencesForLabeler(widget.did);
      final preferences = <String, LabelPreference>{};

      // Create preferences for all label values
      for (final labelValue in labelValues) {
        if (existingPrefs.containsKey(labelValue)) {
          preferences[labelValue] = existingPrefs[labelValue]!;
        } else {
          // Create default preference
          String defaultVisibility;
          final definition = labelDefinitionMap[labelValue];
          if (definition != null) {
            defaultVisibility = definition['defaultSetting'] as String? ?? 'warn';
          } else {
            defaultVisibility = _getDefaultVisibilityForLabel(labelValue);
          }

          final defaultPref = LabelPreference(
            value: labelValue,
            blurs: _visibilityToBlurs(defaultVisibility),
            severity: _visibilityToSeverity(defaultVisibility),
            defaultSetting: _visibilityToSetting(defaultVisibility),
            setting: _visibilityToSetting(defaultVisibility),
            adultOnly: _isAdultOnlyLabel(labelValue),
          );
          preferences[labelValue] = defaultPref;
        }
      }

      setState(() {
        _labelPreferences = preferences;
        _labelDefinitions = labelDefinitionMap;
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Error loading labeler settings: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getDefaultVisibilityForLabel(String labelValue) {
    switch (labelValue) {
      case '!hide':
      case 'dmca-violation':
        return 'hide';
      case '!no-promote':
        return 'hide';
      case '!warn':
      case 'doxxing':
      case 'porn':
      case 'sexual':
      case 'nsfl':
      case 'gore':
        return 'warn';
      case '!no-unauthenticated':
        return 'ignore';
      case 'nudity':
        return 'ignore';
      default:
        return 'warn';
    }
  }

  Setting _visibilityToSetting(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Setting.ignore;
      case 'warn':
        return Setting.warn;
      case 'hide':
        return Setting.hide;
      default:
        return Setting.ignore;
    }
  }

  Blurs _visibilityToBlurs(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Blurs.none;
      case 'warn':
        return Blurs.media;
      case 'hide':
        return Blurs.content;
      default:
        return Blurs.none;
    }
  }

  Severity _visibilityToSeverity(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Severity.none;
      case 'warn':
        return Severity.alert;
      case 'hide':
        return Severity.alert;
      default:
        return Severity.none;
    }
  }

  bool _isAdultOnlyLabel(String label) {
    const adultOnlyLabels = {
      'porn',
      'sexual',
      'nsfl',
    };
    return adultOnlyLabels.contains(label);
  }

  Future<void> _updateLabelPreference(String label, {Setting? setting, Blurs? blurs, Severity? severity}) async {
    try {
      final currentPref = _labelPreferences[label];
      if (currentPref != null) {
        final newSetting = setting ?? currentPref.setting;
        final newBlurs = blurs ?? currentPref.blurs;
        final newSeverity = severity ?? currentPref.severity;

        final settings = ref.read(settingsProvider.notifier);
        await settings.setLabelPreferenceForLabeler(
          widget.did,
          label,
          newBlurs,
          newSeverity,
          currentPref.adultOnly,
          newSetting,
        );

        setState(() {
          _labelPreferences[label] = currentPref.copyWith(
            setting: newSetting,
            blurs: newBlurs,
            severity: newSeverity,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preference saved')),
          );
        }
      }
    } catch (e) {
      _logger.e('Error updating label preference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preference: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Labeler Settings'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Labeler Settings'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Labeler Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: colorScheme.onSurface.withAlpha(178)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadLabelerSettings,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Labeler Settings'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLabelerSettings,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Labeler Profile Section
            if (_labelerProfile != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: _buildProfileCardWithoutBorder(
                      profile: _labelerProfile!,
                      colorScheme: colorScheme,
                      isDefault: widget.did == _defaultModServiceDid,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: colorScheme.onSurface.withAlpha(178),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Labeler',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.did,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withAlpha(178),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Label Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure how this labeler\'s content labels are handled in your feeds.',
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(178),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Label preferences
            if (_labelPreferences.isEmpty)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.label_outline, size: 48, color: colorScheme.onSurface.withAlpha(128)),
                      const SizedBox(height: 8),
                      Text(
                        'No Labels',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This labeler does not provide any content labels.',
                        style: TextStyle(color: colorScheme.onSurface.withAlpha(178)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._labelPreferences.entries.where((entry) => !entry.key.startsWith('!')).map((entry) {
                final definition = _labelDefinitions[entry.key];
                String? labelName;
                String? labelDescription;

                if (definition != null) {
                  final locales = definition['locales'] as List<dynamic>?;
                  if (locales != null && locales.isNotEmpty) {
                    // Use first locale for now (could be enhanced to match user's locale)
                    final firstLocale = locales.first as Map<String, dynamic>;
                    labelName = firstLocale['name'] as String?;
                    labelDescription = firstLocale['description'] as String?;
                  }
                }

                return LabelSettingTile(
                  label: entry.key,
                  preference: entry.value,
                  onPreferenceUpdate: _updateLabelPreference,
                  labelName: labelName,
                  labelDescription: labelDescription,
                  showSeverity: false,
                );
              }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCardWithoutBorder({
    required ProfileViewDetailed profile,
    required ColorScheme colorScheme,
    bool isDefault = false,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: profile.avatar != null
                        ? CachedNetworkImage(
                            imageUrl: profile.avatar!.toString(),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 36,
                              height: 36,
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person,
                                size: 20,
                                color: colorScheme.onSurface.withAlpha(178),
                              ),
                            ),
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: colorScheme.onSurface.withAlpha(178),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.displayName ?? profile.handle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (isDefault)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Tooltip(
                                  message: 'Default mod service labeler (cannot be removed)',
                                  child: Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '@${profile.handle}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(178),
                          ),
                        ),
                        if (profile.description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 3),
                          Text(
                            profile.description!,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withAlpha(178),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
