import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/auth/auth.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static final Uri _manageAccountUri = Uri.parse(
    'https://bsky.app/settings/account',
  );

  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Call logout on the auth provider
      await ref.read(authProvider.notifier).logout();

      if (mounted) {
        // Close loading dialog first
        Navigator.of(context).pop();

        // Navigate to login screen
        context.router.replaceAll([const RegisterRoute()]);
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        context.router.maybePop();
      }
    }
  }

  Future<void> _handleManageAccount() async {
    final l10n = AppLocalizations.of(context);
    final authRepository = GetIt.instance<AuthRepository>();
    final pdsUrl = authRepository.pdsEndpoint ?? 'your PDS URL';
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogOpenBlueskyAccount),
        content: Text(l10n.dialogOpenBlueskyAccountDescription(pdsUrl)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.buttonOpen),
          ),
        ],
      ),
    );

    if (shouldOpen != true || !mounted) {
      return;
    }

    final logger = GetIt.instance<LogService>().getLogger('Settings');

    try {
      final didLaunch = await launchUrl(
        _manageAccountUri,
        mode: LaunchMode.externalApplication,
      );

      if (!didLaunch && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorUnableToOpenLink)));
      }
    } catch (error, stackTrace) {
      logger.e(
        'Failed to launch manage account URL: $_manageAccountUri',
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorUnableToOpenLink)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: const AppLeadingButton(),
        title: Text(l10n.pageTitleSettings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  l10n.pageTitleYourFeeds,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(FluentIcons.list_24_regular),
                onTap: () => context.router.push(const FeedListRoute()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  l10n.pageTitleLabelers,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(FluentIcons.tag_24_regular),
                onTap: () =>
                    context.router.push(const LabelerManagementRoute()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  l10n.pageTitleBlockedUsers,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(FluentIcons.prohibited_24_regular),
                onTap: () => context.router.push(const BlocksRoute()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Manage Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(FluentIcons.open_24_regular),
                onTap: _handleManageAccount,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Legal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(FluentIcons.document_24_regular),
                onTap: () => context.router.push(const LegalRoute()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  FluentIcons.sign_out_24_regular,
                  color: Colors.red,
                ),
                onTap: _handleLogout,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
