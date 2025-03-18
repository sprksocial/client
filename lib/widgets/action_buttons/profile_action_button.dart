import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ProfileActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ProfileActionButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          ClipOval(
            child: Container(
              width: 44,
              height: 44,
              color: Colors.grey,
              child: const Center(child: Icon(FluentIcons.person_24_regular, color: Colors.white)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
              child: const Icon(FluentIcons.add_24_filled, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
