import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/app_toggle.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/providers/preferences_provider.dart';
import 'package:spark/src/features/settings/ui/widgets/widgets.dart';

@RoutePage()
class ModerationPage extends ConsumerStatefulWidget {
  const ModerationPage({super.key});

  @override
  ConsumerState<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends ConsumerState<ModerationPage> {
  static const _adultLabels = ['porn', 'sexual', 'graphic-media', 'nudity'];
  bool _isSaving = false;

  Future<void> _setAdultContentEnabled(bool enabled) async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);
    final logger = GetIt.instance<LogService>().getLogger('ModerationPage');
    setState(() => _isSaving = true);

    try {
      await ref
          .read(userPreferencesProvider.notifier)
          .setAdultContentEnabled(enabled);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to update adult content preference',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _setGlobalLabelPreference(
    String label,
    ModerationSetting setting,
  ) async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);
    final logger = GetIt.instance<LogService>().getLogger('ModerationPage');
    setState(() => _isSaving = true);

    try {
      await ref
          .read(userPreferencesProvider.notifier)
          .setGlobalLabelPreference(label, setting);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to update global label preference for $label',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider).asData?.value;
    final colorScheme = Theme.of(context).colorScheme;
    final adultContentEnabled = preferences?.adultContentEnabled ?? false;
    final ValueChanged<bool>? onAdultContentChanged =
        preferences == null || _isSaving ? null : _setAdultContentEnabled;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: const AppLeadingButton(),
        title: Text(l10n.pageTitleModeration),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              key: const Key('adult-content-settings-group'),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MergeSemantics(
                    child: ListTile(
                      title: Text(
                        l10n.settingAdultContent,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(l10n.settingAdultContentDescription),
                      enabled: onAdultContentChanged != null,
                      trailing: AppToggle(
                        value: adultContentEnabled,
                        onChanged: onAdultContentChanged,
                      ),
                      onTap: onAdultContentChanged == null
                          ? null
                          : () => onAdultContentChanged(!adultContentEnabled),
                    ),
                  ),
                  if (adultContentEnabled) ...[
                    const Divider(height: 1),
                    for (final label in _adultLabels) ...[
                      Builder(
                        builder: (context) {
                          final definition =
                              builtInLabelDefinitionsByValue[label]!;
                          final strings = definition.localizedStrings(l10n)!;
                          return LabelSettingTile(
                            key: Key('global-label-$label'),
                            label: label,
                            labelName: strings.name,
                            labelDescription: strings.description,
                            controlContext:
                                LabelSettingTileContext.adultContentFilter,
                            setting: _effectiveSetting(
                              preferences!,
                              definition,
                            ),
                            enabled: !_isSaving,
                            onChanged: (setting) =>
                                _setGlobalLabelPreference(label, setting),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                splashColor: Colors.transparent,
                title: Text(
                  l10n.pageTitleLabelers,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const AppIcon(AppIconData.tag),
                onTap: () =>
                    context.router.push(const LabelerManagementRoute()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ModerationSetting _effectiveSetting(
    Preferences preferences,
    ModerationLabelDefinition definition,
  ) {
    ModerationSetting? sourceSetting;
    for (final preference
        in preferences.contentLabelPrefs ?? const <ContentLabelPref>[]) {
      if (preference.label != definition.identifier) continue;
      final setting = switch (preference.visibility.toJson()) {
        'hide' => ModerationSetting.hide,
        'warn' => ModerationSetting.warn,
        _ => ModerationSetting.ignore,
      };
      if (preference.labelerDid == null) return setting;
      if (preference.labelerDid == definition.definedBy) {
        sourceSetting = setting;
      }
    }
    return sourceSetting ?? definition.defaultSetting;
  }
}
