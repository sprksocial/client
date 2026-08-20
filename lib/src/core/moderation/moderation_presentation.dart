import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation_label_localizations.dart';
import 'package:spark/src/core/moderation/moderation_models.dart';

sealed class ModerationPresentation {
  const ModerationPresentation();

  const factory ModerationPresentation.standard({Widget? blurredChild}) =
      StandardModerationPresentation;

  const factory ModerationPresentation.compact({
    Widget? blurredChild,
    VoidCallback? onConcealedTap,
  }) = CompactModerationPresentation;

  Widget render({
    required Widget child,
    required bool concealed,
    required ModerationUI ui,
    required List<ModerationCause> causes,
    required VoidCallback reveal,
    required VoidCallback showDetails,
  });
}

final class StandardModerationPresentation extends ModerationPresentation {
  const StandardModerationPresentation({this.blurredChild});

  final Widget? blurredChild;

  @override
  Widget render({
    required Widget child,
    required bool concealed,
    required ModerationUI ui,
    required List<ModerationCause> causes,
    required VoidCallback reveal,
    required VoidCallback showDetails,
  }) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (concealed)
          IgnorePointer(
            child:
                blurredChild ??
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: child,
                ),
          )
        else
          child,
        if (concealed)
          Positioned.fill(
            child: _ModerationCover(
              causes: causes,
              noOverride: ui.noOverride,
              onReveal: ui.noOverride ? null : reveal,
              onDetails: showDetails,
            ),
          )
        else if (ui.alert || ui.inform)
          Positioned(
            left: 12,
            top: 12,
            child: _ModerationNotice(causes: causes, onTap: showDetails),
          ),
      ],
    );
  }
}

final class CompactModerationPresentation extends ModerationPresentation {
  const CompactModerationPresentation({this.blurredChild, this.onConcealedTap});

  final Widget? blurredChild;
  final VoidCallback? onConcealedTap;

  @override
  Widget render({
    required Widget child,
    required bool concealed,
    required ModerationUI ui,
    required List<ModerationCause> causes,
    required VoidCallback reveal,
    required VoidCallback showDetails,
  }) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (concealed)
          blurredChild ??
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: child,
              )
        else
          child,
        if (concealed)
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.38),
              child: InkWell(
                onTap: onConcealedTap ?? (ui.noOverride ? showDetails : reveal),
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
            child: _CompactModerationNotice(onTap: showDetails),
          ),
      ],
    );
  }
}

class ModerationPending extends StatelessWidget {
  const ModerationPending({
    required this.hasError,
    required this.onRetry,
    required this.child,
    super.key,
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
