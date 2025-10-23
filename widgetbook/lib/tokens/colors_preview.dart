import 'package:flutter/material.dart';

class ColorPalettePreview extends StatelessWidget {
  const ColorPalettePreview({
    super.key,
    required this.name,
    required this.colors,
  });

  final String name;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in colors) _ColorShadePreview(color: color),
          ],
        ),
      ],
    );
  }
}

class _ColorShadePreview extends StatelessWidget {
  const _ColorShadePreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
