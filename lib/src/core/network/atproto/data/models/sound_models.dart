import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart';
import 'package:sprk_poptart/so/sprk/sound/defs/audio_details.dart';
import 'package:sprk_poptart/so/sprk/sound/defs/audio_view.dart'
    as sprk_audio_view;
import 'package:sprk_poptart/so/sprk/sound/get_audio_posts/output.dart'
    as sprk_audio_posts;
import 'package:sprk_poptart/so/sprk/sound/get_trending_audios/output.dart'
    as sprk_trending_audios;
import 'package:sprk_poptart/so/sprk/sound/search_audios/output.dart'
    as sprk_search_audios;

typedef AudioView = sprk_audio_view.AudioView;
typedef AudioPostsResponse = sprk_audio_posts.SoundGetAudioPostsOutput;
typedef TrendingAudiosResponse =
    sprk_trending_audios.SoundGetTrendingAudiosOutput;
typedef SearchAudiosResponse = sprk_search_audios.SoundSearchAudiosOutput;

const originalAudioTitle = 'Original Audio';

extension AudioViewRecordParsing on AudioView {
  Object? get localRecord {
    final type = record[r'$type'] as String?;
    final isPlyrTrack =
        type == 'fm.plyr.track' ||
        (type == null && record.containsKey('fileType'));
    final jsonWithType = record.containsKey(r'$type')
        ? record
        : {
            ...record,
            r'$type': isPlyrTrack ? 'fm.plyr.track' : 'so.sprk.sound.audio',
          };

    try {
      if (isPlyrTrack) {
        return PlyrTrackRecord.fromJson(jsonWithType);
      }
      if (jsonWithType[r'$type'] == 'so.sprk.sound.audio') {
        return AudioRecord.fromJson(jsonWithType);
      }
      return Record.fromJson(jsonWithType);
    } catch (_) {
      return null;
    }
  }
}

extension AudioViewDisplayTitle on AudioView {
  String get displayTitle {
    final audioTitle = title?.trim();
    if (audioTitle != null && audioTitle.isNotEmpty) return audioTitle;
    return originalAudioTitle;
  }
}

class VideoUploadResult {
  VideoUploadResult({
    required this.videoBlob,
    this.audioBlob,
    this.audioDetails,
  });

  final Blob videoBlob;
  final Blob? audioBlob;
  final AudioDetails? audioDetails;
}
