import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/features/posting/models/content_warning_selection.dart';

const _contentWarningValues = ['sexual', 'nudity', 'porn', 'graphic-media'];

Future<ContentWarningSelection?> showContentWarningDialog(
  BuildContext context,
) {
  var selection = const ContentWarningSelection();
  return showDialog<ContentWarningSelection>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.labelContentWarnings),
          content: SingleChildScrollView(
            child: ContentWarningSelector(
              value: selection,
              onChanged: (value) => setDialogState(() => selection = value),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, selection),
              child: Text(l10n.buttonPost),
            ),
          ],
        );
      },
    ),
  );
}

class ContentWarningSelector extends StatelessWidget {
  const ContentWarningSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ContentWarningSelection value;
  final ValueChanged<ContentWarningSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final strings = {
      for (final value in _contentWarningValues)
        value: builtInLabelDefinitionsByValue[value]!.localizedStrings(l10n)!,
    };

    return Semantics(
      container: true,
      label: l10n.labelContentWarnings,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppShapes.squircleRadius),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.labelContentWarnings,
              style: AppTypography.textMediumBold.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.messageContentWarningsDescription,
              style: AppTypography.textSmallMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.labelAdultContent, style: AppTypography.textSmallBold),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final adult in AdultContentWarning.values)
                  ChoiceChip(
                    key: Key('content-warning-${adult.name}'),
                    label: Text(strings[adult.name]!.name),
                    selected: value.adult == adult,
                    onSelected: (selected) => onChanged(
                      value.copyWith(adult: adult, clearAdult: !selected),
                    ),
                  ),
              ],
            ),
            if (value.adult case final adult?) ...[
              const SizedBox(height: 8),
              Text(
                strings[adult.name]!.description,
                style: AppTypography.textSmallMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilterChip(
              key: const Key('content-warning-graphic-media'),
              label: Text(strings['graphic-media']!.name),
              selected: value.graphicMedia,
              onSelected: (selected) =>
                  onChanged(value.copyWith(graphicMedia: selected)),
            ),
            if (value.graphicMedia) ...[
              const SizedBox(height: 8),
              Text(
                strings['graphic-media']!.description,
                style: AppTypography.textSmallMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
