import 'package:flutter/material.dart';

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

    return Expanded(
      child: IconButton(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(),
          splashFactory: NoSplash.splashFactory
        ),
        onPressed: onTap,
        icon: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: isSelected ? filledIcon : icon,
        ),
      ),
    );
  }
}
