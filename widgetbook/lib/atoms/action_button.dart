import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/action_button.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:widgetbook_workspace/widgetbook_usecases_templates.dart';

final _iconOptions = <String, Widget>{
  'add': AppIcons.add(),
  'camera': AppIcons.camera(),
  'comment': AppIcons.comment(),
  'like': AppIcons.like(),
  'share': AppIcons.share(),
  'bookmarkOutline': AppIcons.bookmarkOutline(),
  'more': AppIcons.more(),
  'send': AppIcons.send(),
  'search': AppIcons.search(),
  'homeFilled': AppIcons.homeFilled(),
};

@UseCase(name: 'gradient', type: ActionButton)
Widget buildActionButtonInteractiveUseCase(BuildContext context) {
  return gradientBackground(
    context: context,
    startColor: context.knobs.color(
      label: 'startColor',
      initialValue: Colors.blue,
    ),
    endColor: context.knobs.color(
      label: 'endColor',
      initialValue: Colors.purple,
    ),
    child: ActionButton(
      icon: context.knobs.object.dropdown<Widget>(
        label: 'Icon',
        initialOption: _iconOptions['like']!,
        options: _iconOptions.values.toList(),
        labelBuilder: (value) {
          return _iconOptions.entries
              .firstWhere((entry) => entry.value == value)
              .key;
        },
      ),
      label: context.knobs.string(label: 'label', initialValue: '800'),
      isActive: context.knobs.boolean(label: 'isActive', initialValue: false),
      onPressed: () => print('Bookmark pressed'),
    ),
  );
}
