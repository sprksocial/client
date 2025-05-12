import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class FeedSettingItem extends StatelessWidget {
  final String feedName;
  final String? description;
  final bool isEnabled;
  final ValueChanged<bool> onToggleChanged;

  const FeedSettingItem({
    super.key,
    required this.feedName,
    this.description,
    required this.isEnabled,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = colorScheme.surfaceContainerLow;
    final textColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: itemColor, 
            borderRadius: BorderRadius.circular(12)
          ),
          child: ListTile(
            title: Text(
              feedName, 
              style: TextStyle(color: textColor, fontSize: 16)
            ),
            subtitle: description != null
                ? Text(
                    description!, 
                    style: TextStyle(color: textColor.withAlpha(179), fontSize: 12)
                  )
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