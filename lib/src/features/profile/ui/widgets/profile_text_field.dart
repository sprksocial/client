import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

/// A customized text field widget for profile editing
class ProfileTextField extends StatelessWidget {
  /// Initial value of the text field
  final String initialValue;
  
  /// Hint text to display when the field is empty
  final String hintText;
  
  /// Function to call when the text changes
  final Function(String) onChanged;
  
  /// Background color for the field
  final Color bgColor;
  
  /// Number of lines for the text field
  final int maxLines;

  /// Creates a profile text field
  const ProfileTextField({
    super.key,
    required this.initialValue,
    required this.hintText,
    required this.onChanged,
    required this.bgColor,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
} 