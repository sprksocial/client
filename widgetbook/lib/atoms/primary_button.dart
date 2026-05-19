import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'default', type: AppButton)
Widget buildAppButtonLargeDefaultUseCase(BuildContext context) {
  final isEnabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final hasTrailingIcon = context.knobs.boolean(
    label: 'Trailing icon',
    initialValue: false,
  );

  return Center(
    child: AppButton(
      label: context.knobs.string(label: 'Text', initialValue: 'Continue'),
      minWidth: context.knobs.double.slider(
        label: 'Min width',
        initialValue: 320,
        min: 160,
        max: 420,
        divisions: 26,
      ),
      minHeight: context.knobs.double.slider(
        label: 'Min height',
        initialValue: 60,
        min: 44,
        max: 84,
        divisions: 20,
      ),
      trailing: hasTrailingIcon
          ? AppIcons.arrowRight(size: 20, color: AppColors.greyWhite)
          : null,
      size: AppButtonSize.large,
      onPressed: isEnabled ? () => print('AppButton was pressed.') : null,
    ),
  );
}
