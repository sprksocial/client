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

    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children:
          hashtags.map((tag) {
            return GestureDetector(
              onTap: onHashtagTap != null ? () => onHashtagTap!(tag) : null,
              child: Text(
                '#$tag',
                style: style ?? const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
              ),
            );
          }).toList(),
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
