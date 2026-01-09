import 'package:flutter/material.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';

class LabelSettingTile extends StatelessWidget {
  const LabelSettingTile({
    required this.label,
    required this.preference,
    required this.onPreferenceUpdate,
    this.labelName,
    this.labelDescription,
    this.showSeverity = true,
    super.key,
  });
  final String label;
  final LabelPreference preference;
  final Function(
    String label, {
    Setting? setting,
    Blurs? blurs,
    Severity? severity,
  })
  onPreferenceUpdate;
  final String? labelName;
  final String? labelDescription;
  final bool showSeverity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and description
            Text(
              labelName ?? label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (labelDescription != null) ...[
              const SizedBox(height: 4),
              Text(
                labelDescription!,
                style: TextStyle(
                  color: colorScheme.onSurface.withAlpha(200),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: Setting.values.map((setting) {
                final isSelected = preference.setting == setting;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () =>
                          onPreferenceUpdate(label, setting: setting),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? colorScheme.primary
                            : colorScheme.surface,
                        foregroundColor: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        elevation: isSelected ? 2 : 0,
                        side: BorderSide(
                          color: colorScheme.outline,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        setting.value.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Severity Settings (only show if showSeverity is true)
            if (showSeverity) ...[
              const SizedBox(height: 16),
              Text(
                'Severity Level',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: Severity.values.map((sev) {
                  final isSelected = preference.severity == sev;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () =>
                            onPreferenceUpdate(label, severity: sev),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? colorScheme.tertiary
                              : colorScheme.surface,
                          foregroundColor: isSelected
                              ? colorScheme.onTertiary
                              : colorScheme.onSurface,
                          elevation: isSelected ? 2 : 0,
                          side: BorderSide(
                            color: colorScheme.outline,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          sev.value.toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
