import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class RecordingTimer extends StatelessWidget {
  const RecordingTimer({
    required this.duration,
    required this.maxDuration,
    super.key,
  });

  final Duration duration;
  final Duration maxDuration;

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds / maxDuration.inMilliseconds;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final formattedTime =
        '${minutes.toString().padLeft(1, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    final isWarning = progress >= 0.9;
    final textColor = isWarning ? AppColors.red500 : AppColors.greyWhite;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning
              ? AppColors.red500.withAlpha(180)
              : Colors.white.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.red500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedTime,
            style: AppTypography.textMediumBold.copyWith(
              color: textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
