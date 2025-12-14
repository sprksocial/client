import 'package:flutter/material.dart';

class OptionsPanel {
  static void show({
    required BuildContext context,
    required VoidCallback onReport,
    VoidCallback? onDelete,
    bool isProfile = false,
  }) {
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
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: Text(
                  isProfile ? 'Report Profile' : 'Report',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onReport();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text('Close', style: TextStyle(color: textColor)),
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
