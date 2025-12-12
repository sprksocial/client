import 'package:flutter/material.dart';
import 'package:pro_image_editor/features/audio_editor/widgets/audio_main_bottom_bar.dart';
import 'package:pro_image_editor/features/audio_editor/widgets/audio_waveform_selector.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A custom edit sheet widget for the audio editor.
///
/// Provides controls for balance slider, start time selector, and action buttons.
class AudioEditorEditSheet extends StatefulWidget {
  /// Creates a [AudioEditorEditSheet].
  const AudioEditorEditSheet({
    required this.configs,
    required this.editorState,
    required this.controller,
    required this.updateStartTime,
    required this.updateBalance,
    required this.openSelectTrack,
    required this.confirm,
    super.key,
  });

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// The audio main bottom bar state.
  final AudioMainBottomBarState editorState;

  /// The video controller.
  final ProVideoController controller;

  /// Callback to update start time.
  final ValueChanged<Duration> updateStartTime;

  /// Callback to update balance.
  final ValueChanged<double> updateBalance;

  /// Callback to open track selection.
  final VoidCallback openSelectTrack;

  /// Callback to confirm changes.
  final VoidCallback confirm;

  @override
  State<AudioEditorEditSheet> createState() => _AudioEditorEditSheetState();
}

class _AudioEditorEditSheetState extends State<AudioEditorEditSheet> {
  final double _balanced = 0.05;

  late final AudioEditorConfigs _configs;
  late final I18nAudioEditor _i18n;
  late final AudioEditorStyle _style;
  late final AudioTrack _audioTrack;

  String get _balanceLabel {
    if (_audioTrack.volumeBalance < -_balanced) {
      return _i18n.balanceLabelOriginal;
    } else if (_audioTrack.volumeBalance > _balanced) {
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
    _audioTrack = widget.controller.audioTrack!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _style.editSheetBackgroundColor,
        boxShadow:
            _style.editSheetShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_configs.enableEditBalance) ...[
            _buildBalanceSlider(),
            const SizedBox(height: 16),
          ],
          if (_configs.enableEditStartTime) ...[
            _buildStartTimeSelector(),
            const SizedBox(height: 32),
          ],
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBalanceSlider() {
    final balanceSliderBackground = _style.balanceSliderBackground;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        padding: EdgeInsets.zero,
        activeTrackColor: balanceSliderBackground,
        inactiveTrackColor: balanceSliderBackground.withValues(alpha: 0.3),
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
        builder: (_, setState) {
          return Slider(
            value: _audioTrack.volumeBalance,
            min: -1,
            label: _balanceLabel,
            onChanged: (value) {
              widget.updateBalance(value);
              setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget _buildStartTimeSelector() {
    return AudioWaveformSelector(
      configs: widget.configs,
      audioTrack: widget.controller.audioTrack!,
      videoDuration: widget.controller.videoDuration,
      onStartTimeChanged: widget.updateStartTime,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.openSelectTrack,
            icon: const Icon(Icons.music_note),
            label: Text(_i18n.editTrack),
            style: OutlinedButton.styleFrom(
              foregroundColor: _style.buttonEditTrackColor,
              side: BorderSide(color: _style.buttonEditTrackColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
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
            onPressed: widget.confirm,
            icon: const Icon(Icons.check),
            label: Text(_i18n.confirmChanges),
            style: ElevatedButton.styleFrom(
              backgroundColor: _style.buttonConfirmBackground,
              foregroundColor: _style.buttonConfirmColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
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
