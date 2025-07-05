import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/fading_list_view.dart';

class HashtagList extends StatelessWidget {
  const HashtagList({required this.hashtags, super.key, this.style, this.onHashtagTap});
  final List<String> hashtags;
  final TextStyle? style;
  final Function(String)? onHashtagTap;

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadingListView(
      fadeWidth: 16,
      children: hashtags.map((tag) {
        return GestureDetector(
          onTap: onHashtagTap != null ? () => onHashtagTap!(tag) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.white.withAlpha(50), borderRadius: BorderRadius.circular(12)),
            child: Text(
              '#$tag',
              style: style ?? const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        );
      }).toList(),
    );
  }
}
