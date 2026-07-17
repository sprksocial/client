import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_track_list_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/sound_picker_sheet_scaffold.dart';

/// A bottom sheet for selecting an audio track.
class AudioSelectionBottomSheet extends StatefulWidget {
  /// Creates an [AudioSelectionBottomSheet].
  const AudioSelectionBottomSheet({
    required this.configs,
    required this.videoDuration,
    required this.onTrackPlay,
    required this.onTrackStop,
    this.initialSelectedTrack,
    super.key,
  });

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Total duration of the video.
  final Duration videoDuration;

  /// Initial selected track (if any).
  final AudioTrack? initialSelectedTrack;

  /// Called when a track should start playing.
  final Future<void> Function(AudioTrack track) onTrackPlay;

  /// Called when a track should stop playing.
  final Future<void> Function(AudioTrack track) onTrackStop;

  @override
  State<AudioSelectionBottomSheet> createState() =>
      _AudioSelectionBottomSheetState();
}

class _AudioSelectionBottomSheetState extends State<AudioSelectionBottomSheet> {
  AudioTrack? _selectedTrack;
  bool _isConfirmed = false;
  int _trackPreviewRequestId = 0;

  @override
  void initState() {
    super.initState();
    _selectedTrack = widget.initialSelectedTrack;
  }

  @override
  void dispose() {
    if (!_isConfirmed && _selectedTrack != null) {
      unawaited(widget.onTrackStop(_selectedTrack!));
    }
    super.dispose();
  }

  Future<void> _handleTrackSelection(AudioTrack track) async {
    final requestId = ++_trackPreviewRequestId;
    setState(() {
      _selectedTrack = track;
    });
    try {
      await widget.onTrackPlay(track);
      if (!mounted || requestId != _trackPreviewRequestId) return;
    } catch (_) {
      if (!mounted || requestId != _trackPreviewRequestId) return;
      setState(() {
        if (_selectedTrack?.id == track.id) {
          _selectedTrack = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorLoadingSound)),
      );
    }
  }

  void _handleContinue() {
    final selectedTrack = _selectedTrack;
    if (selectedTrack == null) return;
    _isConfirmed = true;
    Navigator.of(context).pop(selectedTrack);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SoundPickerSheetScaffold(
      title: l10n.titleSelectSound,
      onClose: () => Navigator.of(context).pop(),
      footer: _buildContinueButton(),
      child: AudioTrackListSection(
        configs: widget.configs,
        videoDuration: widget.videoDuration,
        selectedTrack: _selectedTrack,
        onTrackSelected: _handleTrackSelection,
      ),
    );
  }

  Widget _buildContinueButton() {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: AppButton(
          label: l10n.buttonContinue,
          onPressed: _selectedTrack == null ? null : _handleContinue,
          fullWidth: true,
        ),
      ),
    );
  }
}
