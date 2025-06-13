import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/fading_list_view.dart';

class HashtagList extends StatelessWidget {
  final List<String> hashtags;
  final TextStyle? style;
  final Function(String)? onHashtagTap;

  const HashtagList({super.key, required this.hashtags, this.style, this.onHashtagTap});

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadingListView(
      isHorizontal: true,
      fadeWidth: 16.0,
      itemSpacing: 8.0,
      children:
          hashtags.map((tag) {
            return GestureDetector(
              onTap: onHashtagTap != null ? () => onHashtagTap!(tag) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(color: AppColors.white.withAlpha(50), borderRadius: BorderRadius.circular(12.0)),
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
