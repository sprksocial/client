import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class RecordingBar extends StatelessWidget {
  final bool isRecording;
  final double progress;
  final String timeText;

  const RecordingBar({
    super.key, 
    required this.isRecording, 
    required this.progress, 
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: LinearProgressIndicator(
              value: isRecording ? progress : 0,
              backgroundColor: AppColors.white.withAlpha(77),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          timeText, 
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 