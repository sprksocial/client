import 'package:flutter/material.dart';

class FeedSettingsHeader extends StatelessWidget {
  final VoidCallback onClose;

  const FeedSettingsHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.close, color: textColor), onPressed: onClose),
          Text('Feed Settings', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 48), // For balance
        ],
      ),
    );
  }
}
