import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_controller.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_track_list_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/sound_picker_sheet_scaffold.dart';

Future<void> showAudioSelectionFlow({
  required BuildContext context,
  required ProImageEditorConfigs configs,
  required Duration videoDuration,
  required AudioTrack? initialTrack,
  required TrimDurationSpan editorSpan,
  required AudioAuditionController audition,
  required bool Function() isCurrent,
  required AudioAuditionErrorHandler onError,
}) async {
  try {
    if (!context.mounted || !isCurrent()) return;
    audition.beginPicker(previousTrack: initialTrack, editorSpan: editorSpan);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: AudioSelectionBottomSheet(
          configs: configs,
          videoDuration: videoDuration,
          audition: audition,
        ),
      ),
    );
    if (!isCurrent()) return;
    if (confirmed ?? false) {
      audition.confirmPicker();
    } else {
      await audition.cancel();
    }
  } catch (error, stackTrace) {
    onError('Failed to complete the sound picker workflow', error, stackTrace);
    if (isCurrent()) await audition.cancel();
  }
}

class AudioSelectionBottomSheet extends StatelessWidget {
  const AudioSelectionBottomSheet({
    required this.configs,
    required this.videoDuration,
    required this.audition,
    super.key,
  });

  final ProImageEditorConfigs configs;
  final Duration videoDuration;
  final AudioAuditionController audition;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audition,
      builder: (context, _) {
        final state = audition.state;
        if (state is! AudioPickerAuditionState) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context);
        return SoundPickerSheetScaffold(
          title: l10n.titleSelectSound,
          onClose: () => Navigator.of(context).pop(false),
          footer: _ContinueButton(
            enabled: state.canContinue,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          child: AudioTrackListSection(
            configs: configs,
            videoDuration: videoDuration,
            selectedTrack: state.selectedTrack,
            onTrackSelected: (track) => _selectTrack(context, track),
          ),
        );
      },
    );
  }

  Future<void> _selectTrack(BuildContext context, AudioTrack track) async {
    final succeeded = await audition.selectPickerTrack(track);
    if (!context.mounted || succeeded) return;
    final state = audition.state;
    if (state is AudioPickerAuditionState &&
        state.previewStatus == AudioPickerPreviewStatus.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorLoadingSound)),
      );
    }
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: AppButton(
          label: AppLocalizations.of(context).buttonContinue,
          onPressed: enabled ? onPressed : null,
          fullWidth: true,
        ),
      ),
    );
  }
}
