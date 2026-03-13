import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    required this.displayName,
    required this.handle,
    super.key,
    this.description,
    this.links,
    this.isEarlySupporter = false,
    this.onEarlySupporterTap,
    this.onMentionTap,
  });

  final String displayName;
  final String handle;
  final String? description;
  final List<String>? links;
  final bool isEarlySupporter;
  final VoidCallback? onEarlySupporterTap;
  final Function(String username)? onMentionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ProfileDescriptionText(
            text: description!,
            style: AppTypography.textSmallBold.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            onMentionTap: onMentionTap,
          ),
        ],
        if (links != null && links!.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...links!.map((url) => _ProfileLinkItem(url: url)),
        ],
      ],
    );
  }
}

class _ProfileDescriptionText extends StatelessWidget {
  const _ProfileDescriptionText({
    required this.text,
    required this.style,
    this.onMentionTap,
  });

  final String text;
  final TextStyle style;
  final Function(String username)? onMentionTap;

  List<Match> _findUsernameMatches(String text) {
    final usernameRegex = RegExp(
      r'\B@([a-zA-Z0-9_.-]+\.[a-zA-Z]{2,}|[a-zA-Z0-9_]+)',
      caseSensitive: false,
    );
    return usernameRegex.allMatches(text).toList();
  }

  List<InlineSpan> _buildTextSpans(String text, List<Match> usernameMatches) {
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    usernameMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in usernameMatches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(text: text.substring(lastEnd, match.start), style: style),
        );
      }

      final username = match.group(0)!;
      spans.add(
        TextSpan(
          text: username,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (onMentionTap != null) {
                onMentionTap!(username);
              }
            },
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final usernameMatches = _findUsernameMatches(text);
    final spans = _buildTextSpans(text, usernameMatches);

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }
}

class _ProfileLinkItem extends StatelessWidget {
  const _ProfileLinkItem({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const linkColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              url,
              style: const TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
