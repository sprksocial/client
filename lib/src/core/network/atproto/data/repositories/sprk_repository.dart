import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/notification_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository.dart';
import 'package:spark/src/features/auth/auth.dart';

// All possible endpoints for the Sprk API should be in this contract
// The implementation should be in each feature's repository
abstract class SprkRepository {
  /// Execute an API call with retry logic
  ///
  /// [apiCall] The API call to execute
  Future<T> executeWithRetry<T>(Future<T> Function() apiCall);

  /// Get the authentication service
  AuthRepository get authRepository;

  /// Get the Sprk DID
  String get sprkDid;
  String get bskyDid;
  String get modDid;
  String get bskyModDid;

  ActorRepository get actor;
  RepoRepository get repo;
  FeedRepository get feed;
  StoryRepository get story;
  GraphRepository get graph;
  LabelerRepository get labeler;
  SoundRepository get sound;
  NotificationRepository get notification;
}
