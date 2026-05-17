import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:sprk_poptart/so/sprk/sound/defs/audio_view.dart'
    show $AudioViewCopyWith;

part 'sound_page_state.freezed.dart';

@freezed
abstract class SoundPageState with _$SoundPageState {
  const factory SoundPageState({
    required AudioView audio,
    required List<PostView> posts,
    required bool isEndOfNetwork,
    String? cursor,
  }) = _SoundPageState;
  const SoundPageState._();

  static const int fetchLimit = 30;
}
