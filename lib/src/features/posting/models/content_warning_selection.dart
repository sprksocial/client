import 'package:poptart_lex/com/atproto/label/defs.dart';

enum AdultContentWarning { sexual, nudity, porn }

class ContentWarningSelection {
  const ContentWarningSelection({this.adult, this.graphicMedia = false});

  final AdultContentWarning? adult;
  final bool graphicMedia;

  ContentWarningSelection copyWith({
    AdultContentWarning? adult,
    bool clearAdult = false,
    bool? graphicMedia,
  }) {
    return ContentWarningSelection(
      adult: clearAdult ? null : adult ?? this.adult,
      graphicMedia: graphicMedia ?? this.graphicMedia,
    );
  }

  List<SelfLabel> get selfLabels => [
    if (adult case final value?) SelfLabel(val: value.name),
    if (graphicMedia) const SelfLabel(val: 'graphic-media'),
  ];

  List<String> get values => selfLabels.map((label) => label.val).toList();
}
