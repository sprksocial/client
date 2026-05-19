import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/toggle_button.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'states', type: ToggleButton)
Widget buildToggleButtonStatesUseCase(BuildContext context) {
  final isSelected = context.knobs.boolean(
    label: 'is_selected',
    initialValue: false,
  );
  return Center(
    child: ToggleButton(
      isSelected: isSelected,
      onChanged: (value) => print('Toggle changed to $value'),
      unselectedLabel: context.knobs.string(
        label: 'unselected_label',
        initialValue: 'Follow',
      ),
      selectedLabel: context.knobs.string(
        label: 'selected_label',
        initialValue: 'Unfollow',
      ),
    ),
  );
}
