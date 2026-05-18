import 'package:flutter/material.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

/// A custom styled text field with optional undo functionality.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    required this.hintText,
    super.key,
    this.fillColor,
    this.maxLines = 1,
    this.onUndo,
    this.validator,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.borderRadius,
  });
  final TextEditingController controller;
  final String hintText;
  final Color? fillColor;
  final int maxLines;
  final VoidCallback? onUndo;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: textStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        filled: true,
        fillColor: fillColor ?? colorScheme.surface,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        suffixIcon: onUndo != null
            ? IconButton(
                icon: const Icon(Icons.undo, size: 20),
                onPressed: onUndo,
                tooltip: AppLocalizations.of(context).tooltipRevert,
              )
            : null,
      ),
    );
  }
}
