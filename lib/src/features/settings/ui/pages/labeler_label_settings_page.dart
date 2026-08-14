import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/design_system/components/atoms/user_avatar.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';
import 'package:spark/src/features/settings/ui/widgets/widgets.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

@RoutePage()
class LabelerLabelSettingsPage extends ConsumerStatefulWidget {
  final String did;

  const LabelerLabelSettingsPage({required this.did, super.key});

  @override
  ConsumerState<LabelerLabelSettingsPage> createState() =>
      _LabelerLabelSettingsPageState();
}

class _LabelerLabelSettingsPageState
    extends ConsumerState<LabelerLabelSettingsPage> {
  late final SparkLogger _logger;
  final ActorRepository _actorRepository = GetIt.instance<ActorRepository>();
  final SprkRepository _sprkRepository = GetIt.instance<SprkRepository>();

  ProfileViewDetailed? _labelerProfile;
  Map<String, LabelPreference> _labelPreferences = {};
  Map<String, ModerationLabelDefinition> _labelDefinitions = {};
  bool _isLoading = true;
  String? _errorMessage;

  String get _defaultModServiceDid {
    final modDid = _sprkRepository.modDid;
    return modDid.split('#').first;
  }

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger(
      'LabelerLabelSettingsPage',
    );
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

      final service = await _sprkRepository.labeler.getServicesDetailed([
        widget.did,
      ]);
      final policiesJson = service.policies.toJson();
      final labelValuesJson = policiesJson['labelValues'] as List<dynamic>?;
      if (labelValuesJson == null || labelValuesJson.isEmpty) {
        throw Exception('No label values found for labeler');
      }

      final labelValues = labelValuesJson.cast<String>();

      final definitions = ModerationLabelDefinitions.fromLabelers({
        widget.did:
            service.policies.labelValueDefinitions ??
            const <LabelValueDefinition>[],
      });
      final labelDefinitionMap = <String, ModerationLabelDefinition>{
        for (final labelValue in labelValues)
          labelValue:
              ?definitions.bySource[widget.did]?[labelValue] ??
              definitions.global[labelValue],
      };

      // Get existing preferences for this labeler
      final settings = ref.read(settingsProvider.notifier);
      final existingSettings = await settings.getLabelSettingsForLabeler(
        widget.did,
      );
      final globalSettings = <String, Setting>{
        for (final preference
            in (await ref.read(
                  userPreferencesProvider.future,
                )).contentLabelPrefs ??
                const <ContentLabelPref>[])
          if (preference.labelerDid == null)
            preference.label: _visibilityToSetting(
              preference.visibility.toJson(),
            ),
      };
      final preferences = <String, LabelPreference>{};

      // Create preferences for all label values
      for (final labelValue in labelValues) {
        final definition = labelDefinitionMap[labelValue];
        final defaultSetting = definition == null
            ? _visibilityToSetting(_getDefaultVisibilityForLabel(labelValue))
            : Setting.fromValue(definition.defaultSetting.name);
        final savedSetting = globalAdultContentLabelValues.contains(labelValue)
            ? globalSettings[labelValue] ??
                  existingSettings[labelValue] ??
                  defaultSetting
            : existingSettings[labelValue] ?? defaultSetting;
        preferences[labelValue] = LabelPreference(
          value: labelValue,
          blurs: definition == null
              ? _visibilityToBlurs(_getDefaultVisibilityForLabel(labelValue))
              : Blurs.fromValue(definition.blurs.name),
          severity: definition == null
              ? _visibilityToSeverity(_getDefaultVisibilityForLabel(labelValue))
              : Severity.fromValue(definition.severity.name),
          defaultSetting: defaultSetting,
          setting: savedSetting,
          adultOnly: definition?.adultOnly ?? false,
        );
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

  Future<void> _updateLabelPreference(String label, {Setting? setting}) async {
    try {
      final currentPref = _labelPreferences[label];
      if (currentPref != null) {
        final newSetting = setting ?? currentPref.setting;

        final settings = ref.read(settingsProvider.notifier);
        await settings.setLabelPreferenceForLabeler(
          widget.did,
          label,
          newSetting,
        );

        setState(() {
          _labelPreferences[label] = currentPref.copyWith(setting: newSetting);
        });
      }
    } catch (e) {
      _logger.e('Error updating label preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final adultContentEnabled =
        ref.watch(userPreferencesProvider).asData?.value.adultContentEnabled ??
        false;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
            color: colorScheme.onSurface,
          ),
          title: Text(l10n.pageTitleLabelerSettings),
          centerTitle: true,
          leading: const AppLeadingButton(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
            color: colorScheme.onSurface,
          ),
          title: Text(l10n.pageTitleLabelerSettings),
          centerTitle: true,
          leading: const AppLeadingButton(),
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
                  l10n.errorLoadingLabelerSettings,
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
                  child: Text(l10n.buttonRetry),
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
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          color: colorScheme.onSurface,
        ),
        title: Text(l10n.pageTitleLabelerSettings),
        centerTitle: true,
        leading: const AppLeadingButton(),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLabelerSettings,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Labeler Profile Section
            if (_labelerProfile != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const UserAvatar(size: 48),
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
                    l10n.labelContentLabelSettings,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.messageLabelerConfigDescription,
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
                      Icon(
                        Icons.label_outline,
                        size: 48,
                        color: colorScheme.onSurface.withAlpha(128),
                      ),
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
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(178),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._labelPreferences.entries
                  .where((entry) => !entry.key.startsWith('!'))
                  .map((entry) {
                    final definition = _labelDefinitions[entry.key];
                    final configuredGlobally = globalAdultContentLabelValues
                        .contains(entry.key);
                    final strings = definition?.localizedStrings(
                      l10n,
                      preferredLocales: [
                        Localizations.localeOf(context).toLanguageTag(),
                      ],
                    );

                    return LabelSettingTile(
                      label: entry.key,
                      controlContext: entry.value.severity == Severity.inform
                          ? LabelSettingTileContext.informLabel
                          : LabelSettingTileContext.label,
                      setting: ModerationSetting.values.byName(
                        entry.value.setting.name,
                      ),
                      onChanged: (setting) => _updateLabelPreference(
                        entry.key,
                        setting: Setting.values.byName(setting.name),
                      ),
                      labelName: strings?.name,
                      labelDescription: strings?.description,
                      disabledMessage: configuredGlobally
                          ? l10n.moderationConfiguredGlobally
                          : null,
                      enabled:
                          !configuredGlobally &&
                          (!entry.value.adultOnly || adultContentEnabled),
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
                  UserAvatar(
                    imageUrl: profile.avatar?.toString() ?? '',
                    size: 36,
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
                                  message:
                                      'Default mod service labeler '
                                      '(cannot be removed)',
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
