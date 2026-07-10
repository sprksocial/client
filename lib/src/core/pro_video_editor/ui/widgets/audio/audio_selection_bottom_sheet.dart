import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_edit_controls_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_track_list_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/sound_picker_sheet_scaffold.dart';

/// A bottom sheet for selecting and editing audio tracks.
///
/// This widget provides a two-state interface:
/// 1. Track selection: Displays a list of available audio tracks
/// 2. Edit controls: Shows balance slider, waveform selector, & action buttons
class AudioSelectionBottomSheet extends StatefulWidget {
  /// Creates an [AudioSelectionBottomSheet].
  const AudioSelectionBottomSheet({
    required this.configs,
    required this.videoDuration,
    required this.onTrackSelected,
    required this.onBalanceChanged,
    required this.onTrackChanged,
    required this.onTrackChangeEnd,
    required this.onConfirm,
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

  /// Called when a track is selected.
  final void Function(AudioTrack track) onTrackSelected;

  /// Called when balance slider changes.
  final void Function(double balance) onBalanceChanged;

  /// Called when timing or playback options change for the selected track.
  final ValueChanged<AudioTrack> onTrackChanged;

  /// Called after the user commits a timing or volume interaction.
  final ValueChanged<AudioTrack> onTrackChangeEnd;

  /// Called when user confirms their audio selection.
  final void Function(AudioTrack? track) onConfirm;

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
  bool _showEditControls = false;
  int _trackPreviewRequestId = 0;

  @override
  void initState() {
    super.initState();
    _selectedTrack = widget.initialSelectedTrack;
    _showEditControls = _selectedTrack != null;
  }

  @override
  void dispose() {
    if (_selectedTrack != null) {
      widget.onTrackStop(_selectedTrack!);
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

    setState(() {
      _showEditControls = true;
    });
    widget.onTrackSelected(selectedTrack);
  }

  void _handleChangeTrack() {
    if (_selectedTrack != null) {
      widget.onTrackStop(_selectedTrack!);
    }
    setState(() {
      _showEditControls = false;
    });
  }

  void _handleConfirm() {
    widget.onConfirm(_selectedTrack);
    Navigator.of(context).pop(_selectedTrack);
  }

  void _handleBalanceChange(double balance) {
    final track = _selectedTrack;
    if (track == null) return;
    _handleTrackChange(track.copyWith(volumeBalance: balance));
    widget.onBalanceChanged(balance);
  }

  void _handleTrackChange(AudioTrack track) {
    setState(() => _selectedTrack = track);
    widget.onTrackChanged(track);
  }

  void _handleTrackChangeEnd(AudioTrack track) {
    widget.onTrackChangeEnd(track);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = widget.configs.i18n.audioEditor;
    final l10n = AppLocalizations.of(context);

    return SoundPickerSheetScaffold(
      title: _showEditControls ? i18n.editTrack : l10n.titleSelectSound,
      onClose: _showEditControls ? null : () => Navigator.of(context).pop(),
      footer: _showEditControls ? null : _buildContinueButton(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _showEditControls && _selectedTrack != null
            ? AudioEditControlsSection(
                key: const ValueKey('edit_controls'),
                configs: widget.configs,
                audioTrack: _selectedTrack!,
                videoDuration: widget.videoDuration,
                onBalanceChanged: _handleBalanceChange,
                onTrackChanged: _handleTrackChange,
                onTrackChangeEnd: _handleTrackChangeEnd,
                onChangeTrack: _handleChangeTrack,
                onConfirm: _handleConfirm,
              )
            : AudioTrackListSection(
                key: const ValueKey('track_list'),
                configs: widget.configs,
                videoDuration: widget.videoDuration,
                selectedTrack: _selectedTrack,
                onTrackSelected: _handleTrackSelection,
              ),
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
