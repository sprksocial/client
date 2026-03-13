import 'dart:ui'; // Required for ImageFilter

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';

class LiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const LiveButton({required this.child, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      top: 20,
      child: InteractivePressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.5),
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
