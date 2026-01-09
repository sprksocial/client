import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';

class SoundHeaderCard extends StatefulWidget {
  const SoundHeaderCard({
    required this.audio,
    required this.onAuthorTap,
    super.key,
  });

  final AudioView audio;
  final VoidCallback onAuthorTap;

  @override
  State<SoundHeaderCard> createState() => _SoundHeaderCardState();
}

class _SoundHeaderCardState extends State<SoundHeaderCard> {
  String _formatUseCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.squircleRadius),
          side: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(25)
                : Colors.black.withAlpha(15),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Art with Play Button
          _CoverArtWithPlayer(
            coverArtUrl: widget.audio.coverArt.toString(),
            audioUrl: widget.audio.audio?.toString(),
          ),
          const SizedBox(width: 16),

          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with music icon
                Row(
                  children: [
                    AppIcons.music(
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.audio.title,
                        style: AppTypography.textLargeBold.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Author
                GestureDetector(
                  onTap: widget.onAuthorTap,
                  child: Text(
                    '@${widget.audio.author.handle}',
                    style: AppTypography.textSmallThin.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 12),

                // Use count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey700 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcons.disk(
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatUseCount(widget.audio.useCount)} videos',
                        style: AppTypography.textExtraSmallMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverArtWithPlayer extends StatefulWidget {
  const _CoverArtWithPlayer({
    required this.coverArtUrl,
    this.audioUrl,
  });

  final String coverArtUrl;
  final String? audioUrl;

  @override
  State<_CoverArtWithPlayer> createState() => _CoverArtWithPlayerState();
}

class _CoverArtWithPlayerState extends State<_CoverArtWithPlayer> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (widget.audioUrl == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position == Duration.zero || _position >= _duration) {
        await _audioPlayer.play(UrlSource(widget.audioUrl!));
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  double get _progress {
    if (_duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasAudio = widget.audioUrl != null;

    return GestureDetector(
      onTap: hasAudio ? _togglePlayPause : null,
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          children: [
            // Cover Art
            Container(
              width: 88,
              height: 88,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppShapes.squircleRadius - 4,
                  ),
                  side: BorderSide(
                    width: 1.5,
                    color: isDark
                        ? Colors.white.withAlpha(40)
                        : Colors.black.withAlpha(20),
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppShapes.squircleRadius - 4,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.coverArtUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ColoredBox(
                    color: AppColors.grey700,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary500,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => ColoredBox(
                    color: AppColors.grey700,
                    child: AppIcons.music(
                      size: 32,
                      color: AppColors.grey400,
                    ),
                  ),
                ),
              ),
            ),

            // Play Button Overlay with Progress Ring
            if (hasAudio)
              Positioned.fill(
                child: Center(
                  child: _PlayButtonWithProgress(
                    isPlaying: _isPlaying,
                    progress: _progress,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayButtonWithProgress extends StatelessWidget {
  const _PlayButtonWithProgress({
    required this.isPlaying,
    required this.progress,
  });

  final bool isPlaying;
  final double progress;

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    const strokeWidth = 3.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with shadow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withAlpha(150),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.white.withAlpha(50),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary500,
              ),
            ),
          ),

          // Play/Pause icon
          Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.greyWhite,
            size: 24,
          ),
        ],
      ),
    );
  }
}
