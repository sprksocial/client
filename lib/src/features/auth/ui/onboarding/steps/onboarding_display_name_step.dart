import 'package:flutter/material.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/ui/widgets/custom_text_field.dart';

class OnboardingDisplayNameStep extends StatefulWidget {
  const OnboardingDisplayNameStep({
    this.initialDisplayName = '',
    this.onUndoDisplayName,
    super.key,
  });

  final String initialDisplayName;
  final VoidCallback? onUndoDisplayName;

  @override
  State<OnboardingDisplayNameStep> createState() =>
      OnboardingDisplayNameStepState();
}

class OnboardingDisplayNameStepState extends State<OnboardingDisplayNameStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;

  String get displayName => _displayNameController.text;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  bool validate() => _formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final placeholder = widget.initialDisplayName.trim().isNotEmpty
        ? widget.initialDisplayName
        : 'Jane Doe';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Form(
        key: _formKey,
        child: CustomTextField(
          controller: _displayNameController,
          hintText: placeholder,
          fillColor:
              theme.inputDecorationTheme.fillColor ?? colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 22,
          ),
          textStyle: theme.textTheme.headlineSmall,
          hintStyle: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          borderRadius: 16,
          onUndo: widget.onUndoDisplayName,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.inputErrorRequired;
            }
            if (value.trim().length > 64) {
              return l10n.onboardingDisplayNameTooLong;
            }
            return null;
          },
        ),
      ),
    );
  }
}
