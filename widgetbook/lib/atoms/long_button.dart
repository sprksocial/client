import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'no_ui', type: AppButton)
Widget buildAppButtonCompactNoUIUseCase(BuildContext context) {
  return AppButton(
    label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
    onPressed: () => print('AppButton was pressed.'),
    size: AppButtonSize.compact,
  );
}

@UseCase(name: 'resizable_parent', type: AppButton)
Widget buildAppButtonCompactInAResizableContainerUseCase(BuildContext context) {
  return Center(
    child: Container(
      width: context.knobs.double.slider(
        label: 'Parent Width',
        initialValue: 250,
        min: 100,
        max: 400,
        divisions: 30,
      ),
      height: context.knobs.double.slider(
        label: 'Parent Height',
        initialValue: 80,
        min: 40,
        max: 200,
        divisions: 16,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.grey.shade200,
      ),
      child: Center(
        child: AppButton(
          label: context.knobs.string(
            label: 'Label',
            initialValue: 'Resizable Button',
          ),
          onPressed: () => print('Button in resizable container pressed.'),
          size: AppButtonSize.compact,
        ),
      ),
    ),
  );
}
