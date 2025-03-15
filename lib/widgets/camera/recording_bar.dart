import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation;

class RecordingBar extends StatelessWidget {
  final bool isRecording;
  final double progress; // 0.0 to 1.0
  final String timeText;

  const RecordingBar({
    super.key,
    required this.isRecording,
    required this.progress,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: LinearProgressIndicator(
              value: isRecording ? progress : 0,
              backgroundColor: CupertinoColors.white.withAlpha(77),
              valueColor: const AlwaysStoppedAnimation<Color>(CupertinoColors.systemPink),
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Time text
        Text(
          timeText,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 