# Chat Models Documentation

This document describes the chat models and architecture implemented for the messaging system.

## Models

### ChatParticipant
Represents a user participating in a conversation.

**Properties:**
- `id`: Unique identifier for the participant
- `username`: Username of the participant
- `displayName`: Optional display name (falls back to username)
- `avatarUrl`: Optional profile picture URL
- `role`: Participant role (member, admin, owner)
- `lastSeen`: Last seen timestamp
- `isOnline`: Current online status

### ChatMessage
Represents a single message in a conversation.

**Properties:**
- `id`: Unique message identifier
- `conversationId`: ID of the conversation this message belongs to
- `senderId`: ID of the user who sent the message
- `content`: Message content/text
- `type`: Message type (text, image, video, audio, file, system)
- `status`: Message status (sending, sent, delivered, read, failed)
- `timestamp`: When the message was sent
- `editedAt`: Optional timestamp if message was edited
- `replyToMessageId`: Optional ID if this is a reply
- `metadata`: Optional additional data
- `attachments`: Optional list of attachment URLs

### Conversation
Represents a conversation between participants.

**Properties:**
- `id`: Unique conversation identifier
- `title`: Optional conversation title
- `type`: Conversation type (direct, group)
- `participants`: List of conversation participants
- `lastMessage`: Most recent message in the conversation
- `lastActivity`: Timestamp of last activity
- `unreadCount`: Number of unread messages
- `isMuted`: Whether notifications are muted
- `isPinned`: Whether conversation is pinned
- `avatarUrl`: Optional conversation avatar
- `metadata`: Optional additional data

**Computed Properties:**
- `displayTitle`: Smart title based on participants or custom title
- `displayAvatarUrl`: Smart avatar URL selection
- `hasUnreadMessages`: Whether there are unread messages
- `lastMessagePreview`: Formatted preview of last message
- `formattedLastActivity`: Human-readable last activity time

## Enums

### MessageType
- `text`: Regular text message
- `image`: Image attachment
- `video`: Video attachment
- `audio`: Audio message
- `file`: File attachment
- `system`: System-generated message

### MessageStatus
- `sending`: Message is being sent
- `sent`: Message sent successfully
- `delivered`: Message delivered to recipient
- `read`: Message read by recipient
- `failed`: Message failed to send

### ConversationType
- `direct`: One-on-one conversation
- `group`: Group conversation with multiple participants

### ParticipantRole
- `member`: Regular participant
- `admin`: Administrator with elevated permissions
- `owner`: Owner with full permissions

## Services

### ChatService
Singleton service that manages chat data and provides mock functionality.

**Key Methods:**
- `initialize()`: Initialize the service with mock data
- `getConversations()`: Get all conversations
- `getMessages(conversationId)`: Get messages for a conversation
- `sendMessage(conversationId, content)`: Send a new message
- `markAsRead(conversationId)`: Mark conversation as read

**Streams:**
- `conversationsStream`: Stream of conversation updates
- `messagesStream`: Stream of message updates

### ChatController
ChangeNotifier that provides state management for the chat system.

**Key Features:**
- Reactive state management
- Error handling
- Loading states
- Conversation filtering (unread, pinned)
- Total unread count

## Architecture

The chat system follows a clean architecture pattern:

1. **Models**: Pure data classes with business logic
2. **Services**: Data layer that handles API calls and data persistence
3. **Controllers**: State management layer using ChangeNotifier
4. **Widgets**: UI components that consume the state

## Usage Examples

### Basic Conversation Display
```dart
ConversationList(
  conversations: conversations,
  onConversationTap: (conversation) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ChatScreen(conversation: conversation),
    ));
  },
)
```

### Sending a Message
```dart
await chatService.sendMessage(conversationId, 'Hello!');
```

### Using the Controller
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatController(),
      child: Consumer<ChatController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return CircularProgressIndicator();
          }
          
          return ConversationList(
            conversations: controller.conversations,
            onConversationTap: (conversation) {
              // Handle tap
            },
          );
        },
      ),
    );
  }
}
```

## Features

### Smart Avatars
- Automatic fallback to generated avatars
- Group conversation avatars show multiple participants
- Online status indicators for direct conversations

### Message Status Indicators
- Visual indicators for message delivery status
- Loading states for sending messages
- Error states for failed messages

### Conversation Management
- Pinned conversations
- Muted conversations
- Unread message counts
- Smart time formatting

### Real-time Updates
- Stream-based updates for conversations and messages
- Automatic UI updates when data changes
- Optimistic UI updates for better UX

## Future Enhancements

- Message reactions
- Message threading/replies
- File attachments
- Voice messages
- Message search
- Conversation archiving
- Push notifications
- Message encryption 