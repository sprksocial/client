import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';

part 'labeler_models.freezed.dart';
part 'labeler_models.g.dart';

@freezed
abstract class LabelerView with _$LabelerView {
  factory LabelerView({
    @AtUriConverter() required AtUri uri,
    required CID cid,
    required ProfileView creator,
    required DateTime indexedAt,
    int? likeCount,
    int? lookCount,
    LabelerViewerState? labelerViewer,
    List<Label>? labels,
  }) = _LabelerView;

  factory LabelerView.fromJson(Map<String, dynamic> json) => _$LabelerViewFromJson(json);
}

@freezed
abstract class LabelerViewDetailed with _$LabelerViewDetailed {
  factory LabelerViewDetailed({
    @AtUriConverter() required AtUri uri,
    required CID cid,
    required ProfileView creator,
    required DateTime indexedAt,
    int? likeCount,
    int? lookCount,
    LabelerViewerState? labelerViewer,
    LabelerPolicies? policies,
    List<Label>? labels,
  }) = _LabelerViewDetailed;

  factory LabelerViewDetailed.fromJson(Map<String, dynamic> json) => _$LabelerViewDetailedFromJson(json);
}

@freezed
abstract class LabelerViewerState with _$LabelerViewerState {
  factory LabelerViewerState({@AtUriConverter() required AtUri like, @AtUriConverter() required AtUri look}) =
      _LabelerViewerState;

  factory LabelerViewerState.fromJson(Map<String, dynamic> json) => _$LabelerViewerStateFromJson(json);
}

@freezed
abstract class LabelerPolicies with _$LabelerPolicies {
  factory LabelerPolicies({
    required List<LabelValue> labelValues,
    List<LabelValueDefinition>? labelValueDefinitions,
  }) = _LabelerPolicies;

  factory LabelerPolicies.fromJson(Map<String, dynamic> json) => _$LabelerPoliciesFromJson(json);
}
