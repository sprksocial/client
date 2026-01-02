import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/l10n/app_localizations.dart';

class OptionsPanel {
  static void show({
    required BuildContext context,
    required VoidCallback onReport,
    VoidCallback? onDelete,
    VoidCallback? onBlock,
    bool isBlocked = false,
    bool isProfile = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final menuBackgroundColor = isDark ? theme.colorScheme.surface : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: menuBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(l10n.optionsPanelDelete, style: const TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete();
                  },
                ),
              if (onBlock != null)
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: Text(
                    isBlocked ? l10n.optionsPanelUnblock : l10n.optionsPanelBlock,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onBlock();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: Text(
                  isProfile ? l10n.optionsPanelReportProfile : l10n.optionsPanelReport,
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onReport();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(l10n.optionsPanelClose, style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
