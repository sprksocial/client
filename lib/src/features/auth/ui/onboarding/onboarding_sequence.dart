import 'package:flutter/material.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/auth/ui/onboarding/onboarding_step.dart';

/// A widget that displays a sequence of [OnboardingStep]s using an
/// [IndexedStack] so that form state is preserved across steps.
class OnboardingSequence extends StatefulWidget {
  const OnboardingSequence({
    required this.steps,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.onComplete,
    this.isCompleteLoading = false,
    super.key,
  });

  final List<OnboardingStep> steps;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;
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

  void _goToNext() {
    final currentStep = widget.steps[_currentIndex];
    if (currentStep.canProceed != null && !currentStep.canProceed!()) {
      return;
    }

    if (_currentIndex < widget.steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
      widget.onIndexChanged?.call(_currentIndex);
    } else {
      widget.onComplete?.call();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      widget.onIndexChanged?.call(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currentStepNumber = _currentIndex + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingStepCount(
                  currentStepNumber,
                  widget.steps.length,
                ),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.steps[_currentIndex].title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  end: currentStepNumber / widget.steps.length,
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
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _goToPrevious,
                          child: Text(l10n.buttonBack),
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: widget.isCompleteLoading ? null : _goToNext,
                        child:
                            widget.isCompleteLoading &&
                                _currentIndex == widget.steps.length - 1
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _currentIndex < widget.steps.length - 1
                                    ? l10n.buttonContinue
                                    : l10n.buttonConfirm,
                              ),
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
