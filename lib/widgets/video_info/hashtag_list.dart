import 'package:flutter/cupertino.dart';

class HashtagList extends StatelessWidget {
  final List<String> hashtags;
  final TextStyle? style;
  final VoidCallback? onHashtagTap;

  const HashtagList({
    super.key,
    required this.hashtags,
    this.style,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: hashtags.map((tag) {
        return GestureDetector(
          onTap: onHashtagTap,
          child: Text(
            '#$tag',
            style: style ?? const TextStyle(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }
} 