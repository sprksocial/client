import 'package:flutter/material.dart';

enum CameraMode { photo, video }

class ModeSelector extends StatelessWidget {
  final CameraMode selectedMode;
  final Function(CameraMode) onModeSelected;

  const ModeSelector({super.key, required this.selectedMode, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black.withAlpha(100), borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton('Photo', selectedMode == CameraMode.photo, () => onModeSelected(CameraMode.photo)),
          _buildModeButton('Video', selectedMode == CameraMode.video, () => onModeSelected(CameraMode.video)),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
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
