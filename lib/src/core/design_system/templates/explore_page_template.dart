import 'package:flutter/material.dart';

class ExplorePageTemplate extends StatelessWidget {
  const ExplorePageTemplate({
    required this.searchWidget,
    required this.emptyStateWidget,
    required this.tabsWidget,
    required this.contentWidget,
    super.key,
    this.showTabs = false,
    this.backgroundColor,
  });

  final Widget searchWidget;
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: searchWidget,
            ),
            if (showTabs && tabsWidget != null) tabsWidget!,
            Expanded(
              child: showTabs ? contentWidget : emptyStateWidget,
            ),
          ],
        ),
      ),
    );
  }
}
