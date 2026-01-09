import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'grid', type: AppIcons)
Widget buildAppIconsGridUseCase(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'icon_size',
    initialValue: 28,
    min: 12,
    max: 64,
    divisions: 52,
  );
  final color = context.knobs.colorOrNull(label: 'tint_color');
  final icons = <Widget>[
    AppIcons.add(size: size, color: color),
    AppIcons.plus(size: size, color: color),
    AppIcons.search(size: size, color: color),
    AppIcons.comment(size: size, color: color),
    AppIcons.like(size: size, color: color),
    AppIcons.messagesFilled(size: size, color: color),
    AppIcons.bookmarkOutline(size: size, color: color),
    AppIcons.bookmarkFilled(size: size, color: color),
    AppIcons.camera(size: size, color: color),
    AppIcons.arrowRight(size: size, color: color),
    AppIcons.pin(size: size, color: color),
    AppIcons.music(size: size, color: color),
    AppIcons.folderMini(size: size, color: color),
    AppIcons.play(size: size, color: color),
    AppIcons.micro(size: size, color: color),
    AppIcons.tag(size: size, color: color),
    AppIcons.hashtag(size: size, color: color),
    AppIcons.cancel(size: size, color: color),
  ];
  return Center(child: Wrap(spacing: 20, runSpacing: 20, children: icons));
}
