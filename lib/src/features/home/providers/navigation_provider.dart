import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/home/data/models/navigation_state.dart';

/// NavigationNotifier manages the bottom navigation state
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void updateIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

/// Provider for the navigation state
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
