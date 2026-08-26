import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

/// App-owned story data layered around the generated protocol view.
final class ModeratedStoryView {
  ModeratedStoryView({
    required this.story,
    Iterable<Label> moderationLabels = const [],
  }) : moderationLabels = List.unmodifiable(moderationLabels);

  final StoryView story;
  final List<Label> moderationLabels;

  AtUri get uri => story.uri;
  String get cid => story.cid;
  ProfileViewBasic get author => story.author;
  DateTime get indexedAt => story.indexedAt;
  Map<String, dynamic> get record => story.record;
  StoryRecord? get localRecord => story.localRecord;
  List<StoryEmbedView>? get localEmbeds => story.localEmbeds;
  bool get isVideoStory => story.isVideoStory;
  String get videoUrl => story.videoUrl;
  String get imageUrl => story.imageUrl;
  String get thumbnailUrl => story.thumbnailUrl;
}
