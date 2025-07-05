import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.icon,
    required this.label,
    super.key,
    this.onPressed,
    this.color,
    this.isAnimating = false,
    this.scale = 1.0,
    this.showLabel = true,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isAnimating;
  final double scale;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Custom shadow that follows shape of the button
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 30)],
                    ),
                  );
                },
              ),
            ),
            // Button with transparent background
            SizedBox(
              height: 35,
              width: 48,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onPressed,
                  child: Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Icon(icon, color: color ?? Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showLabel)
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              shadows: <Shadow>[
                Shadow(blurRadius: 20),
                Shadow(offset: Offset(1, 1), blurRadius: 8, color: Colors.black87),
              ],
            ),
          ),
      ],
    );
  }
}
