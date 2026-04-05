import 'package:flutter/material.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/utils/text_formatter.dart';
import 'package:spark/src/features/posting/models/mention.dart';

/// A custom [TextEditingController] that styles @mentions in pink
/// while displaying regular text in the default style.
class MentionTextEditingController extends TextEditingController {
  MentionTextEditingController({super.text});

  /// The list of mentions to highlight. Should be kept in sync with the
  /// [MentionController].
  List<Mention> _mentions = const [];

  List<Mention> get mentions => _mentions;

  set mentions(List<Mention> value) {
    if (_sameMentions(_mentions, value)) {
      return;
    }

    _mentions = List<Mention>.unmodifiable(value);
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    assert(!value.composing.isValid || !withComposing || value.isComposingRangeValid);

    final theme = Theme.of(context);
    final effectiveStyle =
        style ?? TextStyle(color: theme.colorScheme.onSurface, fontSize: 16);

    final mentionStyle = effectiveStyle.copyWith(
      color: AppColors.pink,
      fontWeight: FontWeight.w600,
    );
    final composingStyle = effectiveStyle.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );

    final text = this.text;
    if (_mentions.isEmpty || text.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: effectiveStyle,
        withComposing: withComposing,
      );
    }

    final composingRegionOutOfRange =
        !value.isComposingRangeValid || !withComposing;
    final composingStart = composingRegionOutOfRange ? -1 : value.composing.start;
    final composingEnd = composingRegionOutOfRange ? -1 : value.composing.end;

    final boundaries = <int>{0, text.length};
    final mentionRanges = <({int start, int end})>[];

    // Sort mentions by byte start to process them in order.
    final sortedMentions = List<Mention>.from(_mentions)
      ..sort((a, b) => a.byteStart.compareTo(b.byteStart));

    for (final mention in sortedMentions) {
      // Convert byte indices to character indices.
      final charStart = TextFormatter.byteIndexToCharIndex(
        text,
        mention.byteStart,
      );
      final charEnd = TextFormatter.byteIndexToCharIndex(text, mention.byteEnd);

      // Skip invalid mentions.
      if (charStart < 0 ||
          charEnd > text.length ||
          charStart >= charEnd) {
        continue;
      }

      boundaries
        ..add(charStart)
        ..add(charEnd);
      mentionRanges.add((start: charStart, end: charEnd));
    }

    if (!composingRegionOutOfRange) {
      boundaries
        ..add(composingStart)
        ..add(composingEnd);
    }

    final sortedBoundaries = boundaries.toList()..sort();
    final spans = <InlineSpan>[];

    for (var i = 0; i < sortedBoundaries.length - 1; i++) {
      final start = sortedBoundaries[i];
      final end = sortedBoundaries[i + 1];

      if (start >= end) continue;

      final isMention = mentionRanges.any(
        (range) => start >= range.start && end <= range.end,
      );
      final isComposing =
          !composingRegionOutOfRange &&
          start >= composingStart &&
          end <= composingEnd;

      var segmentStyle = isMention ? mentionStyle : effectiveStyle;
      if (isComposing) {
        segmentStyle = segmentStyle.merge(composingStyle);
      }

      spans.add(TextSpan(text: text.substring(start, end), style: segmentStyle));
    }

    return TextSpan(children: spans, style: effectiveStyle);
  }

  bool _sameMentions(List<Mention> current, List<Mention> next) {
    if (current.length != next.length) {
      return false;
    }

    for (var i = 0; i < current.length; i++) {
      if (current[i] != next[i]) {
        return false;
      }
    }

    return true;
  }
}
