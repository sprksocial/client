import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class TextFormatter {
  // Format count numbers for better readability
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
      return '${(numCount / 1000000).toStringAsFixed(1)}M';
    } else if (numCount >= 10000) {
      return '${(numCount / 1000).toStringAsFixed(0)}K';
    } else if (numCount >= 1000) {
      return '${(numCount / 1000).toStringAsFixed(1)}K';
    } else {
      return numCount.toString();
    }
  }

  // Extract usernames (@mentions) from text
  static List<Match> findUsernameMatches(String text) {
    // Match patterns like "@username" or "@username.domain"
    final RegExp usernameRegex = RegExp(r'@([a-zA-Z0-9_.-]+\.[a-zA-Z]{2,}|[a-zA-Z0-9_]+)', caseSensitive: false);

    return usernameRegex.allMatches(text).toList();
  }

  // Extract URLs from text (excluding usernames)
  static List<String> extractUrls(String text) {
    final RegExp urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    final List<String> urls = [];
    for (final Match match in urlRegex.allMatches(text)) {
      final url = match.group(0)!;
      // Skip if it looks like a username with @ prefix
      if (url.startsWith('@')) continue;
      urls.add(url);
    }

    // If no URLs found with the complex regex, try a simpler approach
    if (urls.isEmpty) {
      // Look for common domain patterns like "example.com" or "esfera.dev"
      final simpleRegex = RegExp(r'([a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?)', caseSensitive: false);
      for (final Match match in simpleRegex.allMatches(text)) {
        final domain = match.group(0)!;
        // Skip if it's part of a username (with @ prefix)
        if (text.contains('@$domain') || text.contains('@${domain.split('.')[0]}')) {
          continue;
        }
        // Skip common words that might match but aren't domains
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

  // Build rich text with clickable, highlighted usernames
  static RichText buildRichTextWithMentions(
    BuildContext context,
    String text,
    bool expandDescription,
    Function(String) onUsernameTap,
  ) {
    // Get all username matches
    final usernameMatches = findUsernameMatches(text);

    // Build rich text with clickable usernames
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

  // Build text spans with username highlighting
  static List<InlineSpan> _buildTextSpans(
    BuildContext context,
    String text,
    List<Match> usernameMatches,
    Function(String) onUsernameTap,
  ) {
    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    // Sort matches by position
    usernameMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in usernameMatches) {
      // Add text before username
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // Add username with styling and tap handler
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

    // Add remaining text after last username
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }
}
