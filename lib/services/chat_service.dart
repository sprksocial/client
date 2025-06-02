import 'dart:async';
import 'dart:math';
import '../models/chat.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final StreamController<List<Conversation>> _conversationsController = StreamController<List<Conversation>>.broadcast();
  final StreamController<List<ChatMessage>> _messagesController = StreamController<List<ChatMessage>>.broadcast();
  
  List<Conversation> _conversations = [];
  Map<String, List<ChatMessage>> _messagesByConversation = {};

  Stream<List<Conversation>> get conversationsStream => _conversationsController.stream;
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  List<Conversation> get conversations => List.unmodifiable(_conversations);

  Future<void> initialize() async {
    await _loadMockData();
    _conversationsController.add(_conversations);
  }

  Future<List<Conversation>> getConversations() async {
    if (_conversations.isEmpty) {
      await _loadMockData();
    }
    return _conversations;
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    return _messagesByConversation[conversationId] ?? [];
  }

  Future<Conversation?> getConversation(String conversationId) async {
    try {
      return _conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage(String conversationId, String content, {MessageType type = MessageType.text}) async {
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'current_user_id',
      content: content,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );

    _messagesByConversation[conversationId] ??= [];
    _messagesByConversation[conversationId]!.add(message);

    final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
        lastMessage: message,
        lastActivity: DateTime.now(),
      );
    }

    _conversationsController.add(_conversations);
    _messagesController.add(_messagesByConversation[conversationId]!);

    await Future.delayed(const Duration(milliseconds: 500));
    
    final sentMessage = message.copyWith(status: MessageStatus.sent);
    _messagesByConversation[conversationId]![_messagesByConversation[conversationId]!.length - 1] = sentMessage;
    
    _messagesController.add(_messagesByConversation[conversationId]!);
  }

  Future<void> markAsRead(String conversationId) async {
    final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(unreadCount: 0);
      _conversationsController.add(_conversations);
    }
  }

  Future<void> _loadMockData() async {
    final now = DateTime.now();
    
    final participants = [
      ChatParticipant(
        id: 'user_1',
        username: 'abstergo',
        displayName: 'Abstergo Industries',
        avatarUrl: 'https://randomuser.me/api/portraits/men/41.jpg',
        isOnline: true,
      ),
      ChatParticipant(
        id: 'user_2',
        username: 'leslie.alexander',
        displayName: 'Leslie Alexander',
        avatarUrl: 'https://randomuser.me/api/portraits/women/72.jpg',
        isOnline: false,
        lastSeen: now.subtract(const Duration(hours: 2)),
      ),
      ChatParticipant(
        id: 'user_3',
        username: 'eleanor.pena',
        displayName: 'Eleanor Pena',
        avatarUrl: 'https://randomuser.me/api/portraits/women/53.jpg',
        isOnline: true,
      ),
      ChatParticipant(
        id: 'user_4',
        username: 'devon.lane',
        displayName: 'Devon Lane',
        avatarUrl: 'https://randomuser.me/api/portraits/men/86.jpg',
        isOnline: false,
        lastSeen: now.subtract(const Duration(minutes: 30)),
      ),
      ChatParticipant(
        id: 'user_5',
        username: 'esther.howard',
        displayName: 'Esther Howard',
        avatarUrl: 'https://randomuser.me/api/portraits/women/33.jpg',
        isOnline: false,
        lastSeen: now.subtract(const Duration(days: 1)),
      ),
      ChatParticipant(
        id: 'user_6',
        username: 'arlene.mccoy',
        displayName: 'Arlene McCoy',
        avatarUrl: 'https://randomuser.me/api/portraits/women/90.jpg',
        isOnline: true,
      ),
      ChatParticipant(
        id: 'user_7',
        username: 'dianne.russell',
        displayName: 'Dianne Russell',
        avatarUrl: 'https://randomuser.me/api/portraits/women/25.jpg',
        isOnline: false,
        lastSeen: now.subtract(const Duration(hours: 5)),
      ),
    ];

    final currentUser = ChatParticipant(
      id: 'current_user_id',
      username: 'current_user',
      displayName: 'You',
      isOnline: true,
    );

    final messages = [
      ChatMessage(
        id: 'msg_1',
        conversationId: 'conv_1',
        senderId: 'user_1',
        content: 'Ooooh thank you so much! ❤️',
        timestamp: now.subtract(const Duration(days: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_2',
        conversationId: 'conv_2',
        senderId: 'user_2',
        content: 'Makes to a illustrated on all and let me know what you think about it.',
        timestamp: now.subtract(const Duration(hours: 6, minutes: 27)),
        status: MessageStatus.delivered,
      ),
      ChatMessage(
        id: 'msg_3',
        conversationId: 'conv_3',
        senderId: 'user_3',
        content: 'For sure! Let\'s hangout on Scheduled date and time.',
        timestamp: now.subtract(const Duration(hours: 9, minutes: 28)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_4',
        conversationId: 'conv_4',
        senderId: 'user_4',
        content: 'Hey, I heard that you wanted to collaborate on something?',
        timestamp: now.subtract(const Duration(hours: 5, minutes: 18)),
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: 'msg_5',
        conversationId: 'conv_5',
        senderId: 'user_5',
        content: '😴 No 😴 I just went to bed right now, talk tomorrow!',
        timestamp: now.subtract(const Duration(days: 1)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_6',
        conversationId: 'conv_6',
        senderId: 'user_6',
        content: 'But I\'m not really sure how it is but sure! Let me check.',
        timestamp: now.subtract(const Duration(days: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_7',
        conversationId: 'conv_7',
        senderId: 'user_7',
        content: 'No problem! See you then.',
        timestamp: now.subtract(const Duration(days: 3)),
        status: MessageStatus.read,
      ),
    ];

    _conversations = [
      Conversation(
        id: 'conv_1',
        type: ConversationType.group,
        title: 'Abstergo and 4 more',
        participants: [currentUser, participants[0], participants[1], participants[2], participants[3], participants[4]],
        lastMessage: messages[0],
        lastActivity: messages[0].timestamp,
        unreadCount: 1,
        isPinned: false,
      ),
      Conversation(
        id: 'conv_2',
        type: ConversationType.direct,
        participants: [currentUser, participants[1]],
        lastMessage: messages[1],
        lastActivity: messages[1].timestamp,
        unreadCount: 0,
      ),
      Conversation(
        id: 'conv_3',
        type: ConversationType.direct,
        participants: [currentUser, participants[2]],
        lastMessage: messages[2],
        lastActivity: messages[2].timestamp,
        unreadCount: 0,
      ),
      Conversation(
        id: 'conv_4',
        type: ConversationType.direct,
        participants: [currentUser, participants[3]],
        lastMessage: messages[3],
        lastActivity: messages[3].timestamp,
        unreadCount: 3,
      ),
      Conversation(
        id: 'conv_5',
        type: ConversationType.direct,
        participants: [currentUser, participants[4]],
        lastMessage: messages[4],
        lastActivity: messages[4].timestamp,
        unreadCount: 0,
      ),
      Conversation(
        id: 'conv_6',
        type: ConversationType.direct,
        participants: [currentUser, participants[5]],
        lastMessage: messages[5],
        lastActivity: messages[5].timestamp,
        unreadCount: 0,
      ),
      Conversation(
        id: 'conv_7',
        type: ConversationType.direct,
        participants: [currentUser, participants[6]],
        lastMessage: messages[6],
        lastActivity: messages[6].timestamp,
        unreadCount: 0,
      ),
    ];

    _conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    for (final message in messages) {
      _messagesByConversation[message.conversationId] ??= [];
      _messagesByConversation[message.conversationId]!.add(message);
    }

    for (final conversationId in _messagesByConversation.keys) {
      _generateAdditionalMessages(conversationId);
    }
  }

  void _generateAdditionalMessages(String conversationId) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final otherParticipants = conversation.participants.where((p) => p.id != 'current_user_id').toList();
    
    if (otherParticipants.isEmpty) return;

    final random = Random();
    final messageCount = random.nextInt(5) + 3;
    final now = DateTime.now();

    final sampleMessages = [
      'Hey there! How are you doing?',
      'That sounds great!',
      'I totally agree with you on that.',
      'Let me think about it and get back to you.',
      'Thanks for sharing that with me.',
      'Looking forward to hearing from you.',
      'Have a great day!',
      'That\'s really interesting.',
      'I\'ll check it out later.',
      'Sounds like a plan!',
    ];

    for (int i = 0; i < messageCount; i++) {
      final isFromCurrentUser = random.nextBool();
      final senderId = isFromCurrentUser ? 'current_user_id' : otherParticipants[random.nextInt(otherParticipants.length)].id;
      
      final message = ChatMessage(
        id: 'msg_${conversationId}_$i',
        conversationId: conversationId,
        senderId: senderId,
        content: sampleMessages[random.nextInt(sampleMessages.length)],
        timestamp: now.subtract(Duration(hours: random.nextInt(48), minutes: random.nextInt(60))),
        status: isFromCurrentUser ? MessageStatus.sent : MessageStatus.read,
      );

      _messagesByConversation[conversationId]!.add(message);
    }

    _messagesByConversation[conversationId]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void dispose() {
    _conversationsController.close();
    _messagesController.close();
  }
} 