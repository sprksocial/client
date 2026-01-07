import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/avatar_stack.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

const _demoImageBase = 'https://picsum.photos/seed';

List<AvatarData> _generateAvatars(int count) {
  return List.generate(
    count,
    (index) => AvatarData(
      imageUrl: '$_demoImageBase/user$index/200/200',
      username: 'user$index',
    ),
  );
}

@UseCase(name: 'default', type: AvatarStack)
Widget buildAvatarStackDefaultUseCase(BuildContext context) {
  final avatarCount = context.knobs.int.slider(
    label: 'Avatar count',
    initialValue: 5,
    min: 1,
    max: 10,
  );

  return Center(child: AvatarStack(avatars: _generateAvatars(avatarCount)));
}

@UseCase(name: 'customized', type: AvatarStack)
Widget buildAvatarStackCustomizedUseCase(BuildContext context) {
  final avatarCount = context.knobs.int.slider(
    label: 'Avatar count',
    initialValue: 5,
    min: 1,
    max: 10,
  );

  final largeAvatarCount = context.knobs.int.slider(
    label: 'Large avatar count',
    initialValue: 2,
    min: 0,
    max: 5,
  );

  final largeSize = context.knobs.double.slider(
    label: 'Large size',
    initialValue: 36,
    min: 20,
    max: 60,
  );

  final smallSize = context.knobs.double.slider(
    label: 'Small size',
    initialValue: 15,
    min: 12,
    max: 40,
  );

  final largeOverlap = context.knobs.double.slider(
    label: 'Large overlap',
    initialValue: 12,
    min: 0,
    max: 30,
  );

  final smallOverlap = context.knobs.double.slider(
    label: 'Small overlap',
    initialValue: 0,
    min: 0,
    max: 20,
  );

  return Center(
    child: AvatarStack(
      avatars: _generateAvatars(avatarCount),
      largeAvatarCount: largeAvatarCount,
      largeSize: largeSize,
      smallSize: smallSize,
      largeOverlap: largeOverlap,
      smallOverlap: smallOverlap,
    ),
  );
}

@UseCase(name: 'empty', type: AvatarStack)
Widget buildAvatarStackEmptyUseCase(BuildContext context) {
  return const Center(child: AvatarStack(avatars: []));
}

@UseCase(name: 'single avatar', type: AvatarStack)
Widget buildAvatarStackSingleUseCase(BuildContext context) {
  return Center(child: AvatarStack(avatars: _generateAvatars(1)));
}
