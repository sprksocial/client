import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_avatar_step.dart';

@UseCase(name: 'default', type: OnboardingAvatarStep)
Widget buildOnboardingAvatarStepUseCase(BuildContext context) {
  final hasAvatar = context.knobs.boolean(
    label: 'Has Avatar',
    initialValue: true,
  );
  final hasBskyProfile = context.knobs.boolean(
    label: 'Has Imported Bluesky Profile',
    initialValue: true,
  );

  return OnboardingAvatarStep(
    hasImportedBskyProfile: hasBskyProfile,
    avatarImageProvider: hasAvatar
        ? const NetworkImage('https://placehold.co/300x300')
        : null,
    hasLocalAvatar: context.knobs.boolean(
      label: 'Has Local Avatar',
      initialValue: false,
    ),
    hasInitialAvatar: hasAvatar,
    isAvatarActive: hasAvatar,
    onPickAvatar: () {},
    onRevertAvatar: () {},
    onClearAvatar: () {},
  );
}
