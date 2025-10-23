import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/toggle.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'interactive', type: Toggle)
Widget buildToggleInteractiveUseCase(BuildContext context) {
  final initialValue = context.knobs.boolean(
    label: 'initial_value',
    initialValue: true,
  );
  return _ToggleDemo(initialValue: initialValue);
}

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo({required this.initialValue});
  final bool initialValue;
  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  late bool value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Toggle(
        value: value,
        onChanged: (v) {
          setState(() => value = v);
          print('Toggle changed: $v');
        },
      ),
    );
  }
}
