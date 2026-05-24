import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/molecules/feed_tag_list.dart';
import 'package:spark/src/core/design_system/components/molecules/story_circle.dart';
import 'package:spark/src/core/design_system/templates/chat_list_page_template.dart';
import 'package:spark/src/core/design_system/templates/chat_thread_page_template.dart';
import 'package:spark/src/core/design_system/templates/explore_page_template.dart';
import 'package:spark/src/core/design_system/templates/feeds_bar_template.dart';
import 'package:spark/src/core/design_system/templates/image_review_page_template.dart';
import 'package:spark/src/core/design_system/templates/recording_page_template.dart';
import 'package:spark/src/core/design_system/templates/video_review_page_template.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/features/search/providers/suggested_feeds_provider.dart';
import 'package:spark/src/features/search/ui/widgets/suggested_feeds_list.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'default', type: ChatListPageTemplate)
Widget buildChatListPageTemplateUseCase(BuildContext context) {
  return ChatListPageTemplate(
    items: const [
      ChatListItemData(
        displayName: 'Alex Morgan',
        handle: 'alex.sprk.so',
        timestamp: '2m',
        preview: 'That edit is ready to review.',
        unread: true,
      ),
      ChatListItemData(
        displayName: 'Sam Rivera',
        handle: 'sam.sprk.so',
        timestamp: '1h',
        preview: 'Sending the clip now.',
      ),
    ],
    onItemTap: (_) {},
  );
}

@UseCase(name: 'loading', type: ChatListPageTemplate)
Widget buildChatListPageTemplateLoadingUseCase(BuildContext context) {
  return const ChatListPageTemplate.loading();
}

@UseCase(name: 'default', type: ChatThreadPageTemplate)
Widget buildChatThreadPageTemplateUseCase(BuildContext context) {
  return ChatThreadPageTemplate(
    displayName: 'Alex Morgan',
    handle: 'alex.sprk.so',
    messagesWidget: const Center(child: Text('Messages')),
    textController: TextEditingController(),
    onSend: () {},
  );
}

@UseCase(name: 'default', type: ExplorePageTemplate)
Widget buildExplorePageTemplateUseCase(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: ExplorePageTemplate(
      searchHintText: 'Search users and posts',
      showClearSearch: false,
      emptyStateWidget: const _ExploreDiscoveryPreview(),
      tabsWidget: const TabBar(
        tabs: [
          Tab(text: 'Posts'),
          Tab(text: 'Users'),
        ],
      ),
      contentWidget: const TabBarView(
        children: [_ExplorePostsPreview(), _ExploreUsersPreview()],
      ),
      showTabs: false,
    ),
  );
}

@UseCase(name: 'default', type: FeedsBarTemplate)
Widget buildFeedsBarTemplateUseCase(BuildContext context) {
  return const Scaffold(
    backgroundColor: Colors.black,
    appBar: FeedsBarTemplate(
      tags: [
        FeedTagData(id: 'following', text: 'Following'),
        FeedTagData(id: 'art', text: 'Art'),
        FeedTagData(id: 'music', text: 'Music'),
      ],
      selectedTagId: 'following',
    ),
    body: SizedBox.expand(),
  );
}

@UseCase(name: 'empty', type: ImageReviewPageTemplate)
Widget buildImageReviewPageTemplateUseCase(BuildContext context) {
  return ImageReviewPageTemplate(
    title: 'New post',
    onBack: () {},
    imagePaths: const [],
    currentPage: 0,
    onPageChanged: (_) {},
    onTapEditImage: (_) {},
    onAltEdit: (_) {},
    onRemoveImage: (_) {},
    showAddMore: true,
    canAddMore: true,
    imagesCount: 0,
    maxImages: 4,
    onAddMore: () {},
    descriptionMaxChars: 300,
    postLabel: 'Post',
    onPost: () {},
    isPosting: false,
    crossPostValue: false,
    onCrossPostChanged: (_) {},
  );
}

@UseCase(name: 'default', type: RecordingPageTemplate)
Widget buildRecordingPageTemplateUseCase(BuildContext context) {
  return RecordingPageTemplate(
    cameraPreview: const ColoredBox(color: Colors.black),
    aspectRatio: 9 / 16,
    isRecording: false,
    elapsedDuration: Duration.zero,
    maxDuration: const Duration(minutes: 1),
    onBack: () {},
    onFlipCamera: () {},
    canFlipCamera: true,
    captureMode: CaptureMode.videoOnly,
  );
}

@UseCase(name: 'default', type: VideoReviewPageTemplate)
Widget buildVideoReviewPageTemplateUseCase(BuildContext context) {
  return VideoReviewPageTemplate(
    title: 'New video',
    onBack: () {},
    videoPreview: const ColoredBox(color: Colors.black),
    onAltEdit: () {},
    descriptionMaxChars: 300,
    postLabel: 'Post',
    onPost: () {},
    isPosting: false,
    crossPostValue: false,
    onCrossPostChanged: (_) {},
  );
}

class _ExploreDiscoveryPreview extends StatelessWidget {
  const _ExploreDiscoveryPreview();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _StoriesPreview()),
        SliverToBoxAdapter(child: _SuggestedFeedsPreview()),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Discover stories, feeds, and people')),
        ),
      ],
    );
  }
}

class _StoriesPreview extends StatelessWidget {
  const _StoriesPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Stories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.manage_history_outlined, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        SizedBox(
          height: 102,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: StoryCircle.create(userName: 'Create', imageUrl: ''),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: StoryCircle.story(userName: 'Maya', imageUrl: ''),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: StoryCircle.story(userName: 'Jon', imageUrl: ''),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: StoryCircle.story(userName: 'Ari', imageUrl: ''),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestedFeedsPreview extends StatelessWidget {
  const _SuggestedFeedsPreview();

  @override
  Widget build(BuildContext context) {
    final suggestedFeeds = _sampleSuggestedFeeds();
    final savedFeeds = suggestedFeeds
        .map(
          (generatorView) => Feed(
            type: 'feed',
            config: makeSavedFeed(
              type: 'feed',
              value: generatorView.uri.toString(),
              pinned: false,
            ),
            view: generatorView,
          ),
        )
        .toList();

    return ProviderScope(
      overrides: [
        suggestedFeedsProvider.overrideWith(
          () => _WidgetbookSuggestedFeeds(suggestedFeeds),
        ),
        settingsProvider.overrideWithValue(
          SettingsState(activeFeed: savedFeeds.first, feeds: const []),
        ),
      ],
      child: const SuggestedFeedsList(),
    );
  }
}

class _WidgetbookSuggestedFeeds extends SuggestedFeeds {
  _WidgetbookSuggestedFeeds(this.feeds);

  final List<GeneratorView> feeds;

  @override
  Future<List<GeneratorView>> build() async => feeds;
}

List<GeneratorView> _sampleSuggestedFeeds() {
  final now = DateTime(2026, 5, 19);

  return [
    _sampleGeneratorView(
      uri: 'at://did:plc:sparkcreators/so.sprk.feed.generator/creators',
      cid: 'bafyreicreators',
      did: 'did:plc:sparkcreators',
      handle: 'spark.sprk.so',
      displayName: 'Spark Creators',
      description: 'Fresh clips, edits, and creator updates.',
      likeCount: 1200,
      indexedAt: now,
    ),
    _sampleGeneratorView(
      uri: 'at://did:plc:sounds/so.sprk.feed.generator/music-finds',
      cid: 'bafyreisounds',
      did: 'did:plc:sounds',
      handle: 'sounds.sprk.so',
      displayName: 'Music Finds',
      description: 'Tracks people are using in new posts.',
      likeCount: 840,
      indexedAt: now,
    ),
  ];
}

GeneratorView _sampleGeneratorView({
  required String uri,
  required String cid,
  required String did,
  required String handle,
  required String displayName,
  required String description,
  required int likeCount,
  required DateTime indexedAt,
}) {
  return GeneratorView.fromJson({
    r'$type': 'so.sprk.feed.defs#generatorView',
    'uri': uri,
    'cid': cid,
    'did': did,
    'creator': {
      r'$type': 'so.sprk.actor.defs#profileView',
      'did': did,
      'handle': handle,
      'displayName': displayName,
    },
    'displayName': displayName,
    'description': description,
    'likeCount': likeCount,
    'indexedAt': indexedAt.toIso8601String(),
  });
}

class _ExplorePostsPreview extends StatelessWidget {
  const _ExplorePostsPreview();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.45,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: Color.lerp(
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.primaryContainer,
              index / 8,
            )!,
          ),
        );
      },
    );
  }
}

class _ExploreUsersPreview extends StatelessWidget {
  const _ExploreUsersPreview();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 4,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: CircleAvatar(child: Text('U${index + 1}')),
          title: Text(
            ['Maya Chen', 'Jon Bell', 'Ari Stone', 'Lee Park'][index],
          ),
          subtitle: Text('@${['maya', 'jon', 'ari', 'lee'][index]}.sprk.so'),
        );
      },
    );
  }
}
