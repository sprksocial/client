import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/ui/widgets/mentioned_text.dart';

/// Utility class for text formatting and processing
class TextFormatter {
  /// Formats a number into a readable format (e.g., 1.5K, 2.3M)
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
      final formattedValue = value.toStringAsFixed(
        value.truncateToDouble() == value ? 0 : 1,
      );
      return '${formattedValue}M';
    } else if (numCount >= 1000) {
      final value = numCount / 1000;
      final formattedValue = value.toStringAsFixed(
        value.truncateToDouble() == value ? 0 : 1,
      );
      return '${formattedValue}K';
    } else {
      return numCount.toString();
    }
  }

  /// Finds username matches in a text string
  static List<Match> findUsernameMatches(String text) {
    final usernameRegex = RegExp(
      r'@([a-zA-Z0-9_.-]+\.[a-zA-Z]{2,}|[a-zA-Z0-9_]+)',
      caseSensitive: false,
    );

    return usernameRegex.allMatches(text).toList();
  }

  /// Extracts URLs from a text string
  static List<String> extractUrls(String text) {
    final urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    final urls = <String>[];
    for (final Match match in urlRegex.allMatches(text)) {
      final url = match.group(0)!;
      if (url.startsWith('@')) continue;
      urls.add(url);
    }

    if (urls.isEmpty) {
      final simpleRegex = RegExp(
        r'([a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?)',
        caseSensitive: false,
      );
      for (final Match match in simpleRegex.allMatches(text)) {
        final domain = match.group(0)!;
        if (text.contains('@$domain') ||
            text.contains('@${domain.split('.')[0]}')) {
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

  static Widget buildTextWithMentions(
    BuildContext context,
    String text,
    bool expandDescription,
    Function(String) onUsernameTap,
  ) {
    return MentionedText(
      text: text,
      onUsernameTap: onUsernameTap,
      expandText: expandDescription,
      maxLines: expandDescription ? null : 2,
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
      mentionStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Converts a character index to a UTF-8 byte index
  static int charIndexToByteIndex(String text, int charIndex) {
    if (charIndex < 0) return 0;
    if (charIndex >= text.length) return utf8.encode(text).length;
    return utf8.encode(text.substring(0, charIndex)).length;
  }

  /// Converts a UTF-8 byte index to a character index
  static int byteIndexToCharIndex(String text, int byteIndex) {
    if (byteIndex <= 0) return 0;
    final bytes = utf8.encode(text);
    if (byteIndex >= bytes.length) return text.length;

    var charIndex = 0;
    var byteCount = 0;
    for (final rune in text.runes) {
      final character = String.fromCharCode(rune);
      final charBytes = utf8.encode(character);
      if (byteCount + charBytes.length > byteIndex) break;
      byteCount += charBytes.length;
      charIndex += character.length;
    }
    return charIndex;
  }

  /// Gets the UTF-8 byte length of a string
  static int byteLength(String text) => utf8.encode(text).length;

  /// Creates Spark Facet objects from a list of Mention objects
  static List<Facet> buildMentionFacets(List<dynamic> mentions) {
    return mentions.map((mention) {
      return Facet(
        index: FacetIndex(
          byteStart: mention.byteStart as int,
          byteEnd: mention.byteEnd as int,
        ),
        features: [FacetFeature.mention(did: mention.did as String)],
      );
    }).toList();
  }
}
