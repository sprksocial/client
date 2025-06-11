
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum ConversationType {
  direct,
  group,
}

enum ParticipantRole {
  member,
  admin,
  owner,
}

class ChatParticipant {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final ParticipantRole role;
  final DateTime? lastSeen;
  final bool isOnline;

  const ChatParticipant({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.role = ParticipantRole.member,
    this.lastSeen,
    this.isOnline = false,
  });

  String get name => displayName ?? username;

  ChatParticipant copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    ParticipantRole? role,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return ChatParticipant(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'lastSeen': lastSeen?.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: ParticipantRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => ParticipantRole.member,
      ),
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? editedAt;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;
  final List<String>? attachments;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.editedAt,
    this.replyToMessageId,
    this.metadata,
    this.attachments,
  });

  bool get isEdited => editedAt != null;
  bool get isReply => replyToMessageId != null;
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? editedAt,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
    List<String>? attachments,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'replyToMessageId': replyToMessageId,
      'metadata': metadata,
      'attachments': attachments,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      replyToMessageId: json['replyToMessageId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      attachments: (json['attachments'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class Conversation {
  final String id;
  final String? title;
  final ConversationType type;
  final List<ChatParticipant> participants;
  final ChatMessage? lastMessage;
  final DateTime lastActivity;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;

  const Conversation({
    required this.id,
    this.title,
    required this.type,
    required this.participants,
    this.lastMessage,
    required this.lastActivity,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.avatarUrl,
    this.metadata,
  });

  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    
    if (type == ConversationType.direct && participants.length == 2) {
      return participants.firstWhere((p) => p.id != 'current_user_id').name;
    }
    
    if (participants.length > 1) {
      final names = participants.take(3).map((p) => p.name).join(', ');
      if (participants.length > 3) {
        return '$names and ${participants.length - 3} more';
      }
      return names;
    }
    
    return 'Conversation';
  }

  String? get displayAvatarUrl {
    if (avatarUrl != null) return avatarUrl;
    
    if (type == ConversationType.direct && participants.length == 2) {
      return participants.firstWhere((p) => p.id != 'current_user_id').avatarUrl;
    }
    
    return null;
  }

  bool get hasUnreadMessages => unreadCount > 0;

  String get lastMessagePreview {
    if (lastMessage == null) return '';
    
    switch (lastMessage!.type) {
      case MessageType.text:
        return lastMessage!.content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.file:
        return '📎 File';
      case MessageType.system:
        return lastMessage!.content;
    }
  }

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
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[lastActivity.weekday - 1];
    } else {
      return '${lastActivity.day}/${lastActivity.month}/${lastActivity.year}';
    }
  }

  Conversation copyWith({
    String? id,
    String? title,
    ConversationType? type,
    List<ChatParticipant>? participants,
    ChatMessage? lastMessage,
    DateTime? lastActivity,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'lastActivity': lastActivity.toIso8601String(),
      'unreadCount': unreadCount,
      'isMuted': isMuted,
      'isPinned': isPinned,
      'avatarUrl': avatarUrl,
      'metadata': metadata,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String?,
      type: ConversationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConversationType.direct,
      ),
      participants: (json['participants'] as List<dynamic>)
          .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      lastActivity: DateTime.parse(json['lastActivity']),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isMuted: json['isMuted'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
} 