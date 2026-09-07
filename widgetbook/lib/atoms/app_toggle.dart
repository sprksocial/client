import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/app_toggle.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Interactive', type: AppToggle)
Widget buildAppToggleUseCase(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final initialValue = context.knobs.boolean(label: 'Initial value');
  final rightToLeft = context.knobs.boolean(label: 'Right to left');
  final reduceMotion = context.knobs.boolean(label: 'Reduce motion');

  return MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: rightToLeft ? TextDirection.rtl : TextDirection.ltr,
      child: _TogglePreview(
        key: ValueKey(initialValue),
        initialValue: initialValue,
        enabled: enabled,
      ),
    ),
  );
}

class _TogglePreview extends StatefulWidget {
  const _TogglePreview({
    required this.initialValue,
    required this.enabled,
    super.key,
  });

  final bool initialValue;
  final bool enabled;

  @override
  State<_TogglePreview> createState() => _TogglePreviewState();
}

class _TogglePreviewState extends State<_TogglePreview> {
  late bool _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppToggle(
        value: _value,
        semanticLabel: 'Toggle preview',
        onChanged: widget.enabled
            ? (value) => setState(() => _value = value)
            : null,
      ),
    );
  }
}
