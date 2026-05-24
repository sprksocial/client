import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class InteractivePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final double pressedScale;
  final Duration duration;
  final Color overlayColor;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final MouseCursor? mouseCursor;

  const InteractivePressable({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.focusNode,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 120),
    this.overlayColor = const Color(0x42000000),
    this.borderRadius,
    this.semanticLabel,
    this.mouseCursor,
  });

  @override
  State<InteractivePressable> createState() => _InteractivePressableState();
}

class _InteractivePressableState extends State<InteractivePressable> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  void _handleTapDown(TapDownDetails _) => _setPressed(true);
  void _handleTapUp(TapUpDetails _) => _setPressed(false);
  void _handleTapCancel() => _setPressed(false);

  void _handleKeyboardActivate() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isTapEnabled = widget.onTap != null;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: _isEnabled,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: FocusableActionDetector(
        enabled: _isEnabled,
        focusNode: widget.focusNode,
        mouseCursor:
            widget.mouseCursor ??
            (_isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (isTapEnabled) {
                _handleKeyboardActivate();
              }
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: _isEnabled ? _handleTapDown : null,
          onTapUp: _isEnabled ? _handleTapUp : null,
          onTapCancel: _isEnabled ? _handleTapCancel : null,
          child: AnimatedScale(
            scale: _isEnabled && _isPressed ? widget.pressedScale : 1.0,
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
                      color: _isEnabled && _isPressed
                          ? widget.overlayColor
                          : const Color(0x00000000),
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
