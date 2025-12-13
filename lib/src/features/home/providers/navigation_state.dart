import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_state.freezed.dart';

@freezed
abstract class NavigationState with _$NavigationState {
  const factory NavigationState({
    @Default(0) int currentIndex,
  }) = _NavigationState;

  factory NavigationState.initial() => const NavigationState();
}
