import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/features/stories/ui/pages/author_stories_page.dart';

@RoutePage()
class AllStoriesPage extends StatefulWidget {
  const AllStoriesPage({
    required this.storiesByAuthor,
    super.key,
    this.initialAuthorIndex = 0,
  });

  final Map<ProfileViewBasic, List<StoryView>> storiesByAuthor;
  final int initialAuthorIndex;

  @override
  State<AllStoriesPage> createState() => _AllStoriesPageState();
}

class _AllStoriesPageState extends State<AllStoriesPage> {
  late final PageController _pageController;
  late final List<MapEntry<ProfileViewBasic, List<StoryView>>> _authorsList;
  int _currentAuthorIndex = 0;

  @override
  void initState() {
    super.initState();
    _authorsList = widget.storiesByAuthor.entries.toList();
    _currentAuthorIndex = widget.initialAuthorIndex.clamp(0, _authorsList.length - 1);
    _pageController = PageController(initialPage: _currentAuthorIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (_authorsList.isEmpty) {
      return const Scaffold(body: Center(child: Text('No stories')));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentAuthorIndex = index),
          itemCount: _authorsList.length,
          itemBuilder: (context, index) {
            final entry = _authorsList[index];
            return AuthorStoriesPage(
              author: entry.key,
              stories: entry.value,
              onPreviousAuthor: index > 0
                  ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    )
                  : null,
              onNextAuthor: index < _authorsList.length - 1
                  ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
