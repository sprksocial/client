import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';

class AltTextEditorDialog extends StatefulWidget {
  const AltTextEditorDialog({
    required this.initialAltText,
    this.imageFile,
    super.key,
  });
  final String? imageFile;
  final String initialAltText;

  @override
  State<AltTextEditorDialog> createState() => _AltTextEditorDialogState();
}

class _AltTextEditorDialogState extends State<AltTextEditorDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAltText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.nearBlack : Colors.white;
    final textColor = isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final inputBackgroundColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade200;
    final borderColor = isDarkMode
        ? AppColors.deepPurple
        : AppColors.lightLavender;
    final textLength = _controller.text.runes.length;

    return Dialog(
      backgroundColor: backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.imageFile == null
                    ? const SizedBox.shrink()
                    : Image.file(
                        File(widget.imageFile!),
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: inputBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _controller,
                  maxLength: 1000,
                  maxLines: 4,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.hintAddAltText,
                    hintStyle: TextStyle(color: textColor.withAlpha(100)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$textLength/1000',
                  style: TextStyle(
                    color: textColor.withAlpha(130),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.router.maybePop(_controller.text),
                    child: Text(AppLocalizations.of(context).buttonCancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.router.maybePop(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context).buttonSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
