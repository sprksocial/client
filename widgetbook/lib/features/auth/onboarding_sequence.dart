import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:spark/src/features/auth/ui/onboarding/onboarding_sequence.dart';
import 'package:spark/src/features/auth/ui/onboarding/onboarding_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_avatar_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_bio_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_display_name_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_welcome_step.dart';

@UseCase(name: 'full_sequence', type: OnboardingSequence)
Widget buildOnboardingSequenceUseCase(BuildContext context) {
  final initialIndex = context.knobs.int.slider(
    label: 'Initial Step Index',
    initialValue: 0,
    min: 0,
    max: 3,
  );

  return OnboardingSequence(
    initialIndex: initialIndex,
    steps: const [
      OnboardingStep(title: 'Set up your profile', builder: _buildWelcomeStep),
      OnboardingStep(title: 'Add a profile photo', builder: _buildAvatarStep),
      OnboardingStep(
        title: 'Add your display name',
        builder: _buildDisplayNameStep,
      ),
      OnboardingStep(title: 'Add a bio', builder: _buildBioStep),
    ],
    onComplete: () {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Onboarding complete!')));
    },
  );
}

Widget _buildWelcomeStep(BuildContext context) {
  return const OnboardingWelcomeStep();
}

Widget _buildAvatarStep(BuildContext context) {
  return OnboardingAvatarStep(
    hasImportedBskyProfile: false,
    onPickAvatar: () {},
    onRevertAvatar: () {},
    onClearAvatar: () {},
  );
}

Widget _buildDisplayNameStep(BuildContext context) {
  return const OnboardingDisplayNameStep(initialDisplayName: 'Jane Doe');
}

Widget _buildBioStep(BuildContext context) {
  return const OnboardingBioStep(
    initialDescription: 'Building weird internet things.',
  );
}
