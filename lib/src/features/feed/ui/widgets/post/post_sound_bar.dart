import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

class PostSoundBar extends StatelessWidget {
  const PostSoundBar({
    required this.audio,
    super.key,
  });

  final AudioView audio;

  @override
  Widget build(BuildContext context) {
    const textColor = AppColors.greyWhite;
    const albumSize = 48.0;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Music Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 8, right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcons.music(size: 14, color: textColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      audio.title,
                      style: AppTypography.textSmallMedium.copyWith(color: textColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Album Art
          Container(
            width: albumSize,
            height: albumSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: albumSize * 0.6,
                  height: albumSize * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(audio.coverArt.toString()),
                      fit: BoxFit.cover,
                    ),
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
