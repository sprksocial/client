import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/tab_item.dart';
import 'package:sparksocial/src/core/design_system/tokens/gradients.dart';

class ProfileTabItem extends StatelessWidget {
  const ProfileTabItem({
    required this.icon,
    required this.filledIcon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Widget icon;
  final Widget filledIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppTabItem(
      activeChild: ShaderMask(
        shaderCallback: (bounds) => AppGradients.gradientLinearPrimaryGradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: filledIcon,
      ),
      inactiveChild: icon,
      isSelected: isSelected,
      onTap: onTap,
      indicatorColor: theme.colorScheme.primary,
    );
  }
}
