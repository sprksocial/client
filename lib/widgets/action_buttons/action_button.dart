import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const ActionButton({super.key, required this.icon, required this.label, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(shape: const CircleBorder(), minimumSize: const Size(48, 48)),
          onPressed: onPressed,
          icon: Icon(icon, color: color ?? Colors.white, size: 30),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
