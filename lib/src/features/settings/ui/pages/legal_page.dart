import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  static const List<({String title, String path})> _legalLinks = [
    (title: 'Privacy Policy', path: '/privacy'),
    (title: 'Terms of Service', path: '/terms'),
    (title: 'Support', path: '/support'),
  ];

  static final Uri _baseUri = Uri.parse('https://sprk.so');

  Future<void> _openLink(BuildContext context, String path) async {
    final logger = GetIt.instance<LogService>().getLogger('LegalPage');
    final uri = _baseUri.replace(path: path);

    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!didLaunch && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open link right now.')),
        );
      }
    } catch (error, stackTrace) {
      logger.e(
        'Failed to launch legal URL: $uri',
        error: error,
        stackTrace: stackTrace,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open link right now.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppLeadingButton(),
        title: const Text('Legal'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _legalLinks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final link = _legalLinks[index];

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                link.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('sprk.so${link.path}'),
              trailing: const Icon(FluentIcons.open_24_regular),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              onTap: () => _openLink(context, link.path),
            ),
          );
        },
      ),
    );
  }
}
