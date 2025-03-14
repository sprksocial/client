import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Messages'),
        trailing: Icon(Ionicons.create_outline),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                placeholder: 'Search',
                prefixIcon: const Icon(Ionicons.search_outline),
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),
            
            // Message list
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  return MessageListItem(index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageListItem extends StatelessWidget {
  final int index;
  
  const MessageListItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Generate mock data based on index
    final bool hasUnread = index % 3 == 0;
    final String username = '@user${index + 1}';
    final String message = index % 2 == 0
        ? 'Check out my latest video! 🔥'
        : 'Hey, how are you doing?';
    final String time = index % 4 == 0
        ? 'Just now'
        : index % 4 == 1
            ? '5m ago'
            : index % 4 == 2
                ? '1h ago'
                : 'Yesterday';

    return GestureDetector(
      onTap: () {
        // Navigate to chat detail
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Profile image
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? CupertinoColors.systemPurple.withOpacity(0.2)
                        : CupertinoColors.systemTeal.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Ionicons.person_outline,
                      color: index % 2 == 0
                          ? CupertinoColors.systemPurple
                          : CupertinoColors.systemTeal,
                      size: 30,
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: hasUnread
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: hasUnread
                          ? CupertinoColors.label
                          : CupertinoColors.systemGrey,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Right action
            Icon(
              Ionicons.chevron_forward,
              color: CupertinoColors.systemGrey2,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 