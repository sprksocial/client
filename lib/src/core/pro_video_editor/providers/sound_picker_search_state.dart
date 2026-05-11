import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';

part 'sound_picker_search_state.freezed.dart';

@freezed
abstract class SoundPickerSearchState with _$SoundPickerSearchState {
  const factory SoundPickerSearchState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default([]) List<AudioView> audios,
    @Default('') String query,
    String? cursor,
    String? error,
  }) = _SoundPickerSearchState;

  const SoundPickerSearchState._();

  factory SoundPickerSearchState.initial() => const SoundPickerSearchState();

  bool get isSearching => query.isNotEmpty;

  bool get hasMore => cursor != null && cursor!.isNotEmpty;
}
