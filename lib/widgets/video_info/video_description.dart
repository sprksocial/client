import 'package:flutter/material.dart';

class VideoDescription extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final Function(bool isExpanded)? onExpandToggle;

  const VideoDescription({super.key, required this.text, this.style, this.maxLines = 2, this.onExpandToggle});

  @override
  State<VideoDescription> createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    if (!mounted) return;

    setState(() {
      _isExpanded = !_isExpanded;

      if (widget.onExpandToggle != null) {
        widget.onExpandToggle!(_isExpanded);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 13, fontFamily: 'Roboto') ??
        const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Roboto');

    // Process text to ensure emoji display correctly
    final processedText = widget.text;

    return GestureDetector(
      onTap: _toggleExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use RichText for better control over text rendering
          _isExpanded
              ? Text.rich(TextSpan(text: processedText), style: widget.style ?? defaultTextStyle, textAlign: TextAlign.start)
              : LayoutBuilder(
                builder: (context, constraints) {
                  return Text(
                    processedText,
                    style: widget.style ?? defaultTextStyle,
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  );
                },
              ),
          if (widget.text.isNotEmpty && !_isExpanded && _isTextTruncated(context))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'See more',
                style: defaultTextStyle.copyWith(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  bool _isTextTruncated(BuildContext context) {
    final textSpan = TextSpan(
      text: widget.text,
      style: widget.style ?? Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 13),
    );

    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, maxLines: widget.maxLines);

    // Use available width accounting for padding
    final availableWidth = MediaQuery.of(context).size.width - 32;
    textPainter.layout(maxWidth: availableWidth);

    // Check if the text would be truncated
    return textPainter.didExceedMaxLines || textPainter.height > (widget.maxLines * textPainter.preferredLineHeight);
  }
}
