import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_welcome_step.dart';

@UseCase(name: 'default', type: OnboardingWelcomeStep)
Widget buildOnboardingWelcomeStepUseCase(BuildContext context) {
  return const OnboardingWelcomeStep();
}
