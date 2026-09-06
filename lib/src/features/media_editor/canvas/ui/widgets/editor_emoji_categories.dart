import 'package:flutter/material.dart';
import 'package:pro_image_editor/features/emoji_editor/services/emoji_state_manager.dart';
import 'package:pro_image_editor/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

/// Category previews use emoji content without adding category-specific icons.
class EditorEmojiCategories extends CategoryView {
  const EditorEmojiCategories(
    super.config,
    super.state,
    super.tabController,
    super.pageController, {
    super.key,
  });

  @override
  State<EditorEmojiCategories> createState() => _EditorEmojiCategoriesState();
}

class _EditorEmojiCategoriesState
    extends CategoryViewState<EditorEmojiCategories> {
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final categories = widget.state.categoryEmoji;
    return SizedBox(
      height: widget.config.categoryViewConfig.tabBarHeight,
      child: TabBar(
        controller: widget.tabController,
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.greyWhite.withValues(alpha: 0.15),
        ),
        onTap: (index) {
          closeSkinToneOverlay();
          EmojiStateManager.of(
            context,
          )?.setActiveCategory(categories[index].category);
        },
        tabs: categories.map((item) {
          final (emoji, label) = switch (item.category) {
            Category.RECENT => ('', labels.emojiCategoryRecent),
            Category.SMILEYS => ('😀', labels.emojiCategorySmileys),
            Category.ANIMALS => ('🐾', labels.emojiCategoryAnimals),
            Category.FOODS => ('🍔', labels.emojiCategoryFoods),
            Category.TRAVEL => ('🚗', labels.emojiCategoryTravel),
            Category.ACTIVITIES => ('⚽', labels.emojiCategoryActivities),
            Category.OBJECTS => ('💡', labels.emojiCategoryObjects),
            Category.SYMBOLS => ('❤️', labels.emojiCategorySymbols),
            Category.FLAGS => ('🏁', labels.emojiCategoryFlags),
          };
          return Tab(
            child: Tooltip(
              message: label,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: item.category == Category.RECENT
                    ? const AppIcon(
                        AppIconData.history,
                        size: 20,
                        color: AppColors.greyWhite,
                      )
                    : Text(
                        emoji,
                        style:
                            (widget.config.emojiTextStyle ?? const TextStyle())
                                .copyWith(fontSize: 20),
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
