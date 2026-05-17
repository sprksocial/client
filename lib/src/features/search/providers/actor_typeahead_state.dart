import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

part 'actor_typeahead_state.freezed.dart';

@freezed
abstract class ActorTypeaheadState with _$ActorTypeaheadState {
  const factory ActorTypeaheadState({
    @Default(false) bool isLoading,
    @Default([]) List<ProfileViewBasic> results,
    @Default('') String query,
    String? error,
  }) = _ActorTypeaheadState;

  factory ActorTypeaheadState.initial() => const ActorTypeaheadState();
}
