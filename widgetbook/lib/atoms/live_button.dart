import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';

import 'package:sparksocial/src/core/design_system/components/atoms/buttons/live_button.dart';

import 'package:widgetbook_workspace/widgetbook_usecases_templates.dart';

// Helper map to provide a selection of icons for the knob.
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

@UseCase(name: 'on_image_background', type: LiveButton)
Widget buildLiveButtonOnImageBackgroundUseCase(BuildContext context) {
  return imageBackground(
    context: context,
    child: LiveButton(
      onTap: () => print('LiveButton tapped!'),
      child: context.knobs.object.dropdown<Widget>(
        label: 'Icon',
        initialOption: _iconOptions['camera']!,
        options: _iconOptions.values.toList(),
        labelBuilder: (value) {
          return _iconOptions.entries
              .firstWhere((entry) => entry.value == value)
              .key;
        },
      ),
    ),
  );
}

@UseCase(name: 'on_gradient_background', type: LiveButton)
Widget buildLiveButtonOnGradientBackgroundUseCase(BuildContext context) {
  return gradientBackground(
    context: context,
    child: LiveButton(
      onTap: () => print('LiveButton tapped!'),
      child: context.knobs.object.dropdown<Widget>(
        label: 'Icon',
        initialOption: _iconOptions['camera']!,
        options: _iconOptions.values.toList(),
        labelBuilder: (value) {
          return _iconOptions.entries
              .firstWhere((entry) => entry.value == value)
              .key;
        },
      ),
    ),
    startColor: context.knobs.color(
      label: 'Start Color',
      initialValue: Colors.deepPurple,
    ),
    endColor: context.knobs.color(
      label: 'End Color',
      initialValue: Colors.pinkAccent,
    ),
  );
}

@UseCase(name: 'on_solid_color_background', type: LiveButton)
Widget buildLiveButtonOnSolidColorBackgroundUseCase(BuildContext context) {
  return solidColorBackground(
    context: context,
    child: LiveButton(
      onTap: () => print('LiveButton tapped!'),
      child: context.knobs.object.dropdown<Widget>(
        label: 'Icon',
        initialOption: _iconOptions['camera']!,
        options: _iconOptions.values.toList(),
        labelBuilder: (value) {
          return _iconOptions.entries
              .firstWhere((entry) => entry.value == value)
              .key;
        },
      ),
    ),
    color: context.knobs.color(
      label: 'Background Color',
      initialValue: const Color(0xFF1A1A2E),
    ),
  );
}
