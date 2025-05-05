import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

/// Example provider for app theme mode
/// This demonstrates how to create a simple provider using Riverpod annotations
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  bool build() {
    // Default to light mode
    return false; // false = light mode, true = dark mode
  }

  /// Toggle between light and dark mode
  void toggle() {
    state = !state;
  }
}

/// Example of a simple provider without annotations
/// This is useful for providers that don't need state management
final exampleProvider = Provider<String>((ref) {
  return 'Example Provider';
});

/// As features are migrated, their providers will be created in their respective
/// feature directories and can reference these core providers if needed. 