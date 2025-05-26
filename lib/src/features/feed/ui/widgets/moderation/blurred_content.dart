import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class BlurredContent extends StatelessWidget {
  final Widget child;
  final String blurType;

  const BlurredContent({super.key, required this.child, required this.blurType});

  @override
  Widget build(BuildContext context) {
    final bool shouldApplyBlur = blurType != 'none';

    if (shouldApplyBlur) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: AppColors.black.withAlpha(25), child: child),
        ),
      );
    } else {
      return Opacity(opacity: 0.3, child: child);
    }
  }
}
