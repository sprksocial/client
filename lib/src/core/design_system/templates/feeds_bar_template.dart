import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/molecules/feed_tag_list.dart';

/// Design-only template for the Feeds Bar.
///
/// This template renders the tags row with an optional trailing action and
/// a subtle top-to-bottom gradient backdrop. No providers or navigation here.
class FeedsBarTemplate extends StatelessWidget {
  const FeedsBarTemplate({
    required this.tags,
    this.selectedTagId,
    this.onTagTap,
    this.action,
    this.height = kToolbarHeight,
    super.key,
  });

  final List<({String id, String text})> tags;
  final String? selectedTagId;
  final ValueChanged<String>? onTagTap;
  final Widget? action;
  final double height;

  // @override
  // Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30 + kToolbarHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop gradient from top (slightly dark) to transparent
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(110, 0, 0, 0), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: FeedTagList(
                      tags: tags,
                      selectedTagId: selectedTagId,
                      onTagTap: onTagTap,
                    ),
                  ),
                  if (action != null) ...[
                    const SizedBox(width: 8),
                    action!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
