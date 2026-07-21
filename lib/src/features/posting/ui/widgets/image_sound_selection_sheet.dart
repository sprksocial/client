import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_track_list_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/sound_picker_sheet_scaffold.dart';

class ImageSoundSelectionSheet extends StatefulWidget {
  const ImageSoundSelectionSheet({super.key, this.initialSelectedTrack});

  final AudioTrack? initialSelectedTrack;

  @override
  State<ImageSoundSelectionSheet> createState() =>
      _ImageSoundSelectionSheetState();
}

class _ImageSoundSelectionSheetState extends State<ImageSoundSelectionSheet> {
  late final AudioPlayer _audioPlayer;
  AudioTrack? _selectedTrack;
  int _previewRequestId = 0;

  @override
  void initState() {
    super.initState();
    _selectedTrack = widget.initialSelectedTrack;
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  Future<void> _handleTrackSelected(AudioTrack track) async {
    final requestId = ++_previewRequestId;
    setState(() => _selectedTrack = track);

    final audioUrl = track.audio.networkUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      _showAudioError(requestId, track);
      return;
    }

    try {
      await _audioPlayer.stop();
      if (!mounted || requestId != _previewRequestId) return;

      await _audioPlayer.play(
        UrlSource(audioUrl, mimeType: decodeSoundTrackAudioMimeType(track.id)),
      );
    } catch (_) {
      _showAudioError(requestId, track);
    }
  }

  void _showAudioError(int requestId, AudioTrack track) {
    if (!mounted || requestId != _previewRequestId) return;
    setState(() {
      if (_selectedTrack?.id == track.id) {
        _selectedTrack = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).errorLoadingSound)),
    );
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedTrack);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SoundPickerSheetScaffold(
      title: l10n.titleSelectSound,
      onClose: () => Navigator.of(context).pop(),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: AppButton(
            label: l10n.buttonContinue,
            onPressed: _selectedTrack == null ? null : _confirmSelection,
            fullWidth: true,
          ),
        ),
      ),
      child: AudioTrackListSection(
        selectedTrack: _selectedTrack,
        onTrackSelected: _handleTrackSelected,
      ),
    );
  }
}
