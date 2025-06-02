import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../services/chat_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/activities/activity_icon.dart';
import '../widgets/activities/activity_list.dart';
import '../widgets/messages/conversation_list.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedTabIndex = 0;
  final ChatService _chatService = ChatService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  final List<ActivityData> _activities = [
    ActivityData(
      id: 'act_1',
      username: 'Alex Johnson',
      type: ActivityType.like,
      timeString: 'Just now',
      additionalInfo: null,
      targetContentId: 'content_1',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    ActivityData(
      id: 'act_2',
      username: 'Sophia Chen',
      type: ActivityType.comment,
      timeString: '5m ago',
      additionalInfo: 'Wow, this looks amazing! 🔥',
      targetContentId: 'content_2',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    ActivityData(
      id: 'act_3',
      username: 'Michael Taylor',
      type: ActivityType.follow,
      timeString: '10m ago',
      additionalInfo: null,
      targetContentId: null,
      avatarUrl: 'https://randomuser.me/api/portraits/men/28.jpg',
    ),
    ActivityData(
      id: 'act_4',
      username: 'Emma Wilson',
      type: ActivityType.comment,
      timeString: '1h ago',
      additionalInfo: 'Could you share more details about this?',
      targetContentId: 'content_4',
      avatarUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
    ),
    ActivityData(
      id: 'act_5',
      username: 'Ryan Martinez',
      type: ActivityType.like,
      timeString: '2h ago',
      additionalInfo: null,
      targetContentId: 'content_5',
      avatarUrl: 'https://randomuser.me/api/portraits/men/54.jpg',
    ),
    ActivityData(
      id: 'act_6',
      username: 'Olivia Brown',
      type: ActivityType.follow,
      timeString: 'Yesterday',
      additionalInfo: null,
      targetContentId: null,
      avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
    ),
    ActivityData(
      id: 'act_7',
      username: 'Noah Davis',
      type: ActivityType.like,
      timeString: 'Yesterday',
      additionalInfo: null,
      targetContentId: 'content_7',
      avatarUrl: 'https://i.pravatar.cc/150?img=17',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      await _chatService.initialize();
      final conversations = await _chatService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text('Inbox', style: TextStyle(color: AppTheme.getTextColor(context), fontWeight: FontWeight.bold)),
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          icon: Icon(FluentIcons.add_24_regular, color: AppTheme.getTextColor(context), size: 24),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: Icon(FluentIcons.search_24_regular, color: AppTheme.getTextColor(context), size: 24),
          ),
        ],
        backgroundColor: isDarkMode ? Colors.black : AppColors.background,
        elevation: 0, // No shadow
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildCustomTabBar(),

                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: isDarkMode ? AppColors.divider.withAlpha(51) : AppColors.divider.withAlpha(128),
                ),

                Expanded(child: _selectedTabIndex == 0 ? _buildMessagesTab() : _buildActivitiesTab()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              isSelected: _selectedTabIndex == 0,
              label: 'Messages',
              onTap: () => setState(() => _selectedTabIndex = 0),
              isDarkMode: isDarkMode,
            ),
          ),
          // Expanded(
          //   child: _buildTabItem(
          //     isSelected: _selectedTabIndex == 1,
          //     label: 'Activities',
          //     onTap: () => setState(() => _selectedTabIndex = 1),
          //     isDarkMode: isDarkMode,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required bool isSelected, required String label, required VoidCallback onTap, required bool isDarkMode}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  isSelected
                      ? label == 'Messages'
                          ? AppColors.pink
                          : AppColors.primary
                      : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color:
                  isSelected
                      ? label == 'Messages'
                          ? AppColors.pink
                          : AppColors.primary
                      : isDarkMode
                      ? AppColors.textLight.withAlpha(179)
                      : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ConversationList(
      conversations: _conversations,
      onConversationTap: (conversation) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      },
      onConversationLongPress: (conversation) {
        print('Long pressed conversation: ${conversation.id}');
      },
    );
  }

  Widget _buildActivitiesTab() {
    return ActivityList(
      activities: _activities,
      onActivityTap: (activity) {
        print('Tapped on activity: ${activity.id}');
      },
    );
  }
}
