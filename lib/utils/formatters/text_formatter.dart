import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class TextFormatter {
  static String formatCount(dynamic count) {
    if (count == null) return '0';

    int numCount;
    if (count is String) {
      numCount = int.tryParse(count) ?? 0;
    } else if (count is int) {
      numCount = count;
    } else {
      return '0';
    }

    if (numCount >= 1000000) {
      final value = numCount / 1000000;
      return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}M';
    } else if (numCount >= 1000) {
      final value = numCount / 1000;
      return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}K';
    } else {
      return numCount.toString();
    }
  }

  static List<Match> findUsernameMatches(String text) {
    final RegExp usernameRegex = RegExp(r'@([a-zA-Z0-9_.-]+\.[a-zA-Z]{2,}|[a-zA-Z0-9_]+)', caseSensitive: false);

    return usernameRegex.allMatches(text).toList();
  }

  static List<String> extractUrls(String text) {
    final RegExp urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    final List<String> urls = [];
    for (final Match match in urlRegex.allMatches(text)) {
      final url = match.group(0)!;
      if (url.startsWith('@')) continue;
      urls.add(url);
    }

    if (urls.isEmpty) {
      final simpleRegex = RegExp(r'([a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?)', caseSensitive: false);
      for (final Match match in simpleRegex.allMatches(text)) {
        final domain = match.group(0)!;
        if (text.contains('@$domain') || text.contains('@${domain.split('.')[0]}')) {
          continue;
        }
        if (!domain.contains('.com') &&
            !domain.contains('.org') &&
            !domain.contains('.net') &&
            !domain.contains('.dev') &&
            !domain.contains('.io') &&
            !domain.contains('.app')) {
          continue;
        }
        urls.add(domain);
      }
    }

    return urls;
  }

  static RichText buildRichTextWithMentions(
    BuildContext context,
    String text,
    bool expandDescription,
    Function(String) onUsernameTap,
  ) {
    final usernameMatches = findUsernameMatches(text);

    final TextSpan textSpan = TextSpan(
      children: _buildTextSpans(context, text, usernameMatches, onUsernameTap),
      style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 14),
    );

    return RichText(
      text: textSpan,
      maxLines: expandDescription ? null : 2,
      overflow: expandDescription ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }

  static List<InlineSpan> _buildTextSpans(
    BuildContext context,
    String text,
    List<Match> usernameMatches,
    Function(String) onUsernameTap,
  ) {
    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    usernameMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in usernameMatches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      final username = match.group(0)!;
      spans.add(
        TextSpan(
          text: username,
          style: const TextStyle(
            color: AppColors.primary, // Pink color for usernames
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => onUsernameTap(username),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }
}
