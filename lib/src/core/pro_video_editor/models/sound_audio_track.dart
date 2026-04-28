import 'dart:convert';

import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto/core.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';

const _fallbackAudioDuration = Duration(seconds: 9);

AudioTrack? audioViewToAudioTrack(AudioView audio) {
  final audioUrl = audio.audio?.toString();
  if (audioUrl == null || audioUrl.isEmpty) return null;

  return AudioTrack(
    id: encodeSoundTrackId(
      audio.uri.toString(),
      audio.cid,
      authorAvatar: audio.author.avatar?.toString(),
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

String encodeSoundTrackId(String uri, String cid, {String? authorAvatar}) {
  return jsonEncode({'uri': uri, 'cid': cid, 'authorAvatar': authorAvatar});
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
