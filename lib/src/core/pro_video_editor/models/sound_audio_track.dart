import 'dart:convert';

import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';

const _fallbackAudioDuration = Duration(seconds: 9);
const _fallbackAudioFileExtension = 'mp3';

AudioTrack? audioViewToAudioTrack(AudioView audio) {
  final audioUrl = audio.audio?.toString();
  if (audioUrl == null || audioUrl.isEmpty) return null;

  return AudioTrack(
    id: encodeSoundTrackId(
      audio.uri.toString(),
      audio.cid,
      authorAvatar: audio.author.avatar?.toString(),
      audioFileExtension: audioFileExtension(audio),
      audioMimeType: audioMimeType(audio),
    ),
    title: audio.title,
    subtitle: audio.author.handle,
    duration: _fallbackAudioDuration,
    image: EditorImage(networkUrl: audio.coverArt.toString()),
    audio: EditorAudio(networkUrl: audioUrl),
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
    return _normalizeAudioFileExtension(map['audioFileExtension'] as String?);
  } catch (_) {
    return _fallbackAudioFileExtension;
  }
}

String decodeSoundTrackAudioMimeType(String? encoded) {
  if (encoded == null) return 'audio/mpeg';
  try {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return _normalizeAudioMimeType(
      map['audioMimeType'] as String?,
      extension: map['audioFileExtension'] as String?,
    );
  } catch (_) {
    return 'audio/mpeg';
  }
}

String audioFileExtension(AudioView audio) {
  final record = audio.record;
  if (record is PlyrTrackRecord) {
    return _normalizeAudioFileExtension(
      record.fileType,
      mimeType: record.audioBlob?.mimeType,
    );
  }
  if (record is AudioRecord) {
    return _normalizeAudioFileExtension(null, mimeType: record.sound.mimeType);
  }
  return _fallbackAudioFileExtension;
}

String audioMimeType(AudioView audio) {
  final record = audio.record;
  if (record is PlyrTrackRecord) {
    return _normalizeAudioMimeType(
      record.audioBlob?.mimeType,
      extension: record.fileType,
    );
  }
  if (record is AudioRecord) {
    return _normalizeAudioMimeType(record.sound.mimeType);
  }
  return 'audio/mpeg';
}

String _normalizeAudioFileExtension(String? value, {String? mimeType}) {
  final extension = value?.trim().toLowerCase().replaceFirst('.', '');
  if (extension != null && extension.isNotEmpty) {
    final normalized = switch (extension) {
      'mpeg' => 'mp3',
      'mp4' => 'm4a',
      'x-m4a' => 'm4a',
      'x-wav' => 'wav',
      _ => extension.replaceAll(RegExp(r'[^a-z0-9]'), ''),
    };
    if (normalized.isNotEmpty) return normalized;
  }

  final subtype = mimeType?.split('/').last.trim().toLowerCase();
  return switch (subtype) {
    'mpeg' => 'mp3',
    'mp3' => 'mp3',
    'mp4' => 'm4a',
    'm4a' => 'm4a',
    'x-m4a' => 'm4a',
    'aac' => 'aac',
    'wav' => 'wav',
    'x-wav' => 'wav',
    'flac' => 'flac',
    'ogg' => 'ogg',
    _ => _fallbackAudioFileExtension,
  };
}

String _normalizeAudioMimeType(String? mimeType, {String? extension}) {
  final normalizedMime = mimeType?.trim().toLowerCase();
  if (normalizedMime != null && normalizedMime.startsWith('audio/')) {
    return switch (normalizedMime) {
      'audio/x-m4a' => 'audio/mp4',
      _ => normalizedMime,
    };
  }

  return switch (_normalizeAudioFileExtension(extension)) {
    'm4a' => 'audio/mp4',
    'aac' => 'audio/aac',
    'wav' => 'audio/wav',
    'flac' => 'audio/flac',
    'ogg' => 'audio/ogg',
    _ => 'audio/mpeg',
  };
}
