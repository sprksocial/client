import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/admin/defs.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/moderation/create_report.dart';
import 'package:poptart_lex/com/atproto/moderation/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';

/// Applies the same moderation decision and reveal rules to every surface.
class ModeratedContent extends ConsumerStatefulWidget {
  const ModeratedContent({
    required this.labels,
    required this.target,
    required this.context,
    required this.child,
    super.key,
    this.subjectDid,
    this.authorLabels = const [],
    this.compact = false,
    this.blurredChild,
    this.onConcealedTap,
    this.filterReplacement = const SizedBox.shrink(),
    this.onConcealChanged,
  });

  final List<Label> labels;
  final ModerationTarget target;
  final ModerationContext context;
  final String? subjectDid;
  final List<Label> authorLabels;
  final Widget child;
  final bool compact;
  final Widget? blurredChild;
  final VoidCallback? onConcealedTap;
  final Widget filterReplacement;
  final ValueChanged<bool>? onConcealChanged;

  @override
  ConsumerState<ModeratedContent> createState() => _ModeratedContentState();
}

class _ModeratedContentState extends ConsumerState<ModeratedContent> {
  String? _revealedKey;
  bool? _lastConcealed;

  @override
  Widget build(BuildContext context) {
    if (widget.labels.isEmpty && widget.authorLabels.isEmpty) {
      _notifyConcealed(false);
      return widget.child;
    }

    final engineState = ref.watch(moderationEngineProvider);
    final engine = engineState.asData?.value;
    if (engine == null) {
      _notifyConcealed(true);
      return _ModerationPending(
        hasError: engineState.hasError,
        onRetry: () => ref.invalidate(moderationEngineProvider),
        child: widget.child,
      );
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final decision = ModerationDecision.merge([
      if (widget.target == ModerationTarget.account)
        engine.evaluateProfileLabels(
          widget.labels,
          subjectDid: widget.subjectDid,
          preferredLocales: [locale],
        )
      else
        engine.evaluate(
          widget.labels,
          target: widget.target,
          subjectDid: widget.subjectDid,
          preferredLocales: [locale],
        ),
      if (widget.authorLabels.isNotEmpty)
        engine.evaluateProfileLabels(
          widget.authorLabels,
          subjectDid: widget.subjectDid,
          preferredLocales: [locale],
        ),
    ]);
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
    final disclosureKey = [
      widget.subjectDid,
      widget.context.name,
      _signature([...widget.labels, ...widget.authorLabels]),
    ].join('|');
    final shouldConceal =
        ui.blur && (ui.noOverride || _revealedKey != disclosureKey);
    _notifyConcealed(shouldConceal);

    if (widget.compact) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          if (shouldConceal)
            widget.blurredChild ??
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: widget.child,
                )
          else
            widget.child,
          if (shouldConceal)
            Positioned.fill(
              child: Material(
                color: Colors.black.withValues(alpha: 0.38),
                child: InkWell(
                  onTap:
                      widget.onConcealedTap ??
                      (ui.noOverride
                          ? () => _showDetails(decision, causes)
                          : () => setState(() => _revealedKey = disclosureKey)),
                  child: const Center(
                    child: Icon(
                      Icons.visibility_off_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else if (ui.alert || ui.inform)
            Positioned(
              left: 4,
              top: 4,
              child: _CompactModerationNotice(
                onTap: () => _showDetails(decision, causes),
              ),
            ),
        ],
      );
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (shouldConceal)
          IgnorePointer(
            child:
                widget.blurredChild ??
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: widget.child,
                ),
          )
        else
          widget.child,
        if (shouldConceal)
          Positioned.fill(
            child: _ModerationCover(
              causes: causes,
              noOverride: ui.noOverride,
              onReveal: ui.noOverride
                  ? null
                  : () => setState(() => _revealedKey = disclosureKey),
              onDetails: () => _showDetails(decision, causes),
            ),
          )
        else if (ui.alert || ui.inform)
          Positioned(
            left: 12,
            top: 12,
            child: _ModerationNotice(
              causes: causes,
              onTap: () => _showDetails(decision, causes),
            ),
          ),
      ],
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
      builder: (context) => _ModerationDetails(
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

class _ModerationPending extends StatelessWidget {
  const _ModerationPending({
    required this.hasError,
    required this.onRetry,
    required this.child,
  });

  final bool hasError;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        IgnorePointer(
          child: ExcludeSemantics(child: Opacity(opacity: 0, child: child)),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.black87,
            child: hasError
                ? Semantics(
                    button: true,
                    label: AppLocalizations.of(context).buttonRetry,
                    child: InkWell(
                      onTap: onRetry,
                      child: const Center(child: Icon(Icons.refresh)),
                    ),
                  )
                : const Center(
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _CompactModerationNotice extends StatelessWidget {
  const _CompactModerationNotice({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).buttonModerationDetails,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkResponse(
          onTap: onTap,
          radius: 16,
          child: const Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.info_outline, size: 16),
          ),
        ),
      ),
    );
  }
}

class _ModerationCover extends StatelessWidget {
  const _ModerationCover({
    required this.causes,
    required this.noOverride,
    required this.onReveal,
    required this.onDetails,
  });

  final List<ModerationCause> causes;
  final bool noOverride;
  final VoidCallback? onReveal;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = causes
        .map((cause) => cause.localizedStrings(l10n)?.name)
        .nonNulls
        .toList();
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.moderationContentWarning,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (names.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  names.join(', '),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 18),
              if (onReveal != null)
                FilledButton(
                  onPressed: onReveal,
                  child: Text(l10n.buttonViewContent),
                )
              else if (noOverride)
                Text(
                  l10n.moderationCannotOverride,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              TextButton(
                onPressed: onDetails,
                child: Text(l10n.buttonModerationDetails),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModerationNotice extends StatelessWidget {
  const _ModerationNotice({required this.causes, required this.onTap});

  final List<ModerationCause> causes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = causes
        .map((cause) => cause.localizedStrings(l10n)?.name)
        .nonNulls
        .firstOrNull;
    return ActionChip(
      avatar: const Icon(Icons.info_outline, size: 18),
      label: Text(name ?? l10n.moderationContentNotice),
      onPressed: onTap,
    );
  }
}

class _ModerationDetails extends StatefulWidget {
  const _ModerationDetails({required this.causes, required this.mayAppeal});

  final List<ModerationCause> causes;
  final bool mayAppeal;

  @override
  State<_ModerationDetails> createState() => _ModerationDetailsState();
}

class _ModerationDetailsState extends State<_ModerationDetails> {
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
            Builder(
              builder: (context) {
                final strings = cause.localizedStrings(l10n);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings?.name ?? l10n.moderationContentNotice,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (strings?.description case final description?) ...[
                          const SizedBox(height: 6),
                          Text(description),
                        ],
                        const SizedBox(height: 8),
                        SelectableText(
                          '${l10n.moderationAppliedBy}: ${cause.sourceDid}',
                        ),
                        if (cause.label.exp case final expires?)
                          Text(
                            '${l10n.moderationExpires}: ${expires.toLocal()}',
                          ),
                        if (cause.noOverride) ...[
                          const SizedBox(height: 6),
                          Text(l10n.moderationCannotOverride),
                        ],
                        if (widget.mayAppeal &&
                            cause.sourceDid != _labelSubjectDid(cause.label) &&
                            cause.sourceDid.startsWith('did:')) ...[
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _submitting
                                ? null
                                : () => _appeal(cause),
                            child: Text(l10n.buttonAppealLabel),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _appeal(ModerationCause cause) async {
    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context);
    try {
      final subject = _reportSubject(cause.label);
      await GetIt.I<SprkRepository>().repo.createReport(
        input: ModerationCreateReportInput(
          subject: subject,
          reasonType: const ReasonType.knownValue(
            data: KnownReasonType.comAtprotoModerationDefsReasonAppeal,
          ),
          reason: l10n.moderationAppealReason,
        ),
        serviceDid: cause.sourceDid,
      );
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

UModerationCreateReportSubject _reportSubject(Label label) {
  AtUri? uri;
  try {
    uri = AtUri.parse(label.uri);
  } catch (_) {
    uri = null;
  }
  if (uri != null && label.cid != null && label.cid!.isNotEmpty) {
    return UModerationCreateReportSubject.repoStrongRef(
      data: RepoStrongRef(uri: uri, cid: label.cid!),
    );
  }
  final did = uri?.hostname ?? label.uri;
  return UModerationCreateReportSubject.repoRef(data: RepoRef(did: did));
}

String _labelSubjectDid(Label label) {
  try {
    return AtUri.parse(label.uri).hostname;
  } catch (_) {
    return label.uri;
  }
}

String _signature(List<Label> labels) => labels
    .map(
      (label) =>
          '${label.src}|${label.uri}|${label.val}|${label.neg}|${label.exp}',
    )
    .join(';;');
