import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation_appeal_service.dart';
import 'package:spark/src/core/moderation/moderation_label_localizations.dart';
import 'package:spark/src/core/moderation/moderation_models.dart';

class ModerationDetailsSheet extends ConsumerStatefulWidget {
  const ModerationDetailsSheet({
    required this.causes,
    required this.mayAppeal,
    super.key,
  });

  final List<ModerationCause> causes;
  final bool mayAppeal;

  @override
  ConsumerState<ModerationDetailsSheet> createState() =>
      _ModerationDetailsSheetState();
}

class _ModerationDetailsSheetState
    extends ConsumerState<ModerationDetailsSheet> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            l10n.moderationDetailsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final cause in widget.causes)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cause.localizedStrings(l10n)?.name ??
                          l10n.moderationContentNotice,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (cause.localizedStrings(l10n)?.description
                        case final description?) ...[
                      const SizedBox(height: 6),
                      Text(description),
                    ],
                    const SizedBox(height: 8),
                    SelectableText(
                      '${l10n.moderationAppliedBy}: '
                      '${cause.sourceHandle == null ? cause.sourceDid : '@${cause.sourceHandle}'}',
                    ),
                    if (cause.label.exp case final expires?)
                      Text('${l10n.moderationExpires}: ${expires.toLocal()}'),
                    if (cause.noOverride) ...[
                      const SizedBox(height: 6),
                      Text(l10n.moderationCannotOverride),
                    ],
                    if (widget.mayAppeal &&
                        ModerationAppealService.canAppeal(cause.label)) ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _submitting ? null : () => _appeal(cause),
                        child: Text(l10n.buttonAppealLabel),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _appeal(ModerationCause cause) async {
    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(moderationAppealServiceProvider)
          .appeal(cause.label, reason: l10n.moderationAppealReason);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.moderationAppealSent)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.moderationAppealFailed)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
