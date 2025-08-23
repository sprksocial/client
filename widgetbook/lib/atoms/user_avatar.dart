import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:sparksocial/src/core/ui/widgets/user_avatar.dart';


@widgetbook.UseCase(
  name: 'Default',
  type: UserAvatar,
)
Widget buildUserAvatarUseCase(BuildContext context) {
  return UserAvatar(
    imageUrl: context.knobs.string(
      label: 'Image URL',
      initialValue: 'https://picsum.photos/200',
    ),
    username: context.knobs.string(
      label: 'Username',
      initialValue: 'John Doe',
    ),
    size: context.knobs.double.slider(
      label: 'Size',
      initialValue: 80,
      min: 40,
      max: 200,
    ),
    borderWidth: context.knobs.double.slider(
      label: 'Border Width',
      initialValue: 2,
      min: 0,
      max: 10,
    ),
    borderColor: context.knobs.color(
      label: 'Border Color',
      initialValue: Colors.blue,
    ),
    backgroundColor: context.knobs.color(
      label: 'Background Color',
      initialValue: Colors.grey,
    ),
    fallbackTextColor: context.knobs.color(
      label: 'Fallback Text Color',
      initialValue: Colors.white,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Without Image',
  type: UserAvatar,
)
Widget buildUserAvatarWithoutImageUseCase(BuildContext context) {
  return const UserAvatar(
    username: 'Jane Doe',
    size: 80,
  );
}

@widgetbook.UseCase(
  name: 'Without Image or Username',
  type: UserAvatar,
)
Widget buildUserAvatarWithoutImageOrUsernameUseCase(BuildContext context) {
  return const UserAvatar(
    size: 80,
  );
}