import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:sparksocial/src/features/settings/ui/pages/feed_list_page.dart';
import 'package:sparksocial/src/features/settings/ui/pages/labeler_management_page.dart';

@RoutePage()
class FeedSettingsPage extends ConsumerStatefulWidget {
  const FeedSettingsPage({super.key});

  @override
  ConsumerState<FeedSettingsPage> createState() => _FeedSettingsPageState();
}

class _FeedSettingsPageState extends ConsumerState<FeedSettingsPage> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Settings'),
        centerTitle: true,
        leading: const AppLeadingButton(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Your Feeds'),
            Tab(text: 'Labelers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FeedListPage(),
          LabelerManagementPage(),
        ],
      ),
    );
  }
}
