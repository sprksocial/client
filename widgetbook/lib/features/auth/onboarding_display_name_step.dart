import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_display_name_step.dart';

@UseCase(name: 'default', type: OnboardingDisplayNameStep)
Widget buildOnboardingDisplayNameStepUseCase(BuildContext context) {
  return OnboardingDisplayNameStep(
    initialDisplayName: context.knobs.string(
      label: 'Display Name',
      initialValue: 'Jane Doe',
    ),
    onUndoDisplayName:
        context.knobs.boolean(label: 'Show Undo', initialValue: true)
        ? () {}
        : null,
  );
}
