import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final Duration position;
  final Duration duration;
  
  const TimeDisplay({
    Key? key,
    required this.position,
    required this.duration,
  }) : super(key: key);
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${_formatDuration(position)}/${_formatDuration(duration)}',
        style: const TextStyle(
          color: CupertinoColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
} 