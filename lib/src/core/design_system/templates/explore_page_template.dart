import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/molecules/input_field.dart';

class ExplorePageTemplate extends StatelessWidget {
  const ExplorePageTemplate({
    required this.emptyStateWidget,
    required this.tabsWidget,
    required this.contentWidget,
    super.key,
    this.searchWidget,
    this.searchController,
    this.searchFocusNode,
    this.searchHintText = '',
    this.onSearchSubmitted,
    this.onClearSearch,
    this.showClearSearch = false,
    this.showTabs = false,
    this.backgroundColor,
  });

  final Widget? searchWidget;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final String searchHintText;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onClearSearch;
  final bool showClearSearch;
  final Widget emptyStateWidget;
  final Widget? tabsWidget;
  final Widget contentWidget;
  final bool showTabs;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _buildSearch()),
            if (showTabs && tabsWidget != null) tabsWidget!,
            Expanded(child: showTabs ? contentWidget : emptyStateWidget),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    if (searchWidget != null) return searchWidget!;

    return InputField.search(
      controller: searchController,
      focusNode: searchFocusNode,
      hintText: searchHintText,
      onSubmitted: onSearchSubmitted,
      textInputAction: TextInputAction.search,
      leadingWidgets: const [Icon(FluentIcons.search_24_regular, size: 20)],
      actionWidgets: showClearSearch
          ? [
              GestureDetector(
                onTap: onClearSearch,
                child: const Icon(FluentIcons.dismiss_24_regular, size: 20),
              ),
            ]
          : null,
    );
  }
}
