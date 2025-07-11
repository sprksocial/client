import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class ContentWarningOverlay extends StatelessWidget {
  const ContentWarningOverlay({
    required this.onViewContent,
    required this.warningLabels,
    super.key,
    this.shouldBlur = false,
    this.child,
  });

  final VoidCallback onViewContent;
  final List<String> warningLabels;
  final Widget? child;
  final bool shouldBlur; // content blur

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original content (blurred/hidden)
        if (child != null)
          if (shouldBlur) ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: child) else child!,
        // Warning overlay
        if (shouldBlur)
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.white, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Content Warning',
                      style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This content has been flagged for:\n${warningLabels.join(', ')}',
                      style: const TextStyle(color: AppColors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onViewContent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('View Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
