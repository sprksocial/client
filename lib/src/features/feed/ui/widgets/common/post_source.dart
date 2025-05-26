import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class PostSource extends StatelessWidget {
  final String username;
  final bool isSprk;

  const PostSource({super.key, required this.username, this.isSprk = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            '@$username',
            style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isSprk || true) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(42),
              boxShadow: [
                BoxShadow(color: AppColors.black.withAlpha(30), blurRadius: 4, spreadRadius: 1, offset: const Offset(0, 0)),
              ],
            ),
            child:
                isSprk
                    ? SvgPicture.asset('assets/images/sprk.svg', width: 14, height: 14)
                    : SvgPicture.asset('assets/images/bsky.svg', width: 14, height: 14),
          ),
        ],
      ],
    );
  }
}
