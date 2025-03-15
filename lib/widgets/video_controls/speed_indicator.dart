import 'package:flutter/cupertino.dart';

class SpeedIndicator extends StatelessWidget {
  final bool isVisible;
  
  const SpeedIndicator({
    Key? key,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '2x',
        style: TextStyle(
          color: CupertinoColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
} 