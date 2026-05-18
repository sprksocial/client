import 'package:flutter/material.dart';

/// Represents a single step within an [OnboardingSequence].
class OnboardingStep {
  const OnboardingStep({
    required this.title,
    required this.builder,
    this.canProceed,
  });

  /// Title shown above the progress indicator for this step.
  final String title;

  /// Builder that returns the content widget for this step.
  final WidgetBuilder builder;

  /// Optional validation called before advancing to the next step.
  /// Return `false` to block navigation.
  final bool Function()? canProceed;
}
