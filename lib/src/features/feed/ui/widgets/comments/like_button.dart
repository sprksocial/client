import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final bool isLoading;
  final int likeCount;
  final VoidCallback onPressed;
  final Color textColor;
  final double fontSize;
  final double iconSize;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onPressed,
    required this.textColor,
    this.isLoading = false,
    this.fontSize = 12.0,
    this.iconSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        children: [
          _LikeIcon(isLiked: isLiked, isLoading: isLoading, iconSize: iconSize, textColor: textColor),
          const SizedBox(width: 4),
          Text(likeCount.toString(), style: TextStyle(fontSize: fontSize, color: textColor)),
        ],
      ),
    );
  }
}

class _LikeIcon extends StatelessWidget {
  final bool isLiked;
  final bool isLoading;
  final double iconSize;
  final Color textColor;

  const _LikeIcon({required this.isLiked, required this.isLoading, required this.iconSize, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final IconData icon = isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular;

    final Color color = isLiked ? AppColors.red : textColor;

    return Icon(icon, size: iconSize, color: color);
  }
}
