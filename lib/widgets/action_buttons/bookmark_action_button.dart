import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'action_button.dart';

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
      icon: isBookmarked ? Ionicons.bookmark : Ionicons.bookmark_outline,
      label: count,
      onPressed: onPressed,
    );
  }
} 