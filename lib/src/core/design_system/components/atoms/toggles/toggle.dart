import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/gradients.dart';

class Toggle extends StatelessWidget {
  const Toggle({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  static const double _width = 44.73;
  static const double _height = 22.73;
  static const double _thumbSize = 18.73;
  static const Duration _animationDuration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        width: _width,
        height: _height,
        padding: const EdgeInsets.all(2),
        decoration: value ? _activeTrackDecoration : _inactiveTrackDecoration,
        child: AnimatedAlign(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Thumb(thumbSize: _thumbSize, isActive: value),
        ),
      ),
    );
  }

  static final BoxDecoration _activeTrackDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(100),
    gradient: const LinearGradient(
      transform: GradientRotation(64.15 * pi / 180),
      colors: [Color(0xFFFF97CD), Color(0xFFFF349D)],
    ),
  );

  static final BoxDecoration _inactiveTrackDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(100),
    color: const Color.fromRGBO(255, 255, 255, 0.05),
    border: Border.all(
      color: const Color.fromRGBO(255, 255, 255, 0.15),
    ),
  );
}

class Thumb extends StatelessWidget {
  const Thumb({
    required double thumbSize,
    required this.isActive,
    super.key,
  }) : _thumbSize = thumbSize;

  final double _thumbSize;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _thumbSize,
      height: _thumbSize,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withAlpha(128),
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_thumbSize / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.glassStroke,
            ),
          ),
        ),
      ),
    );
  }
}
