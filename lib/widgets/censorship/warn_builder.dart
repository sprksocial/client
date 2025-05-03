import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:sparksocial/utils/app_colors.dart';

class WarnBuilder extends StatefulWidget {
  final Widget child;
  final String labelerDid;
  final String labelValue;
  final String? warningMessage;
  final String blurType;
  final String severity;

  const WarnBuilder({
    super.key, 
    required this.child, 
    required this.labelerDid, 
    required this.labelValue,
    this.warningMessage,
    this.blurType = 'content',
    this.severity = 'alert',
  });

  @override
  State<WarnBuilder> createState() => _WarnBuilderState();
}

class _WarnBuilderState extends State<WarnBuilder> {
  bool _showWarning = true;

  @override
  Widget build(BuildContext context) {
    if (!_showWarning) {
      return widget.child;
    }

    final bool shouldApplyBlur = widget.blurType != 'none';
    
    // Define colors and styles based on severity
    final Color borderColor = _getBorderColor();
    final Color iconColor = _getIconColor();
    final IconData warningIcon = _getWarningIcon();
    final String headerText = _getHeaderText();
    final double borderWidth = widget.severity == 'alert' ? 2.0 : 1.0;
    final Color backgroundColor = widget.severity == 'alert' 
        ? Colors.black.withAlpha(100) 
        : Colors.black.withAlpha(80);

    return Stack(
      children: [
        if (shouldApplyBlur)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: widget.child,
              ),
            ),
          )
        else
          Opacity(
            opacity: 0.3,
            child: widget.child,
          ),
        
        // Warning overlay
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(warningIcon, size: 48, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  headerText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.warningMessage ?? 
                  'This content has been marked as ${widget.labelValue}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showWarning = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Show content'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getBorderColor() {
    switch (widget.severity) {
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
  
  Color _getIconColor() {
    switch (widget.severity) {
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
  
  IconData _getWarningIcon() {
    switch (widget.severity) {
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
  
  String _getHeaderText() {
    switch (widget.severity) {
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