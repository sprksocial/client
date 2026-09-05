import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/auth/ui/onboarding/onboarding_step.dart';

/// A widget that displays a sequence of [OnboardingStep]s using an
/// [IndexedStack] so that form state is preserved across steps.
class OnboardingSequence extends StatefulWidget {
  const OnboardingSequence({
    required this.steps,
    this.initialIndex = 0,
    this.onStepChanged,
    this.onComplete,
    this.isCompleteLoading = false,
    super.key,
  });

  final List<OnboardingStep> steps;
  final int initialIndex;
  final ValueChanged<OnboardingStepId>? onStepChanged;
  final VoidCallback? onComplete;
  final bool isCompleteLoading;

  @override
  State<OnboardingSequence> createState() => _OnboardingSequenceState();
}

class _OnboardingSequenceState extends State<OnboardingSequence> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(OnboardingSequence oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isIncluded(widget.steps[_currentIndex])) return;

    final nextIndex = _nextIncludedIndex();
    if (nextIndex != null) {
      _currentIndex = nextIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onStepChanged?.call(widget.steps[nextIndex].id);
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onComplete?.call();
    });
  }

  bool _isIncluded(OnboardingStep step) => step.shouldInclude?.call() ?? true;

  int? _nextIncludedIndex() {
    for (var index = _currentIndex + 1; index < widget.steps.length; index++) {
      if (_isIncluded(widget.steps[index])) return index;
    }
    return null;
  }

  int? _previousIncludedIndex() {
    for (var index = _currentIndex - 1; index >= 0; index--) {
      if (_isIncluded(widget.steps[index])) return index;
    }
    return null;
  }

  void _advanceToNextIncludedStep() {
    final nextIndex = _nextIncludedIndex();
    if (nextIndex == null) {
      widget.onComplete?.call();
      return;
    }

    setState(() => _currentIndex = nextIndex);
    widget.onStepChanged?.call(widget.steps[_currentIndex].id);
  }

  void _goToNext() {
    final currentStep = widget.steps[_currentIndex];
    if (currentStep.canProceed != null && !currentStep.canProceed!()) {
      return;
    }

    _advanceToNextIncludedStep();
  }

  void _goToPrevious() {
    final previousIndex = _previousIncludedIndex();
    if (previousIndex == null) return;

    setState(() => _currentIndex = previousIndex);
    widget.onStepChanged?.call(widget.steps[_currentIndex].id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currentStep = widget.steps[_currentIndex];
    final includedSteps = widget.steps.where(_isIncluded).toList();
    final currentStepNumber = includedSteps.indexOf(currentStep) + 1;
    final includedStepCount = includedSteps.length;
    final hasPreviousStep = _previousIncludedIndex() != null;
    final hasNextStep = _nextIncludedIndex() != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingStepCount(currentStepNumber, includedStepCount),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentStep.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  end: currentStepNumber / includedStepCount,
                ),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SizedBox.expand(
                child: IndexedStack(
                  index: _currentIndex,
                  children: widget.steps
                      .map((step) => step.builder(context))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Row(
                  children: [
                    if (hasPreviousStep)
                      Expanded(
                        child: AppButton(
                          label: l10n.buttonBack,
                          onPressed: widget.isCompleteLoading
                              ? null
                              : _goToPrevious,
                          variant: AppButtonVariant.neutral,
                          size: AppButtonSize.medium,
                          fullWidth: true,
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label:
                            currentStep.primaryLabel ??
                            (hasNextStep
                                ? l10n.buttonContinue
                                : l10n.buttonConfirm),
                        onPressed: widget.isCompleteLoading ? null : _goToNext,
                        size: AppButtonSize.medium,
                        fullWidth: true,
                        leading: widget.isCompleteLoading && !hasNextStep
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
