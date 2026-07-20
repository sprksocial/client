import 'dart:convert';

import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';

const _fallbackAudioDuration = Duration(seconds: 9);
const _fallbackAudioFileExtension = 'mp3';

AudioTrack? audioViewToAudioTrack(AudioView audio) {
  final audioUrl = playableAudioUrl(audio);
  if (audioUrl == null || audioUrl.isEmpty) return null;
  final coverArtUrl = soundCoverArtUrl(audio);

  return AudioTrack(
    id: encodeSoundTrackId(
      audio.uri.toString(),
      audio.cid,
      authorAvatar: audio.author.avatar?.toString(),
      audioFileExtension: audioFileExtension(audio),
      audioMimeType: audioMimeType(audio),
    ),
    title: audio.displayTitle,
    subtitle: audio.author.handle,
    duration: audioDuration(audio),
    image: coverArtUrl != null ? EditorImage(networkUrl: coverArtUrl) : null,
    audio: EditorAudio(networkUrl: audioUrl),
    loop: true,
  );
}

List<AudioTrack> audioViewsToAudioTracks(Iterable<AudioView> audios) {
  return audios.map(audioViewToAudioTrack).nonNulls.toList();
}

String encodeSoundTrackId(
  String uri,
  String cid, {
  String? authorAvatar,
  String? audioFileExtension,
  String? audioMimeType,
}) {
  return jsonEncode({
    'uri': uri,
    'cid': cid,
    'authorAvatar': authorAvatar,
    'audioFileExtension': audioFileExtension,
    'audioMimeType': audioMimeType,
  });
}

RepoStrongRef? decodeSoundTrackStrongRef(String? encoded) {
  if (encoded == null) return null;
  try {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return RepoStrongRef(
      uri: AtUri.parse(map['uri'] as String),
      cid: map['cid'] as String,
    );
  } catch (_) {
    return null;
  }
}

String? decodeSoundTrackAuthorAvatar(String? encoded) {
  if (encoded == null) return null;
  try {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return map['authorAvatar'] as String?;
  } catch (_) {
    return null;
  }
}

String decodeSoundTrackAudioFileExtension(String? encoded) {
  if (encoded == null) return _fallbackAudioFileExtension;
  try {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return _resolveAudioFormat(
      extension: map['audioFileExtension'] as String?,
      mimeType: map['audioMimeType'] as String?,
    ).extension;
  } catch (_) {
    return _fallbackAudioFileExtension;
  }
}

String decodeSoundTrackAudioMimeType(String? encoded) {
  if (encoded == null) return 'audio/mpeg';
  try {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return _resolveAudioFormat(
      extension: map['audioFileExtension'] as String?,
      mimeType: map['audioMimeType'] as String?,
    ).mimeType;
  } catch (_) {
    return 'audio/mpeg';
  }
}

String audioFileExtension(AudioView audio) {
  final record = audio.localRecord;
  if (record is PlyrTrackRecord) {
    return _resolveAudioFormat(
      extension: record.fileType,
      mimeType: record.audioBlob?.mimeType,
    ).extension;
  }
  if (record is AudioRecord) {
    return _resolveAudioFormat(mimeType: record.sound.mimeType).extension;
  }
  return _fallbackAudioFileExtension;
}

String audioMimeType(AudioView audio) {
  final record = audio.localRecord;
  if (record is PlyrTrackRecord) {
    return _resolveAudioFormat(
      extension: record.fileType,
      mimeType: record.audioBlob?.mimeType,
    ).mimeType;
  }
  if (record is AudioRecord) {
    return _resolveAudioFormat(mimeType: record.sound.mimeType).mimeType;
  }
  return 'audio/mpeg';
}

String? playableAudioUrl(AudioView audio) {
  final record = audio.localRecord;
  final mimeType = audioMimeType(audio);
  final appViewAudioUrl = audio.audio;

  if (record is PlyrTrackRecord) {
    final directAudioUrl = record.audioUrl;
    if (directAudioUrl != null && directAudioUrl.isNotEmpty) {
      return directAudioUrl;
    }
  }

  if (mimeType == 'audio/wav' &&
      appViewAudioUrl != null &&
      _isSparkMediaSoundUrl(appViewAudioUrl)) {
    return null;
  }

  return appViewAudioUrl;
}

Duration audioDuration(AudioView audio) {
  final record = audio.localRecord;
  if (record is PlyrTrackRecord) {
    final durationSeconds = record.duration;
    if (durationSeconds != null && durationSeconds > 0) {
      return Duration(seconds: durationSeconds);
    }
  }
  return _fallbackAudioDuration;
}

String? soundCoverArtUrl(AudioView audio) {
  final coverArtUrl = audio.coverArt.toString().trim();
  if (coverArtUrl.isEmpty || coverArtUrl == 'null') {
    return null;
  }
  return coverArtUrl;
}

bool _isSparkMediaSoundUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return uri.host == 'media.sprk.so' &&
      uri.pathSegments.isNotEmpty &&
      uri.pathSegments.first == 'sound';
}

_AudioFormat _resolveAudioFormat({String? extension, String? mimeType}) {
  final normalizedMime = mimeType?.trim().toLowerCase();
  final mimeFormat = switch (normalizedMime) {
    'audio/mpeg' || 'audio/mp3' => const _AudioFormat('mp3', 'audio/mpeg'),
    'audio/mp4' ||
    'audio/m4a' ||
    'audio/x-m4a' => const _AudioFormat('m4a', 'audio/mp4'),
    'audio/aac' => const _AudioFormat('aac', 'audio/aac'),
    'audio/vnd.wave' ||
    'audio/wave' ||
    'audio/wav' ||
    'audio/x-wav' => const _AudioFormat('wav', 'audio/wav'),
    'audio/flac' || 'audio/x-flac' => const _AudioFormat('flac', 'audio/flac'),
    'audio/ogg' => const _AudioFormat('ogg', 'audio/ogg'),
    _ => null,
  };
  if (mimeFormat != null) return mimeFormat;

  final normalizedExtension = extension
      ?.trim()
      .toLowerCase()
      .replaceFirst('.', '')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
  final extensionFormat = switch (normalizedExtension) {
    'mpeg' || 'mp3' => const _AudioFormat('mp3', 'audio/mpeg'),
    'mp4' || 'm4a' || 'xm4a' => const _AudioFormat('m4a', 'audio/mp4'),
    'aac' => const _AudioFormat('aac', 'audio/aac'),
    'vndwave' ||
    'wave' ||
    'wav' ||
    'xwav' => const _AudioFormat('wav', 'audio/wav'),
    'flac' || 'xflac' => const _AudioFormat('flac', 'audio/flac'),
    'ogg' => const _AudioFormat('ogg', 'audio/ogg'),
    _ => null,
  };
  if (extensionFormat != null) return extensionFormat;

  if (normalizedMime != null && normalizedMime.startsWith('audio/')) {
    final subtype = normalizedMime
        .substring('audio/'.length)
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (subtype.isNotEmpty) return _AudioFormat(subtype, normalizedMime);
  }
  if (normalizedExtension != null && normalizedExtension.isNotEmpty) {
    return _AudioFormat(normalizedExtension, 'audio/$normalizedExtension');
  }
  return const _AudioFormat(_fallbackAudioFileExtension, 'audio/mpeg');
}

class _AudioFormat {
  const _AudioFormat(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}
