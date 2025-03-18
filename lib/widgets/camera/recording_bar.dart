import 'package:flutter/material.dart';

class RecordingBar extends StatelessWidget {
  final bool isRecording;
  final double progress; // 0.0 to 1.0
  final String timeText;

  const RecordingBar({super.key, required this.isRecording, required this.progress, required this.timeText});

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: Colors.white.withAlpha(77),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(timeText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
