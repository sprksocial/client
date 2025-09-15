import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class ActionButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;

  const ActionButton({
    required this.icon,
    required this.label,
    super.key,
    this.onPressed,
    this.isActive = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = _isPressed ? 40.5 : 45.0;
    final blurAmount = _isPressed ? 2.25 : 2.5;
    final opacity = _isPressed ? 0.6 : 1.0;
    final totalHeight = _isPressed ? 54.5 : 59.0;
    const double iconSize = 34;
    final sizedIcon = SizedBox(
      width: iconSize,
      height: iconSize,
      child: widget.icon,
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: 45, // Base width is constant
        height: totalHeight,
        child: Opacity(
          opacity: opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                  child: Container(
                    width: containerSize,
                    height: containerSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: sizedIcon),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(widget.label, textAlign: TextAlign.center, style: AppTypography.textSmallMedium),
            ],
          ),
        ),
      ),
    );
  }
}
