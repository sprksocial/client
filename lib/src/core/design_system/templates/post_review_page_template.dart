import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/app_toggle.dart';
import 'package:spark/src/core/design_system/components/molecules/input_field.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';
import 'package:spark/src/features/posting/ui/widgets/mention_input_field.dart';

class PostReviewPageTemplate extends StatelessWidget {
  const PostReviewPageTemplate({
    required this.title,
    required this.onBack,
    required this.media,
    required this.caption,
    required this.options,
    required this.postLabel,
    required this.onPost,
    required this.isPosting,
    this.backgroundColor,
    this.status,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Widget media;
  final Widget caption;
  final List<Widget> options;
  final String postLabel;
  final VoidCallback? onPost;
  final bool isPosting;
  final Color? backgroundColor;
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: AppLeadingButton(
          onPressed: onBack,
          tooltip: AppLocalizations.of(context).buttonBack,
          color: theme.colorScheme.onSurface,
        ),
        title: Text(title),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: AbsorbPointer(
                        absorbing: isPosting,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            media,
                            const SizedBox(height: 28),
                            caption,
                            const SizedBox(height: 20),
                            ...options,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status != null) ...[
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight * 0.3,
                            ),
                            child: SingleChildScrollView(child: status),
                          ),
                          const SizedBox(height: 12),
                        ],
                        AppButton(
                          label: postLabel,
                          onPressed: isPosting ? null : onPost,
                          fullWidth: true,
                          leading: isPosting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostReviewCaption extends StatelessWidget {
  const PostReviewCaption({
    required this.maxChars,
    this.controller,
    this.mentionController,
    this.enabled = true,
    super.key,
  });

  final int maxChars;
  final TextEditingController? controller;
  final MentionController? mentionController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final textController = mentionController?.textController ?? controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewCaption,
          style: AppTypography.textMediumMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Theme(
          data: theme.copyWith(
            inputDecorationTheme: theme.inputDecorationTheme.copyWith(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          child: mentionController != null
              ? MentionInputField(
                  controller: mentionController!,
                  onMentionsChanged: (_) {},
                  hintText: l10n.hintAddDescription,
                  maxChars: maxChars,
                  minLines: 5,
                  maxLines: 8,
                  enabled: enabled,
                )
              : InputField.search(
                  controller: controller,
                  hintText: l10n.hintAddDescription,
                  minLines: 5,
                  maxLines: 8,
                  enabled: enabled,
                ),
        ),
        if (textController != null)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (context, value, _) {
              final count = value.text.runes.length;
              if (count < maxChars * 0.8) return const SizedBox.shrink();
              return Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '$count/$maxChars',
                  style: AppTypography.textSmallMedium.copyWith(
                    color: count > maxChars
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class PostReviewCrossPost extends StatelessWidget {
  const PostReviewCrossPost({
    required this.value,
    required this.onChanged,
    this.showWarning = false,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showWarning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MergeSemantics(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.reviewAlsoPostToBluesky),
            trailing: AppToggle(value: value, onChanged: onChanged),
            onTap: () => onChanged(!value),
          ),
        ),
        if (showWarning)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              l10n.reviewCrosspostImageWarning,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
