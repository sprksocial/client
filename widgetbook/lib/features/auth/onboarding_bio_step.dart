import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_bio_step.dart';

@UseCase(name: 'default', type: OnboardingBioStep)
Widget buildOnboardingBioStepUseCase(BuildContext context) {
  return OnboardingBioStep(
    initialDescription: context.knobs.string(
      label: 'Bio',
      initialValue: 'Building weird internet things.',
    ),
    onUndoDescription:
        context.knobs.boolean(label: 'Show Undo', initialValue: true)
        ? () {}
        : null,
  );
}
