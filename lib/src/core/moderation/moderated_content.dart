import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation_details_sheet.dart';
import 'package:spark/src/core/moderation/moderation_engine.dart';
import 'package:spark/src/core/moderation/moderation_models.dart';
import 'package:spark/src/core/moderation/moderation_presentation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/moderation/moderation_subject.dart';

/// Applies the same moderation decision and reveal rules to every surface.
class ModeratedContent extends ConsumerStatefulWidget {
  const ModeratedContent({
    required this.subject,
    required this.context,
    required this.child,
    super.key,
    this.presentation = const ModerationPresentation.standard(),
    this.filterReplacement = const SizedBox.shrink(),
    this.onConcealChanged,
  });

  final ModerationSubject subject;
  final ModerationContext context;
  final Widget child;
  final ModerationPresentation presentation;
  final Widget filterReplacement;
  final ValueChanged<bool>? onConcealChanged;

  @override
  ConsumerState<ModeratedContent> createState() => _ModeratedContentState();
}

class ModeratedProfileAvatar extends StatelessWidget {
  const ModeratedProfileAvatar({
    required this.labels,
    required this.subjectDid,
    required this.child,
    super.key,
  });

  final List<Label> labels;
  final String subjectDid;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ModeratedContent(
        subject: ModerationSubject.profile(
          labels: labels,
          subjectDid: subjectDid,
        ),
        context: ModerationContext.avatar,
        presentation: const ModerationPresentation.compact(),
        child: child,
      ),
    );
  }
}

class _ModeratedContentState extends ConsumerState<ModeratedContent> {
  String? _revealedKey;
  bool? _lastConcealed;

  @override
  Widget build(BuildContext context) {
    if (!widget.subject.hasLabels) {
      _notifyConcealed(false);
      return widget.child;
    }

    final engineState = ref.watch(moderationEngineProvider);
    final engine = engineState.asData?.value;
    if (engine == null) {
      _notifyConcealed(true);
      return ModerationPending(
        hasError: engineState.hasError,
        onRetry: () => ref.invalidate(moderationEngineProvider),
        child: widget.child,
      );
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final decision = widget.subject.evaluate(
      engine,
      preferredLocales: [locale],
    );
    final ui = decision.forContext(widget.context);
    if (ui.filter) {
      _notifyConcealed(true);
      return widget.filterReplacement;
    }
    if (!ui.blur && !ui.alert && !ui.inform) {
      _notifyConcealed(false);
      return widget.child;
    }

    final causes = <ModerationCause>{
      ...ui.blurs,
      ...ui.alerts,
      ...ui.informs,
    }.toList();
    final disclosureKey = widget.subject.disclosureKey(widget.context);
    final concealed =
        ui.blur && (ui.noOverride || _revealedKey != disclosureKey);
    _notifyConcealed(concealed);

    return widget.presentation.render(
      child: widget.child,
      concealed: concealed,
      ui: ui,
      causes: causes,
      reveal: () => setState(() => _revealedKey = disclosureKey),
      showDetails: () => _showDetails(decision, causes),
    );
  }

  Future<void> _showDetails(
    ModerationDecision decision,
    List<ModerationCause> causes,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ModerationDetailsSheet(
        causes: causes,
        mayAppeal: decision.isSubjectCurrentUser,
      ),
    );
  }

  void _notifyConcealed(bool concealed) {
    if (_lastConcealed == concealed) return;
    _lastConcealed = concealed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onConcealChanged?.call(concealed);
    });
  }
}
