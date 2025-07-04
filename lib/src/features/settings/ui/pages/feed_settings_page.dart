import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/settings/ui/pages/feed_list_page.dart';
import 'package:sparksocial/src/features/settings/ui/pages/label_settings_page.dart';

@RoutePage()
class FeedSettingsPage extends ConsumerStatefulWidget {
  const FeedSettingsPage({super.key});

  @override
  ConsumerState<FeedSettingsPage> createState() => _FeedSettingsPageState();
}

class _FeedSettingsPageState extends ConsumerState<FeedSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Settings'),
        centerTitle: true,
        leading: const AutoLeadingButton(),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: textColor,
          unselectedLabelColor: textColor.withAlpha(127),
          isScrollable: false,
          tabs: const [
            Tab(text: "Your Feeds"),
            Tab(text: "Content Labels"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FeedListPage(),
          LabelSettingsPage(),
        ],
      ),
    );
  }
}
