import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/molecules/feed_tag_list.dart';

/// The preferred height for the feeds bar content (excludes status bar).
/// The actual rendered height includes top safe area padding.
/// This is designed for use with [Scaffold.extendBodyBehindAppBar] = true.
const kFeedsBarHeight = kToolbarHeight;

/// The width of the leading button area, matching [kToolbarHeight] like AppBar.
const kFeedsBarLeadingWidth = 40.0;

/// Design-only template for the Feeds Bar.
///
/// This template renders the tags row with a built-in leading button and
/// a subtle top-to-bottom gradient backdrop. Implements [PreferredSizeWidget]
/// so it can be used as an AppBar.
///
/// The leading button is built-in (similar to how [AppBar] handles leading)
/// and displays a create post icon. Use [onLeadingPressed] to handle taps.
class FeedsBarTemplate extends StatelessWidget implements PreferredSizeWidget {
  const FeedsBarTemplate({
    required this.tags,
    this.selectedTagId,
    this.onTagTap,
    this.onReorder,
    this.onLongPress,
    this.enableReordering = false,
    this.onLeadingPressed,
    super.key,
  });

  final List<FeedTagData> tags;
  final String? selectedTagId;
  final ValueChanged<String>? onTagTap;
  final Function(int oldIndex, int newIndex)? onReorder;
  final Function(FeedTagData tag)? onLongPress;
  final bool enableReordering;

  /// Callback when the leading (create post) button is pressed.
  final VoidCallback? onLeadingPressed;

  /// Returns the toolbar height for layout calculations.
  /// The actual widget height includes status bar safe area padding,
  /// matching [AppBar] & works with [Scaffold.extendBodyBehindAppBar] = true.
  @override
  Size get preferredSize => const Size.fromHeight(kFeedsBarHeight);

  @override
  Widget build(BuildContext context) {
    // Use a Column to let the widget size naturally based on SafeArea + content
    // This avoids the preferredSize mismatch issue
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Backdrop gradient - positioned to fill available space
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(110, 0, 0, 0), Colors.transparent],
              ),
            ),
          ),
        ),
        // Content with SafeArea - this determines the widget's intrinsic height
        SafeArea(
          bottom: false,
          left: false,
          right: false,
          child: SizedBox(
            height: kFeedsBarHeight,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  // Leading button - matches AppLeadingButton structure exactly
                  SizedBox(
                    width: kFeedsBarLeadingWidth,
                    height: kFeedsBarLeadingWidth,
                    child: Tooltip(
                      message: 'Create post',
                      child: GestureDetector(
                        onTap: onLeadingPressed,
                        child: Center(child: AppIcons.addPostFilled(size: 28)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FeedTagList(
                      tags: tags,
                      selectedTagId: selectedTagId,
                      onTagTap: onTagTap,
                      onReorder: onReorder,
                      onLongPress: onLongPress,
                      enableReordering: enableReordering,
                      enableRightFade: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
