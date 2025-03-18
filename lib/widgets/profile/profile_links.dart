import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ProfileLinks extends StatelessWidget {
  final List<String> links;

  const ProfileLinks({required this.links, super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building ProfileLinks with ${links.length} links: $links');
    }

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 6.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: links.map((url) => _buildLinkItem(url)).toList()),
    );
  }

  Widget _buildLinkItem(String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(FluentIcons.link_24_regular, size: 16, color: AppColors.blue),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              url,
              style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
