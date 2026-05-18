import 'package:flutter/material.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/ui/widgets/custom_text_field.dart';

class OnboardingBioStep extends StatefulWidget {
  const OnboardingBioStep({
    this.initialDescription = '',
    this.onUndoDescription,
    super.key,
  });

  final String initialDescription;
  final VoidCallback? onUndoDescription;

  @override
  State<OnboardingBioStep> createState() => OnboardingBioStepState();
}

class OnboardingBioStepState extends State<OnboardingBioStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;

  String get description => _descriptionController.text;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool validate() => _formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final placeholder = widget.initialDescription.trim().isNotEmpty
        ? widget.initialDescription
        : 'This is my bio. There are many like it but this one is mine.';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Form(
        key: _formKey,
        child: CustomTextField(
          controller: _descriptionController,
          hintText: placeholder,
          fillColor:
              theme.inputDecorationTheme.fillColor ?? colorScheme.surface,
          maxLines: 7,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 22,
          ),
          textStyle: theme.textTheme.titleLarge,
          hintStyle: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          borderRadius: 16,
          onUndo: widget.onUndoDescription,
          validator: (value) {
            if (value != null && value.trim().length > 256) {
              return l10n.onboardingBioTooLong;
            }
            return null;
          },
        ),
      ),
    );
  }
}
