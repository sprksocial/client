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
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      spacing: 20,
      runSpacing: 24,
      children: [
        for (final icon in AppIconData.values)
          SizedBox(
            width: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(icon, size: size, color: color),
                const SizedBox(height: 8),
                Text(
                  icon.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
