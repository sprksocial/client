import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class TimeDisplay extends StatelessWidget {
  final Duration position;
  final Duration duration;

  const TimeDisplay({super.key, required this.position, required this.duration});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: AppColors.black.withAlpha(128), borderRadius: BorderRadius.circular(8)),
      child: Text(
        '${_formatDuration(position)}/${_formatDuration(duration)}',
        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
