import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/features/home/providers/navigation_state.dart';

part 'navigation_provider.g.dart';

@riverpod
class Navigation extends _$Navigation {
  @override
  NavigationState build() {
    return const NavigationState();
  }

  void updateIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}
