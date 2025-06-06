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
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.black.withAlpha(180), 
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(100),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '${_formatDuration(position)} / ${_formatDuration(duration)}',
          style: const TextStyle(
            color: AppColors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
