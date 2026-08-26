import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

@immutable
class AppChoiceOption<T> {
  const AppChoiceOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
}

class AppChoiceGroup<T> extends StatelessWidget {
  const AppChoiceGroup({
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
    this.enabled = true,
  }) : assert(options.length > 1);

  final T value;
  final List<AppChoiceOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        for (final option in options)
          Expanded(
            child: _ChoiceButton<T>(
              option: option,
              isSelected: option.value == value,
              enabled: enabled && option.enabled,
              onSelected: onChanged,
            ),
          ),
      ],
    );
  }
}

class _ChoiceButton<T> extends StatelessWidget {
  const _ChoiceButton({
    required this.option,
    required this.isSelected,
    required this.enabled,
    required this.onSelected,
  });

  final AppChoiceOption<T> option;
  final bool isSelected;
  final bool enabled;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onTap = enabled ? () => onSelected(option.value) : null;
    final backgroundColor = enabled
        ? isSelected
              ? colorScheme.primary
              : colorScheme.surface
        : colorScheme.onSurface.withValues(alpha: 0.12);
    final foregroundColor = enabled
        ? isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final borderRadius = BorderRadius.circular(12);

    return Semantics(
      label: option.label,
      button: true,
      enabled: enabled,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InteractivePressable(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Material(
            color: backgroundColor,
            elevation: isSelected && enabled ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: BorderSide(color: colorScheme.outline, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Align(
                child: Text(
                  option.label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textExtraSmallBold.copyWith(
                    color: foregroundColor,
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
