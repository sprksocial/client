import 'package:flutter/material.dart';

class VideoDescription extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  const VideoDescription({super.key, required this.text, this.style, this.maxLines = 2, this.overflow = TextOverflow.ellipsis});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? const TextStyle(color: Colors.white, fontSize: 13), maxLines: maxLines, overflow: overflow);
  }
}
