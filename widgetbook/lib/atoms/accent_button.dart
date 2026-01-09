import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:spark/src/core/design_system/components/atoms/buttons/accent_button.dart';
import 'package:widgetbook_workspace/widgetbook_usecases_templates.dart';

@UseCase(name: 'on_image_background', type: AccentButton)
Widget buildAccentButtonOnImageBackgroundUseCase(BuildContext context) {
  return imageBackground(
    context: context,
    child: AccentButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
    ),
  );
}

@UseCase(name: 'on_gradient_background', type: AccentButton)
Widget buildAccentButtonOnGradientBackgroundUseCase(BuildContext context) {
  return gradientBackground(
    context: context,
    child: AccentButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
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

@UseCase(name: 'on_solid_color_background', type: AccentButton)
Widget buildAccentButtonOnSolidColorBackgroundUseCase(BuildContext context) {
  return solidColorBackground(
    context: context,
    child: AccentButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
    ),
    color: context.knobs.color(
      label: 'Background Color',
      initialValue: const Color(0xFF1A1A2E),
    ),
  );
}
