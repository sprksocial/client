import 'package:flutter/material.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

const double kStoryMentionInitialHeight = 64;

class StoryMentionChip extends StatelessWidget {
  const StoryMentionChip({
    required this.primaryText,
    this.secondaryText,
    this.compact = false,
    this.fixedHeight,
    super.key,
  });

  final String primaryText;
  final String? secondaryText;
  final bool compact;
  final double? fixedHeight;

  @override
  Widget build(BuildContext context) {
    final child = _MentionText(
      primaryText: primaryText,
      secondaryText: secondaryText,
      compact: compact,
      fixedHeight: fixedHeight,
    );

    if (fixedHeight == null) {
      return child;
    }

    return SizedBox(height: fixedHeight, child: child);
  }
}

Size measureStoryMentionChipSize({
  required String primaryText,
  String? secondaryText,
  bool compact = false,
  double height = kStoryMentionInitialHeight,
}) {
  final metrics = _StoryMentionMetrics.fromHeight(
    height: height,
    compact: compact,
  );
  final handleText = primaryText.startsWith('@')
      ? primaryText.substring(1)
      : primaryText;
  final baseStyle = TextStyle(
    color: const Color(0xFF111827),
    fontWeight: FontWeight.w700,
    fontSize: metrics.fontSize,
    height: compact ? 1 : 1.05,
  );

  final painter = TextPainter(
    text: TextSpan(
      style: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
      children: [
        TextSpan(
          text: '@',
          style: baseStyle.copyWith(color: AppColors.primary600),
        ),
        TextSpan(text: handleText, style: baseStyle),
        if (!compact && secondaryText != null && secondaryText.isNotEmpty)
          TextSpan(
            text: '\n$secondaryText',
            style: baseStyle.copyWith(
              fontSize: metrics.sublineSize,
              fontWeight: FontWeight.w500,
              color: AppColors.grey400,
              height: 1.15,
            ),
          ),
      ],
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  return Size(painter.width + metrics.horizontalPadding * 2, height);
}

class _MentionText extends StatelessWidget {
  const _MentionText({
    required this.primaryText,
    required this.secondaryText,
    required this.compact,
    required this.fixedHeight,
  });

  final String primaryText;
  final String? secondaryText;
  final bool compact;
  final double? fixedHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = fixedHeight ?? constraints.maxHeight;
        final metrics = _StoryMentionMetrics.fromHeight(
          height: availableHeight.isFinite
              ? availableHeight
              : kStoryMentionInitialHeight,
          compact: compact,
        );
        final handleText = primaryText.startsWith('@')
            ? primaryText.substring(1)
            : primaryText;
        final maxTextWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth - metrics.horizontalPadding * 2).clamp(
                24.0,
                double.infinity,
              )
            : double.infinity;

        final baseStyle = TextStyle(
          color: const Color(0xFF111827),
          fontWeight: FontWeight.w700,
          fontSize: metrics.fontSize,
          height: compact ? 1 : 1.05,
        );

        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: metrics.horizontalPadding,
            ),
            child: RoundedBackgroundText.rich(
              maxTextWidth: maxTextWidth,
              backgroundColor: Colors.white,
              leadingDistribution: TextLeadingDistribution.even,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '@',
                    style: baseStyle.copyWith(color: AppColors.primary600),
                  ),
                  TextSpan(text: handleText, style: baseStyle),
                  if (!compact &&
                      secondaryText != null &&
                      secondaryText!.isNotEmpty)
                    TextSpan(
                      text: '\n$secondaryText',
                      style: baseStyle.copyWith(
                        fontSize: metrics.sublineSize,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey400,
                        height: 1.15,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoryMentionMetrics {
  const _StoryMentionMetrics({
    required this.fontSize,
    required this.sublineSize,
    required this.horizontalPadding,
  });

  final double fontSize;
  final double sublineSize;
  final double horizontalPadding;

  factory _StoryMentionMetrics.fromHeight({
    required double height,
    required bool compact,
  }) {
    final normalizedHeight = height.clamp(compact ? 28.0 : 36.0, 96.0);
    final fontSize = (normalizedHeight * (compact ? 0.42 : 0.32)).clamp(
      compact ? 12.0 : 14.0,
      compact ? 18.0 : 20.0,
    );

    return _StoryMentionMetrics(
      fontSize: fontSize,
      sublineSize: (fontSize * 0.62).clamp(10.0, 13.0),
      horizontalPadding: compact ? 4 : 6,
    );
  }
}
