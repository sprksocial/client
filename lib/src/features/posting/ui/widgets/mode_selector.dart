import 'package:flutter/material.dart';

class ModeSelector extends StatelessWidget {
  final bool isVideoMode;
  final Function(bool) onModeSelected;

  const ModeSelector({super.key, required this.isVideoMode, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black.withAlpha(100), borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModeButton(label: 'Photo', isSelected: !isVideoMode, onTap: () => onModeSelected(false)),
          ModeButton(label: 'Video', isSelected: isVideoMode, onTap: () => onModeSelected(true)),
        ],
      ),
    );
  }
}

class ModeButton extends StatelessWidget {
  const ModeButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.pink : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}