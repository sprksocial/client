import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  static const List<String> _legalPaths = ['/privacy', '/terms', '/support'];

  static final Uri _baseUri = Uri.parse('https://sprk.so');

  String _titleForPath(String path, AppLocalizations l10n) {
    switch (path) {
      case '/privacy':
        return l10n.labelPrivacyPolicy;
      case '/terms':
        return l10n.labelTermsOfService;
      case '/support':
        return l10n.labelSupport;
      default:
        return path;
    }
  }

  Future<void> _openLink(BuildContext context, String path) async {
    final l10n = AppLocalizations.of(context);
    final logger = GetIt.instance<LogService>().getLogger('LegalPage');
    final uri = _baseUri.replace(path: path);

    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!didLaunch && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorUnableToOpenLink)));
      }
    } catch (error, stackTrace) {
      logger.e(
        'Failed to launch legal URL: $uri',
        error: error,
        stackTrace: stackTrace,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorUnableToOpenLink)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppLeadingButton(),
        title: Text(l10n.pageTitleLegal),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _legalPaths.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final path = _legalPaths[index];

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                _titleForPath(path, l10n),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('sprk.so$path'),
              trailing: const Icon(FluentIcons.open_24_regular),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              onTap: () => _openLink(context, path),
            ),
          );
        },
      ),
    );
  }
}
