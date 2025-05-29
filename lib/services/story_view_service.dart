import 'package:shared_preferences/shared_preferences.dart';

class StoryViewService {
  static const String _viewedStoriesKey = 'viewed_stories';
  static StoryViewService? _instance;

  StoryViewService._();

  static StoryViewService get instance {
    _instance ??= StoryViewService._();
    return _instance!;
  }

  Future<Set<String>> getViewedStories() async {
    final prefs = await SharedPreferences.getInstance();
    final viewedList = prefs.getStringList(_viewedStoriesKey) ?? [];
    return viewedList.toSet();
  }

  Future<void> markStoryAsViewed(String storyUri) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedSet = await getViewedStories();
    viewedSet.add(storyUri);
    await prefs.setStringList(_viewedStoriesKey, viewedSet.toList());
  }

  Future<void> markStoriesAsViewed(List<String> storyUris) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedSet = await getViewedStories();
    viewedSet.addAll(storyUris);
    await prefs.setStringList(_viewedStoriesKey, viewedSet.toList());
  }

  Future<int> getUnviewedCount(List<Map<String, dynamic>> stories) async {
    final viewedSet = await getViewedStories();
    int unviewedCount = 0;

    for (final story in stories) {
      final storyUri = story['uri'] as String?;
      if (storyUri != null && !viewedSet.contains(storyUri)) {
        unviewedCount++;
      }
    }

    return unviewedCount;
  }

  Future<void> clearViewedStories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_viewedStoriesKey);
  }
}
