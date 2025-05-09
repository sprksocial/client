import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/moderation/data/repositories/moderation_repository.dart';

part 'moderation_providers.g.dart';

/// Provider for the moderation repository
@riverpod
ModerationRepository moderationRepository(Ref ref) {
  return GetIt.instance<ModerationRepository>();
} 