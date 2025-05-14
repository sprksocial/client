import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/label_models.dart';

part 'labeler.freezed.dart';
part 'labeler.g.dart';

@freezed
class Labeler with _$Labeler {
  const factory Labeler({
    required String did,
    String? displayName,
    String? description,
    String? avatar,
    @Default({}) Map<String, LabelValue> labelDefinitions,
  }) = _Labeler;

  factory Labeler.fromJson(Map<String, dynamic> json) => 
      _$LabelerFromJson(json);
      
  factory Labeler.fromLabelInfo(LabelInfo info) => Labeler(
    did: info.did,
    displayName: info.displayName,
    description: info.description,
    avatar: info.avatar,
  );
} 