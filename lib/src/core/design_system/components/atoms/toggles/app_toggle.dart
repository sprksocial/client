import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';

/// A controlled on/off input. A null [onChanged] disables interaction.
class AppToggle extends StatefulWidget {
  const AppToggle({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggle() => widget.onChanged?.call(!widget.value);

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onChanged != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion || _focusNode.hasFocus
        ? Duration.zero
        : AppConstants.animationFast;
    final trackColor = widget.value
        ? AppColors.primary600
        : isDark
        ? AppColors.darkGreyButton
        : AppColors.grey200;
    final hasFocus = isEnabled && _focusNode.hasFocus;

    // Own switch semantics while reusing the shared pointer/keyboard behavior.
    return Semantics(
      label: widget.semanticLabel,
      toggled: widget.value,
      enabled: isEnabled,
      focusable: isEnabled,
      focused: hasFocus,
      onTap: isEnabled ? _toggle : null,
      excludeSemantics: true,
      child: InteractivePressable(
        onTap: isEnabled ? _toggle : null,
        focusNode: _focusNode,
        duration: duration,
        pressedScale: reduceMotion ? 1 : 0.97,
        overlayColor: Colors.transparent,
        child: SizedBox(
          width: 56,
          height: AppConstants.buttonHeightLarge,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasFocus ? AppColors.primary600 : Colors.transparent,
                ),
              ),
              child: AnimatedOpacity(
                opacity: isEnabled ? 1 : AppConstants.opacityDisabled / 255,
                duration: duration,
                child: AnimatedContainer(
                  width: 48,
                  height: 28,
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedAlign(
                    alignment: widget.value
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.greyWhite,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(dimension: 20),
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
}
