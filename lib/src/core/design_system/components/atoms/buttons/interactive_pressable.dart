import 'package:flutter/material.dart';

class InteractivePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final double pressedScale;
  final double pressedOpacity;
  final Duration duration;

  const InteractivePressable({
    required this.child, super.key,
    this.onTap,
    this.focusNode,
    this.pressedScale = 0.95,
    this.pressedOpacity = 0.6,
    this.duration = const Duration(milliseconds: 120),
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
        child: AnimatedOpacity(
          opacity: _isPressed ? widget.pressedOpacity : 1.0,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
