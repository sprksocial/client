import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'action_button.dart';
import '../../utils/app_colors.dart';

class BookmarkActionButton extends StatelessWidget {
  final String count;
  final bool isBookmarked;
  final VoidCallback? onPressed;

  const BookmarkActionButton({
    super.key,
    required this.count,
    this.isBookmarked = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: isBookmarked ? FluentIcons.bookmark_24_filled : FluentIcons.bookmark_24_regular,
      label: count,
      onPressed: onPressed,
      color: isBookmarked ? AppColors.blue : CupertinoColors.white,
    );
  }
} 