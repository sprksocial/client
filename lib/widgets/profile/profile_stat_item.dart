import 'package:flutter/cupertino.dart';
import '../../utils/app_theme.dart';

class ProfileStatItem extends StatelessWidget {
  final String count;
  final String label;

  const ProfileStatItem({
    super.key,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppTheme.getTextColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}