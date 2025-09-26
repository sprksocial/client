import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/organisms/bottom_nav_bar.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'default', type: SparkBottomNavBar)
Widget buildSparkBottomNavBarUseCase(BuildContext context) {
  final initialIndex = context.knobs.int.slider(
    label: 'initialIndex',
    initialValue: 0,
    min: 0,
    max: 4,
    divisions: 4,
  );

  final avatarUrl = context.knobs.string(
    label: 'avatarUrl',
    initialValue:
        'https://picsum.photos/100/100?random=${DateTime.now().second % 10}',
  );

  final showImageBg = context.knobs.boolean(
    label: 'imageBackground',
    initialValue: false,
  );

  Widget background;
  if (showImageBg) {
    background = Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(color: Colors.grey.shade800),
    );
  } else {
    background = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF111214), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  int selected = initialIndex;

  return StatefulBuilder(
    builder: (ctx, setState) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: background),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: SparkBottomNavBar(
                    currentIndex: selected,
                    onTap: (i) => setState(() => selected = i),
                    userAvatar: NetworkImage(avatarUrl),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
