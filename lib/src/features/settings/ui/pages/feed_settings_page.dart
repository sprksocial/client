import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/features/home/providers/feed_settings_visibility_provider.dart';
import 'package:spark/src/features/settings/ui/pages/feed_list_page.dart';
import 'package:spark/src/features/settings/ui/pages/labeler_management_page.dart';

@RoutePage()
class FeedSettingsPage extends ConsumerStatefulWidget {
  const FeedSettingsPage({super.key});

  @override
  ConsumerState<FeedSettingsPage> createState() => _FeedSettingsPageState();
}

class _FeedSettingsPageState extends ConsumerState<FeedSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FeedSettingsVisibility? _visibilityNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Store notifier reference & mark feed settings as visible when page opens
    // Use post-frame callback to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _visibilityNotifier = ref.read(feedSettingsVisibilityProvider.notifier);
        _visibilityNotifier?.setVisible(true);
      }
    });
  }

  @override
  void dispose() {
    // Mark feed settings as not visible when page closes
    // Use Future to delay the modification until after dispose completes
    final notifier = _visibilityNotifier;
    Future(() {
      notifier?.setVisible(false);
    });
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          color: colorScheme.onSurface,
        ),
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
