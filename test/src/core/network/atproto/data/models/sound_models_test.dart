import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';

void main() {
  group('AudioView', () {
    test('parses Spark audio records', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:test123/so.sprk.sound.audio/spark',
        'cid': 'cid-spark',
        'author': {'did': 'did:plc:test123', 'handle': 'test.sprk.so'},
        'record': {
          r'$type': 'so.sprk.sound.audio',
          'sound': _blobJson(),
          'title': 'Original Sound',
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'title': 'Original Sound',
        'coverArt': 'https://example.com/spark.jpg',
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Atest123/cid',
      });

      expect(audio.localRecord, isA<AudioRecord>());
      expect(audio.title, 'Original Sound');
      expect(audio.displayTitle, 'Original Sound');
    });

    test('uses Original Audio when a Spark audio has no title', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:test123/so.sprk.sound.audio/spark',
        'cid': 'cid-spark',
        'author': {'did': 'did:plc:test123', 'handle': 'test.sprk.so'},
        'record': {
          r'$type': 'so.sprk.sound.audio',
          'sound': _blobJson(),
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'coverArt': 'https://example.com/spark.jpg',
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Atest123/cid',
      });

      final track = audioViewToAudioTrack(audio);

      expect(audio.title, isNull);
      expect(audio.displayTitle, 'Original Audio');
      expect(track?.title, 'Original Audio');
    });

    test('omits track image when a sound has no cover art', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:test123/so.sprk.sound.audio/no-cover',
        'cid': 'cid-spark-no-cover',
        'author': {'did': 'did:plc:test123', 'handle': 'test.sprk.so'},
        'record': {
          r'$type': 'so.sprk.sound.audio',
          'sound': _blobJson(),
          'title': 'No Cover',
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'title': 'No Cover',
        'coverArt': '',
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Atest123/cid',
      });

      final track = audioViewToAudioTrack(audio);

      expect(soundCoverArtUrl(audio), isNull);
      expect(track?.image, isNull);
    });

    test('uses cover art when present', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:test123/so.sprk.sound.audio/with-cover',
        'cid': 'cid-spark-with-cover',
        'author': {'did': 'did:plc:test123', 'handle': 'test.sprk.so'},
        'record': {
          r'$type': 'so.sprk.sound.audio',
          'sound': _blobJson(),
          'title': 'With Cover',
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'title': 'With Cover',
        'coverArt': 'https://example.com/spark.jpg',
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Atest123/cid',
      });

      final track = audioViewToAudioTrack(audio);

      expect(soundCoverArtUrl(audio), 'https://example.com/spark.jpg');
      expect(track?.image?.networkUrl, 'https://example.com/spark.jpg');
    });

    test('parses public Plyr tracks as sounds', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:plyr123/fm.plyr.track/track',
        'cid': 'cid-plyr',
        'author': {'did': 'did:plc:plyr123', 'handle': 'artist.plyr.fm'},
        'record': {
          r'$type': 'fm.plyr.track',
          'title': "Governor's Ball Symphony",
          'artist': 'Dame',
          'fileType': 'mp3',
          'duration': 187,
          'audioUrl': 'https://cdn.plyr.example/audio/governor.mp3',
          'audioBlob': _blobJson(),
          'imageUrl': 'https://example.com/cover.jpg',
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'title': "Governor's Ball Symphony",
        'coverArt': 'https://example.com/cover.jpg',
        'details': {'artist': 'Dame', 'title': "Governor's Ball Symphony"},
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Aplyr123/cid',
      });

      final record = audio.localRecord;
      final track = audioViewToAudioTrack(audio);

      expect(record, isA<PlyrTrackRecord>());
      expect((record as PlyrTrackRecord).artist, 'Dame');
      expect(audio.details?.artist, 'Dame');
      expect(track?.duration, const Duration(seconds: 187));
      expect(
        track?.audio.networkUrl,
        'https://cdn.plyr.example/audio/governor.mp3',
      );
    });

    test('preserves m4a file type when converting Plyr sounds to tracks', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:plyr123/fm.plyr.track/m4a-track',
        'cid': 'cid-m4a',
        'author': {'did': 'did:plc:plyr123', 'handle': 'artist.plyr.fm'},
        'record': {
          r'$type': 'fm.plyr.track',
          'title': 'M4A Track',
          'artist': 'Dame',
          'fileType': 'm4a',
          'audioBlob': _blobJson(mimeType: 'audio/mp4'),
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'title': 'M4A Track',
        'coverArt': 'https://example.com/cover.jpg',
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Aplyr123/cid',
      });

      final track = audioViewToAudioTrack(audio);

      expect(track, isNotNull);
      expect(decodeSoundTrackAudioFileExtension(track!.id), 'm4a');
      expect(decodeSoundTrackAudioMimeType(track.id), 'audio/mp4');
    });

    test('normalizes legacy FLAC MIME types for Plyr playback', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:plyr123/fm.plyr.track/flac-track',
        'cid': 'cid-flac',
        'author': {'did': 'did:plc:plyr123', 'handle': 'artist.plyr.fm'},
        'record': {
          r'$type': 'fm.plyr.track',
          'title': 'FLAC Track',
          'artist': 'Dame',
          'fileType': 'flac',
          'audioUrl': 'https://audio.plyr.fm/audio/track.flac',
          'audioBlob': _blobJson(mimeType: 'audio/x-flac'),
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'title': 'FLAC Track',
        'coverArt': 'https://example.com/cover.jpg',
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Aplyr123/cid',
      });

      final track = audioViewToAudioTrack(audio);

      expect(track, isNotNull);
      expect(track!.audio.networkUrl, 'https://audio.plyr.fm/audio/track.flac');
      expect(decodeSoundTrackAudioFileExtension(track.id), 'flac');
      expect(decodeSoundTrackAudioMimeType(track.id), 'audio/flac');
    });

    test('maps Spark audio/mp4 blobs to m4a tracks', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:test123/so.sprk.sound.audio/m4a-spark',
        'cid': 'cid-spark-m4a',
        'author': {'did': 'did:plc:test123', 'handle': 'test.sprk.so'},
        'record': {
          r'$type': 'so.sprk.sound.audio',
          'sound': _blobJson(mimeType: 'audio/mp4'),
          'title': 'Spark M4A',
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'title': 'Spark M4A',
        'coverArt': 'https://example.com/spark.jpg',
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Atest123/cid',
      });

      final track = audioViewToAudioTrack(audio);

      expect(track, isNotNull);
      expect(decodeSoundTrackAudioFileExtension(track!.id), 'm4a');
      expect(decodeSoundTrackAudioMimeType(track.id), 'audio/mp4');
    });

    test(
      'omits Spark media WAVE sounds because the media CDN rejects them',
      () {
        final audio = AudioView.fromJson({
          'uri': 'at://did:plc:test123/so.sprk.sound.audio/wave-spark',
          'cid': 'cid-spark-wave',
          'author': {'did': 'did:plc:test123', 'handle': 'test.sprk.so'},
          'record': {
            r'$type': 'so.sprk.sound.audio',
            'sound': _blobJson(mimeType: 'audio/vnd.wave'),
            'title': 'Spark WAVE',
            'createdAt': '2026-05-01T12:00:00.000Z',
          },
          'title': 'Spark WAVE',
          'coverArt': 'https://example.com/spark.jpg',
          'indexedAt': '2026-05-01T12:00:00.000Z',
          'audio': 'https://media.sprk.so/sound/did%3Aplc%3Atest123/cid',
        });

        final track = audioViewToAudioTrack(audio);

        expect(track, isNull);
      },
    );

    test('uses direct Plyr audio URLs for WAVE tracks when available', () {
      final audio = AudioView.fromJson({
        'uri': 'at://did:plc:plyr123/fm.plyr.track/wave-track',
        'cid': 'cid-plyr-wave',
        'author': {'did': 'did:plc:plyr123', 'handle': 'artist.plyr.fm'},
        'record': {
          r'$type': 'fm.plyr.track',
          'title': 'Plyr WAVE',
          'artist': 'Dame',
          'fileType': 'wav',
          'audioUrl': 'https://cdn.plyr.example/audio/wave.wav',
          'audioBlob': _blobJson(mimeType: 'audio/vnd.wave'),
          'createdAt': '2026-05-01T12:00:00.000Z',
        },
        'title': 'Plyr WAVE',
        'coverArt': 'https://example.com/cover.jpg',
        'indexedAt': '2026-05-01T12:00:00.000Z',
        'audio': 'https://media.sprk.so/sound/did%3Aplc%3Aplyr123/cid',
      });

      final track = audioViewToAudioTrack(audio);

      expect(track, isNotNull);
      expect(
        track!.audio.networkUrl,
        'https://cdn.plyr.example/audio/wave.wav',
      );
      expect(decodeSoundTrackAudioFileExtension(track.id), 'wav');
      expect(decodeSoundTrackAudioMimeType(track.id), 'audio/wav');
    });
  });
}

Map<String, Object> _blobJson({String mimeType = 'audio/mpeg'}) {
  return {
    r'$type': 'blob',
    'mimeType': mimeType,
    'size': 42,
    'ref': {r'$link': 'bafkreigh2akiscaildc2'},
  };
}
