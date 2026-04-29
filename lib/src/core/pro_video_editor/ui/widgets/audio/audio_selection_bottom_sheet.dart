import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_edit_controls_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_track_list_section.dart';

/// A bottom sheet for selecting and editing audio tracks.
///
/// This widget provides a two-state interface:
/// 1. Track selection: Displays a list of available audio tracks
/// 2. Edit controls: Shows balance slider, waveform selector, & action buttons
class AudioSelectionBottomSheet extends StatefulWidget {
  /// Creates an [AudioSelectionBottomSheet].
  const AudioSelectionBottomSheet({
    required this.configs,
    required this.audioTracks,
    required this.videoDuration,
    required this.onTrackSelected,
    required this.onBalanceChanged,
    required this.onStartTimeChanged,
    required this.onConfirm,
    required this.onTrackPlay,
    required this.onTrackStop,
    this.initialSelectedTrack,
    super.key,
  });

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Available audio tracks to choose from.
  final List<AudioTrack> audioTracks;

  /// Total duration of the video.
  final Duration videoDuration;

  /// Initial selected track (if any).
  final AudioTrack? initialSelectedTrack;

  /// Called when a track is selected.
  final void Function(AudioTrack track) onTrackSelected;

  /// Called when balance slider changes.
  final void Function(double balance) onBalanceChanged;

  /// Called when start time changes in waveform selector.
  final void Function(Duration startTime) onStartTimeChanged;

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

  void _handleTrackSelection(AudioTrack track) {
    setState(() {
      _selectedTrack = track;
    });
    widget.onTrackPlay(track);
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
    if (_selectedTrack != null) {
      _selectedTrack!.volumeBalance = balance;
      widget.onBalanceChanged(balance);
    }
  }

  void _handleStartTimeChange(Duration startTime) {
    if (_selectedTrack != null) {
      _selectedTrack!.startTime = startTime;
      widget.onStartTimeChanged(startTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          _buildHeader(),
          Flexible(
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
                      onStartTimeChanged: _handleStartTimeChange,
                      onChangeTrack: _handleChangeTrack,
                      onConfirm: _handleConfirm,
                    )
                  : AudioTrackListSection(
                      key: const ValueKey('track_list'),
                      configs: widget.configs,
                      audioTracks: widget.audioTracks,
                      videoDuration: widget.videoDuration,
                      selectedTrack: _selectedTrack,
                      onTrackSelected: _handleTrackSelection,
                    ),
            ),
          ),
          if (!_showEditControls) _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    final i18n = widget.configs.i18n.audioEditor;
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _showEditControls ? i18n.editTrack : l10n.titleSelectSound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (!_showEditControls)
            IconButton(
              icon: Icon(Icons.close, color: colorScheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedTrack == null ? null : _handleContinue,
            child: Text(l10n.buttonContinue),
          ),
        ),
      ),
    );
  }
}
