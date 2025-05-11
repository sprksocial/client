import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class ContentWarningStyle {
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final String headerText;
  final Color backgroundColor;
  final double borderWidth;

  ContentWarningStyle({
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.headerText,
    required this.backgroundColor,
    required this.borderWidth,
  });

  factory ContentWarningStyle.fromSeverity(String severity) {
    final Color borderColor = _getBorderColor(severity);
    final Color iconColor = _getIconColor(severity);
    final IconData icon = _getWarningIcon(severity);
    final String headerText = _getHeaderText(severity);
    final double borderWidth = severity == 'alert' ? 2.0 : 1.0;
    final Color backgroundColor = severity == 'alert' 
        ? AppColors.black.withAlpha(100) 
        : AppColors.black.withAlpha(80);

    return ContentWarningStyle(
      borderColor: borderColor,
      iconColor: iconColor,
      icon: icon,
      headerText: headerText,
      backgroundColor: backgroundColor,
      borderWidth: borderWidth,
    );
  }

  static Color _getBorderColor(String severity) {
    switch (severity) {
      case 'alert':
        return AppColors.red;
      case 'inform':
        return AppColors.orange;
      case 'none':
        return AppColors.blue;
      default:
        return AppColors.red;
    }
  }
  
  static Color _getIconColor(String severity) {
    switch (severity) {
      case 'alert':
        return AppColors.red;
      case 'inform':
        return AppColors.orange;
      case 'none':
        return AppColors.blue;
      default:
        return AppColors.red;
    }
  }
  
  static IconData _getWarningIcon(String severity) {
    switch (severity) {
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'inform':
        return Icons.info_outline;
      case 'none':
        return Icons.visibility_off;
      default:
        return Icons.warning_amber_rounded;
    }
  }
  
  static String _getHeaderText(String severity) {
    switch (severity) {
      case 'alert':
        return 'Sensitive content';
      case 'inform':
        return 'Content notice';
      case 'none':
        return 'Hidden content';
      default:
        return 'Sensitive content';
    }
  }
} 