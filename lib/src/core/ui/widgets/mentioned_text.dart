import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/utils/text_formatter.dart';

/// A widget that displays text with clickable @mentions
class MentionedText extends StatelessWidget {
  /// Creates a text widget with clickable @mentions
  const MentionedText({
    required this.text,
    required this.onUsernameTap,
    super.key,
    this.expandText = false,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.textStyle,
    this.mentionStyle,
  });

  /// The text to display, which may contain @mentions
  final String text;

  /// Called when a username is tapped
  final Function(String username) onUsernameTap;

  /// Whether to show the full text or truncate it
  final bool expandText;

  /// Maximum number of lines when not expanded
  final int? maxLines;

  /// How to handle overflow when not expanded
  final TextOverflow overflow;

  /// Text style to apply to the regular text
  final TextStyle? textStyle;

  /// Text style to apply to the @mentions, merged with textStyle
  final TextStyle? mentionStyle;

  @override
  Widget build(BuildContext context) {
    final usernameMatches = TextFormatter.findUsernameMatches(text);
    final theme = Theme.of(context);

    final defaultTextStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: 14,
    );

    final baseStyle = textStyle ?? defaultTextStyle;
    final effectiveMentionStyle =
        mentionStyle ??
        const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold);

    // Build text spans for mentions
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    usernameMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in usernameMatches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: baseStyle,
          ),
        );
      }

      final username = match.group(0)!;
      spans.add(
        TextSpan(
          text: username,
          style: effectiveMentionStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () => onUsernameTap(username),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }

    final textSpan = TextSpan(children: spans, style: baseStyle);

    return RichText(
      text: textSpan,
      maxLines: expandText ? null : maxLines,
      overflow: expandText ? TextOverflow.visible : overflow,
    );
  }
}
