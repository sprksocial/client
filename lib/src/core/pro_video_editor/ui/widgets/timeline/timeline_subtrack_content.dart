import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

class TimelineSubtrackContent extends StatelessWidget {
  const TimelineSubtrackContent({
    required this.icon,
    required this.label,
    this.leading,
    super.key,
  });

  final IconData icon;
  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          leading ?? Icon(icon, size: 15, color: AppColors.greyWhite),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.greyWhite,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
