// Dart models for chat messages and conversations generated with Freezed
// Following project guidelines: English language, explicit typing, and consistent nomenclature.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@JsonEnum()
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  system,
}

@JsonEnum()
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

@JsonEnum()
enum ConversationType {
  direct,
  group,
}

@JsonEnum()
enum ParticipantRole {
  member,
  admin,
  owner,
}

@freezed
class ChatParticipant with _$ChatParticipant {
  const ChatParticipant._();

  @JsonSerializable(explicitToJson: true)
  const factory ChatParticipant({
    required String id,
    required String username,
    String? displayName,
    String? avatarUrl,
    @Default(ParticipantRole.member) ParticipantRole role,
    DateTime? lastSeen,
    @Default(false) bool isOnline,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) => _$ChatParticipantFromJson(json);

  /// Returns the participant's display name if available, otherwise their username.
  String get name => displayName ?? username;
}

@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  @JsonSerializable(explicitToJson: true)
  const factory ChatMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required String content,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sent) MessageStatus status,
    required DateTime timestamp,
    DateTime? editedAt,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
    List<String>? attachments,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  bool get isEdited => editedAt != null;
  bool get isReply => replyToMessageId != null;
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;
}

@freezed
class Conversation with _$Conversation {
  const Conversation._();

  @JsonSerializable(explicitToJson: true)
  const factory Conversation({
    required String id,
    String? title,
    required ConversationType type,
    required List<ChatParticipant> participants,
    ChatMessage? lastMessage,
    required DateTime lastActivity,
    @Default(0) int unreadCount,
    @Default(false) bool isMuted,
    @Default(false) bool isPinned,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  /// Returns a displayable title for the conversation based on its participants and provided title.
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }

    if (type == ConversationType.direct && participants.length == 2) {
      // Assuming the current user id will be provided in UI/business layer.
      return participants.first.name;
    }

    if (participants.length > 1) {
      final names = participants.take(3).map((p) => p.name).join(', ');
      if (participants.length > 3) {
        return '$names and ${(participants.length - 3)} more';
      }
      return names;
    }

    return 'Conversation';
  }

  /// Chooses an avatar URL for the conversation.
  String? get displayAvatarUrl {
    if (avatarUrl != null) return avatarUrl;

    if (type == ConversationType.direct && participants.length == 2) {
      return participants.first.avatarUrl;
    }

    return null;
  }

  bool get hasUnreadMessages => unreadCount > 0;

  /// Generates a preview string for the last message, suitable for UI subtitle.
  String get lastMessagePreview {
    if (lastMessage == null) return '';

    return switch (lastMessage!.type) {
      MessageType.text => lastMessage!.content,
      MessageType.image => '📷 Photo',
      MessageType.video => '🎥 Video',
      MessageType.audio => '🎵 Audio',
      MessageType.file => '📎 File',
      MessageType.system => lastMessage!.content,
    };
  }

  /// Human-friendly formatted last activity for UI display.
  String get formattedLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[lastActivity.weekday - 1];
    } else {
      return '${lastActivity.day}/${lastActivity.month}/${lastActivity.year}';
    }
  }
}
