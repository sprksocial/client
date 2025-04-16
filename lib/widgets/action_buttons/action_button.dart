import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isAnimating;
  final double scale;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.isAnimating = false,
    this.scale = 1.0,
  });

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
                  child: Center(child: Transform.scale(scale: scale, child: Icon(icon, color: color ?? Colors.white, size: 30))),
                ),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            shadows: <Shadow>[
              Shadow(offset: Offset(0, 0), blurRadius: 20.0, color: Color(0xFF000000)),
              Shadow(offset: Offset(1, 1), blurRadius: 8.0, color: Colors.black87),
            ],
          ),
        ),
      ],
    );
  }
}
