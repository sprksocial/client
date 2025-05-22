import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class SpeedIndicator extends StatelessWidget {
  final bool isVisible;

  const SpeedIndicator({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.black.withAlpha(179), borderRadius: BorderRadius.circular(16)),
      child: const Text('2x', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
