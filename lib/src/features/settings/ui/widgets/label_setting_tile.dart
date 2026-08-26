import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/surfaces/app_surface.dart';
import 'package:spark/src/core/design_system/components/molecules/app_choice_group.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';

enum LabelSettingTileContext { adultContentFilter, label, informLabel }

class LabelSettingTile extends StatelessWidget {
  const LabelSettingTile({
    required this.label,
    required this.setting,
    required this.onChanged,
    required this.controlContext,
    this.labelName,
    this.labelDescription,
    this.disabledMessage,
    this.enabled = true,
    super.key,
  });
  final String label;
  final ModerationSetting setting;
  final ValueChanged<ModerationSetting> onChanged;
  final LabelSettingTileContext controlContext;
  final String? labelName;
  final String? labelDescription;
  final String? disabledMessage;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final (ignoreLabel, warnLabel) = switch (controlContext) {
      LabelSettingTileContext.adultContentFilter => (
        l10n.labelShow,
        l10n.labelWarn,
      ),
      LabelSettingTileContext.label => (l10n.labelOff, l10n.labelWarn),
      LabelSettingTileContext.informLabel => (l10n.labelOff, l10n.labelBadge),
    };
    final actions = <AppChoiceOption<ModerationSetting>>[
      AppChoiceOption(value: ModerationSetting.ignore, label: ignoreLabel),
      AppChoiceOption(value: ModerationSetting.warn, label: warnLabel),
      AppChoiceOption(value: ModerationSetting.hide, label: l10n.labelHide),
    ];

    return AppSurface(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelName ?? label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          if (labelDescription != null) ...[
            Text(
              labelDescription!,
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(200),
                fontSize: 12,
              ),
            ),
          ],
          if (disabledMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              disabledMessage!,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          AppChoiceGroup<ModerationSetting>(
            value: setting,
            options: actions,
            enabled: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
