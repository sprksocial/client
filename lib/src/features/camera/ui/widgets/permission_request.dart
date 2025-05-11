import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class CameraPermissionRequest extends StatelessWidget {
  final VoidCallback onRequestPermission;

  const CameraPermissionRequest({
    super.key, 
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FluentIcons.camera_off_24_regular, 
              color: AppColors.white.withAlpha(179), // 70% opacity equivalent 
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera permission required',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.white, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please allow camera access to use this feature',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withAlpha(179), // 70% opacity equivalent
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRequestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
} 