import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/default_profile_avatar.dart';
import 'package:spark/src/core/design_system/components/atoms/user_avatar.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'fallback', type: DefaultProfileAvatar)
Widget buildDefaultProfileAvatarUseCase(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'size',
    initialValue: 48,
    min: 24,
    max: 120,
    divisions: 24,
  );

  return Center(child: DefaultProfileAvatar(size: size));
}

@UseCase(name: 'states', type: UserAvatar)
Widget buildUserAvatarStatesUseCase(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'size',
    initialValue: 48,
    min: 24,
    max: 120,
    divisions: 24,
  );

  return Center(
    child: Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        UserAvatar(size: size, username: 'spark'),
        UserAvatar(
          size: size,
          username: 'spark',
          borderWidth: 2,
          borderColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    ),
  );
}
