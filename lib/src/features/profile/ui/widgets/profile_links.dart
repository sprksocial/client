import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

// Placeholder for ProfileLinks widget
class ProfileLinks extends StatelessWidget {
  const ProfileLinks({required this.links, super.key});
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    final logger = GetIt.instance<LogService>().getLogger('ProfileLinks');

    logger.d('Building ProfileLinks with ${links.length} links: $links');

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links.map((url) => _ProfileLinkItem(url: url)).toList(),
      ),
    );
  }
}

class _ProfileLinkItem extends StatelessWidget {
  const _ProfileLinkItem({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    // Use theme colors if possible, or keep AppColors.blue if it's a specific brand blue
    const linkColor = AppColors.blue; // Or: Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          const Icon(FluentIcons.link_24_regular, size: 16, color: linkColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              url,
              style: const TextStyle(color: linkColor, fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
