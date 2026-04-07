import 'dart:convert';
import 'dart:math' as math;

const _maxBlueskyPostLength = 300;
const _linkSeparator = '\n\n';
const _ellipsis = '...';

class BlueskyCrosspostText {
  const BlueskyCrosspostText({
    required this.text,
    required this.facetTextByteEnd,
    required this.linkByteStart,
  });

  final String text;
  final int facetTextByteEnd;
  final int linkByteStart;
}

BlueskyCrosspostText buildBlueskyCrosspostText({
  required String text,
  required String linkUrl,
}) {
  if (text.isEmpty) {
    return BlueskyCrosspostText(
      text: linkUrl,
      facetTextByteEnd: 0,
      linkByteStart: 0,
    );
  }

  final suffix = '$_linkSeparator$linkUrl';
  final availableTextLength = _maxBlueskyPostLength - suffix.length;
  if (availableTextLength <= 0) {
    return BlueskyCrosspostText(
      text: linkUrl,
      facetTextByteEnd: 0,
      linkByteStart: 0,
    );
  }

  final body = _buildCrosspostBody(text, availableTextLength);
  final bodyText = body.text;
  final linkPrefix = '$bodyText$_linkSeparator';

  return BlueskyCrosspostText(
    text: '$linkPrefix$linkUrl',
    facetTextByteEnd: body.facetTextByteEnd,
    linkByteStart: utf8.encode(linkPrefix).length,
  );
}

({String text, int facetTextByteEnd}) _buildCrosspostBody(
  String text,
  int maxLength,
) {
  if (text.length <= maxLength) {
    return (text: text, facetTextByteEnd: utf8.encode(text).length);
  }

  if (maxLength <= _ellipsis.length) {
    return (text: _ellipsis.substring(0, maxLength), facetTextByteEnd: 0);
  }

  final croppedTextLength = math.max(0, maxLength - _ellipsis.length);
  final croppedText = text.substring(0, croppedTextLength);
  return (
    text: '$croppedText$_ellipsis',
    facetTextByteEnd: utf8.encode(croppedText).length,
  );
}
