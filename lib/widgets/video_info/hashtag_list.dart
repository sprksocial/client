import 'package:flutter/material.dart';

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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: hashtags.map((tag) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: onHashtagTap != null ? () => onHashtagTap!(tag) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '#$tag',
                  style: style ?? const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Extract hashtags from a text string
  static List<String> extractFromText(String text) {
    if (text.isEmpty) {
      return [];
    }

    final matches = RegExp(r'#(\w+)').allMatches(text);
    if (matches.isEmpty) {
      return [];
    }

    return matches.map((m) => m.group(1)!).toList();
  }
}
