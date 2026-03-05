import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_waveform_selector.dart';

/// Displays edit controls for the selected audio track.
///
/// Includes balance slider, waveform selector, and action buttons.
class AudioEditControlsSection extends StatefulWidget {
  /// Creates an [AudioEditControlsSection].
  const AudioEditControlsSection({
    required this.configs,
    required this.audioTrack,
    required this.videoDuration,
    required this.onBalanceChanged,
    required this.onStartTimeChanged,
    required this.onChangeTrack,
    required this.onConfirm,
    super.key,
  });

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// The selected audio track to edit.
  final AudioTrack audioTrack;

  /// Total duration of the video.
  final Duration videoDuration;

  /// Called when balance slider changes.
  final void Function(double balance) onBalanceChanged;

  /// Called when start time changes in waveform selector.
  final void Function(Duration startTime) onStartTimeChanged;

  /// Called when user wants to change the track.
  final VoidCallback onChangeTrack;

  /// Called when user confirms their changes.
  final VoidCallback onConfirm;

  @override
  State<AudioEditControlsSection> createState() =>
      _AudioEditControlsSectionState();
}

class _AudioEditControlsSectionState extends State<AudioEditControlsSection> {
  late AudioEditorConfigs _configs;
  late I18nAudioEditor _i18n;
  late AudioEditorStyle _style;
  final double _balanced = 0.05;

  String get _balanceLabel {
    if (widget.audioTrack.volumeBalance < -_balanced) {
      return _i18n.balanceLabelOriginal;
    } else if (widget.audioTrack.volumeBalance > _balanced) {
      return _i18n.balanceLabelOverlay;
    } else {
      return _i18n.balanceLabelBalanced;
    }
  }

  @override
  void initState() {
    super.initState();
    _configs = widget.configs.audioEditor;
    _i18n = widget.configs.i18n.audioEditor;
    _style = _configs.style;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTrackInfo(),
          const SizedBox(height: 24),
          if (_configs.enableEditBalance) ...[
            _buildBalanceSlider(),
            const SizedBox(height: 24),
          ],
          if (_configs.enableEditStartTime) ...[
            _buildStartTimeSelector(),
            const SizedBox(height: 32),
          ],
          _buildActionButtons(),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildTrackInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (widget.audioTrack.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 48,
                color: _style.audioTrackImageBackground,
                child: widget.audioTrack.image != null
                    ? Image.network(
                        widget.audioTrack.image!.networkUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildDefaultIcon(),
                      )
                    : _buildDefaultIcon(),
              ),
            )
          else
            _buildDefaultIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.audioTrack.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.audioTrack.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(179),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon() {
    final color = _style.audioTrackImageBackground;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _configs.icons.audioTrackDefaultIcon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildBalanceSlider() {
    final balanceSliderBackground = _style.balanceSliderBackground;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Balance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            padding: EdgeInsets.zero,
            activeTrackColor: balanceSliderBackground,
            inactiveTrackColor: balanceSliderBackground.withAlpha(77),
            thumbColor: balanceSliderBackground,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 4,
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: balanceSliderBackground,
            valueIndicatorTextStyle: TextStyle(
              color: _style.balanceSliderColor,
              fontWeight: FontWeight.w500,
            ),
            showValueIndicator: ShowValueIndicator.onlyForContinuous,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Slider(
                value: widget.audioTrack.volumeBalance,
                min: -1,
                label: _balanceLabel,
                onChanged: (value) {
                  widget.onBalanceChanged(value);
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStartTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        AudioWaveformSelector(
          configs: widget.configs,
          audioTrack: widget.audioTrack,
          videoDuration: widget.videoDuration,
          onStartTimeChanged: widget.onStartTimeChanged,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onChangeTrack,
            icon: const Icon(Icons.music_note),
            label: Text(_i18n.editTrack),
            style: OutlinedButton.styleFrom(
              foregroundColor: _style.buttonEditTrackColor,
              side: BorderSide(color: _style.buttonEditTrackColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  _style.buttonEditTrackBorderRadius,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onConfirm,
            icon: const Icon(Icons.check),
            label: Text(_i18n.confirmChanges),
            style: ElevatedButton.styleFrom(
              backgroundColor: _style.buttonConfirmBackground,
              foregroundColor: _style.buttonConfirmColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  _style.buttonConfirmBorderRadius,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
