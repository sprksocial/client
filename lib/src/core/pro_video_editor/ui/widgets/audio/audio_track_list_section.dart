import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_provider.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_state.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/sound_artwork.dart';

/// Displays a scrollable list of audio tracks for selection.
class AudioTrackListSection extends ConsumerStatefulWidget {
  /// Creates an [AudioTrackListSection].
  const AudioTrackListSection({
    required this.configs,
    required this.videoDuration,
    required this.onTrackSelected,
    this.selectedTrack,
    super.key,
  });

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Total duration of the video.
  final Duration videoDuration;

  /// Currently selected track (if any).
  final AudioTrack? selectedTrack;

  /// Called when a track is tapped.
  final void Function(AudioTrack track) onTrackSelected;

  @override
  ConsumerState<AudioTrackListSection> createState() =>
      _AudioTrackListSectionState();
}

class _AudioTrackListSectionState extends ConsumerState<AudioTrackListSection> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 240) {
      return;
    }
    ref.read(soundPickerSearchProvider.notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soundPickerSearchProvider);
    final audioTracks = audioViewsToAudioTracks(state.audios);
    final selectedTrack = widget.selectedTrack;
    final tracks =
        selectedTrack != null &&
            !audioTracks.any((track) => track.id == selectedTrack.id)
        ? [selectedTrack, ...audioTracks]
        : audioTracks;

    return Column(
      children: [
        _buildSearchField(context),
        Expanded(child: _buildTrackList(context, state, tracks)),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.hintSearchSounds,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(soundPickerSearchProvider.notifier)
                        .updateQuery('');
                    setState(() {});
                  },
                ),
        ),
        onChanged: (value) {
          ref.read(soundPickerSearchProvider.notifier).updateQuery(value);
          setState(() {});
        },
        onSubmitted: (value) {
          ref.read(soundPickerSearchProvider.notifier).submitQuery(value);
        },
      ),
    );
  }

  Widget _buildTrackList(
    BuildContext context,
    SoundPickerSearchState state,
    List<AudioTrack> tracks,
  ) {
    if (state.isLoading && tracks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && tracks.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return _buildMessageState(
        context,
        state.isSearching ? l10n.errorSearchingSounds : l10n.errorLoadingSound,
      );
    }
    if (tracks.isEmpty) {
      return _buildMessageState(
        context,
        state.isSearching
            ? AppLocalizations.of(context).emptyNoSoundSearchResults
            : AppLocalizations.of(context).emptyNoSoundsAvailable,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: tracks.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= tracks.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final audioTrack = tracks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AudioTrackSelectionTile(
            configs: widget.configs,
            audioTrack: audioTrack,
            isSelected: audioTrack.id == widget.selectedTrack?.id,
            onTap: () => widget.onTrackSelected(audioTrack),
          ),
        );
      },
    );
  }

  Widget _buildMessageState(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.configs.audioEditor.icons.audioTrackDefaultIcon,
              size: 48,
              color: colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AudioTrackSelectionTile extends StatelessWidget {
  const AudioTrackSelectionTile({
    required this.configs,
    required this.audioTrack,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final ProImageEditorConfigs configs;
  final AudioTrack audioTrack;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageBackground = configs.audioEditor.style.audioTrackImageBackground;
    final borderRadius = BorderRadius.circular(8);
    final backgroundColor = isSelected
        ? AppColors.primary500.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final borderColor = isSelected
        ? AppColors.primary500.withValues(alpha: 0.75)
        : colorScheme.outline.withValues(alpha: 0.45);
    final titleColor = isSelected
        ? AppColors.primary500
        : colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      child: InteractivePressable(
        onTap: onTap,
        pressedScale: 0.98,
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SoundArtwork(
                    imageUrl: audioTrack.image?.networkUrl,
                    size: 50,
                    borderRadius: 8,
                    backgroundColor: imageBackground.withAlpha(80),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audioTrack.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textMediumBold.copyWith(
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          audioTrack.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textSmallMedium.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    audioTrack.formattedDuration,
                    style: AppTypography.textSmallMedium.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
