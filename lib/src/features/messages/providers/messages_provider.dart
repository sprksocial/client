import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/messages/data/models/messages_page_state.dart';

part 'messages_provider.g.dart';


/// Provider for managing the messages page state
@riverpod
class MessagesPage extends _$MessagesPage {
  @override
  MessagesPageState build() {
    return const MessagesPageState(
      selectedTabIndex: 0,
      messages: [], // Initialize with empty lists, actual data fetched elsewhere
      activities: [], // Initialize with empty lists, actual data fetched elsewhere
    );
  }

  void setSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  // Mock data methods are removed as data fetching should be handled by a repository
  // and injected into the provider, or the provider should call a repository.
  // For this refactor, we assume data is fetched/managed elsewhere and the provider
  // primarily handles UI state like selectedTabIndex.
} 