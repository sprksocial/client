import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:get_it/get_it.dart';

// Placeholder for ProfileLinks widget
class ProfileLinks extends StatelessWidget {
  final List<String> links;

  const ProfileLinks({required this.links, super.key});

  @override
  Widget build(BuildContext context) {
    final SparkLogger logger = GetIt.instance<LogService>().getLogger('ProfileLinks');

    logger.d('Building ProfileLinks with ${links.length} links: $links');

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links.map((url) => _ProfileLinkItem(url: url)).toList(),
      ),
    );
  }
}

class _ProfileLinkItem extends StatelessWidget {
  final String url;

  const _ProfileLinkItem({required this.url});

  @override
  Widget build(BuildContext context) {
    // Use theme colors if possible, or keep AppColors.blue if it's a specific brand blue
    final Color linkColor = AppColors.blue; // Or: Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(FluentIcons.link_24_regular, size: 16, color: linkColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              url,
              style: TextStyle(color: linkColor, fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
