import 'package:flutter/widgets.dart';

class TypographyPreview extends StatelessWidget {
  const TypographyPreview({
    super.key,
    required this.name,
    required this.styles,
  });

  final String name;
  final Map<String, TextStyle> styles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: 0.64,
          child: Text(
            name.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w200),
          ),
        ),
        for (final style in styles.entries) Text(style.key, style: style.value),
      ],
    );
  }
}
