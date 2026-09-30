import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/auth/auth.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/follow_import/providers/follow_import_provider.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _openingAccountManagement = false;

  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      showDialog<void>(
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
    if (_openingAccountManagement) return;
    final l10n = AppLocalizations.of(context);
    final authRepository = GetIt.instance<AuthRepository>();
    final logger = GetIt.instance<LogService>().getLogger('Settings');
    setState(() => _openingAccountManagement = true);

    try {
      final manageAccountUri = await authRepository.getAccountManagementUri();
      if (!mounted) return;
      final didLaunch = await launchUrl(
        manageAccountUri,
        mode: LaunchMode.inAppBrowserView,
      );

      if (!didLaunch && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorUnableToOpenLink)));
      }
    } catch (error, stackTrace) {
      logger.e(
        'Failed to open account management',
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorUnableToOpenLink)));
      }
    } finally {
      if (mounted) setState(() => _openingAccountManagement = false);
    }
  }

  Future<void> _handleFollowImport() async {
    final imported = await context.router.push<bool>(const FollowImportRoute());
    if (!mounted || imported != true) return;

    await ref
        .read(followImportControllerProvider.notifier)
        .refreshFollowingFeed();
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
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                splashColor: Colors.transparent,
                title: Text(
                  l10n.pageTitleYourFeeds,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const AppIcon(AppIconData.alignLeft),
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
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('settings-follow-import'),
                splashColor: Colors.transparent,
                title: Text(
                  l10n.settingsFollowImportTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const AppIcon(AppIconData.people),
                onTap: _handleFollowImport,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                splashColor: Colors.transparent,
                title: Text(
                  l10n.pageTitleModeration,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const AppIcon(AppIconData.shield),
                onTap: () => context.router.push(const ModerationRoute()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                splashColor: Colors.transparent,
                title: Text(
                  l10n.pageTitleBlockedUsers,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const AppIcon(AppIconData.block),
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
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                splashColor: Colors.transparent,
                title: Text(
                  l10n.settingsManageAccountTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(l10n.settingsManageAccountDescription),
                trailing: _openingAccountManagement
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const AppIcon(AppIconData.externalLink),
                onTap: _openingAccountManagement ? null : _handleManageAccount,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                splashColor: Colors.transparent,
                title: const Text(
                  'Legal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const AppIcon(AppIconData.document),
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
            child: Material(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                splashColor: Colors.transparent,
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const AppIcon(AppIconData.signOut, color: Colors.red),
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
