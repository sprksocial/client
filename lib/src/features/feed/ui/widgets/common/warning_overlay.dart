import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/upload/data/models/content_warning_style.dart';

class WarningOverlay extends StatelessWidget {
  final ContentWarningStyle style;
  final String? warningMessage;
  final String labelValue;
  final VoidCallback onShowContent;

  const WarningOverlay({
    super.key,
    required this.style,
    required this.labelValue,
    required this.onShowContent,
    this.warningMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: style.borderColor, width: style.borderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: 48, color: style.iconColor),
            const SizedBox(height: 16),
            Text(
              style.headerText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 8),
            Text(
              warningMessage ?? 'This content has been marked as $labelValue',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onShowContent,
              style: ElevatedButton.styleFrom(backgroundColor: style.borderColor, foregroundColor: AppColors.white),
              child: const Text('Show content'),
            ),
          ],
        ),
      ),
    );
  }
}
