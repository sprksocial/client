import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class ProfileActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isOutlined;

  const ProfileActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.isOutlined = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: 36,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isPrimary 
              ? AppColors.primary 
              : isDarkMode ? AppColors.modalBackground : AppColors.lightLavender,
          border: isOutlined 
              ? Border.all(
                  color: isDarkMode ? Colors.grey.withOpacity(0.5) : Colors.grey.withOpacity(0.2), 
                  width: 1
                ) 
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: isPrimary ? AppColors.white : AppTheme.getTextColor(context)),
                const SizedBox(width: 2),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isPrimary ? AppColors.white : AppTheme.getTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
