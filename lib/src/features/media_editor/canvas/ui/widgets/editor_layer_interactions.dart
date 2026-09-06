import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

/// Supplies the editor's layer controls using Spark glyphs.
LayerInteractionWidgets buildEditorLayerInteractions() {
  return LayerInteractionWidgets(
    editButton: (stream, onTap, rotation) => ReactiveWidget(
      stream: stream,
      builder: (context) => Positioned(
        top: 0,
        right: 0,
        child: _LayerButton(
          icon: AppIconData.edit,
          label: AppLocalizations.of(context).buttonEdit,
          rotation: rotation,
          onTap: onTap,
        ),
      ),
    ),
    removeButton: (stream, onTap, rotation) => ReactiveWidget(
      stream: stream,
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: _LayerButton(
          icon: AppIconData.cancel,
          label: AppLocalizations.of(context).buttonRemove,
          rotation: rotation,
          onTap: onTap,
        ),
      ),
    ),
    rotateScaleButton: (stream, onDown, onUp, rotation) => ReactiveWidget(
      stream: stream,
      builder: (context) => Positioned(
        bottom: 0,
        right: 0,
        child: _LayerButton(
          icon: AppIconData.rotate,
          label: AppLocalizations.of(context).tooltipRotateScale,
          rotation: rotation,
          onPointerDown: onDown,
          onPointerUp: onUp,
        ),
      ),
    ),
  );
}

class _LayerButton extends StatefulWidget {
  const _LayerButton({
    required this.icon,
    required this.label,
    required this.rotation,
    this.onTap,
    this.onPointerDown,
    this.onPointerUp,
  });

  final AppIconData icon;
  final String label;
  final double rotation;
  final VoidCallback? onTap;
  final PointerDownEventListener? onPointerDown;
  final PointerUpEventListener? onPointerUp;

  @override
  State<_LayerButton> createState() => _LayerButtonState();
}

class _LayerButtonState extends State<_LayerButton> {
  final _tooltipKey = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: widget.rotation,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      opaque: false,
      onEnter: (_) => _tooltipKey.currentState?.ensureTooltipVisible(),
      onExit: (_) => Tooltip.dismissAllToolTips(),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: widget.onPointerDown,
        onPointerUp: widget.onPointerUp,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap,
          // Let the editor's canvas also receive layer-transform gestures.
          child: IgnorePointer(
            child: Tooltip(
              key: _tooltipKey,
              message: widget.label,
              triggerMode: TooltipTriggerMode.manual,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.greyWhite,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: AppIcon(
                    widget.icon,
                    size: 20,
                    color: AppColors.greyBlack,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
