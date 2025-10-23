import 'package:flutter/material.dart';

class InteractivePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final double pressedScale;
  final Duration duration;
  final Color overlayColor;
  final BorderRadius? borderRadius;

  const InteractivePressable({
    required this.child,
    super.key,
    this.onTap,
    this.focusNode,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 120),
    this.overlayColor = Colors.black26,
    this.borderRadius,
  });

  @override
  State<InteractivePressable> createState() => _InteractivePressableState();
}

class _InteractivePressableState extends State<InteractivePressable> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _isPressed = false);
  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            Positioned.fill(
              child: AnimatedContainer(
                duration: widget.duration,
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: _isPressed ? widget.overlayColor : Colors.transparent,
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
