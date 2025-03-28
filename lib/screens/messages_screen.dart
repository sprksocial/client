import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/activities/activity_icon.dart';
import '../widgets/activities/activity_list.dart';
import '../widgets/common/development_overlay.dart';
import '../widgets/messages/message_list.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedTabIndex = 0;

  final List<MessageData> _messages = [
    MessageData(
      id: 'msg_1',
      username: 'Abstergo and 4 more',
      messagePreview: 'Ooooh thank you so much! ❤️',
      timeString: 'Wednesday',
      unreadCount: 1,
      avatarUrl: 'https://randomuser.me/api/portraits/men/41.jpg',
    ),
    MessageData(
      id: 'msg_2',
      username: 'Leslie Alexander',
      messagePreview: 'Makes to a illustrated on all and let me...',
      timeString: '17:33',
      unreadCount: null,
      avatarUrl: 'https://randomuser.me/api/portraits/women/72.jpg',
    ),
    MessageData(
      id: 'msg_3',
      username: 'Eleanor Pena',
      messagePreview: 'For sure! Let\'s hangout on Scheduled da...',
      timeString: '14:32',
      unreadCount: null,
      avatarUrl: 'https://randomuser.me/api/portraits/women/53.jpg',
    ),
    MessageData(
      id: 'msg_4',
      username: 'Devon Lane',
      messagePreview: 'Hey, I heard that you wanted...',
      timeString: '18:42',
      unreadCount: 3,
      avatarUrl: 'https://randomuser.me/api/portraits/men/86.jpg',
    ),
    MessageData(
      id: 'msg_5',
      username: 'Esther Howard',
      messagePreview: '😴 No 😴 I just went to bed right now, ta...',
      timeString: 'Yesterday',
      unreadCount: null,
      avatarUrl: 'https://randomuser.me/api/portraits/women/33.jpg',
    ),
    MessageData(
      id: 'msg_6',
      username: 'Arlene McCoy',
      messagePreview: 'But I\'m not really sure how it is but sure!...',
      timeString: 'Wednesday',
      unreadCount: null,
      avatarUrl: 'https://randomuser.me/api/portraits/women/90.jpg',
    ),
    MessageData(
      id: 'msg_7',
      username: 'Dianne Russell',
      messagePreview: 'No problem! See you then.',
      timeString: 'Tuesday',
      unreadCount: null,
      avatarUrl: 'https://randomuser.me/api/portraits/women/25.jpg',
    ),
  ];

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
            const DevelopmentOverlay(),
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
          Expanded(
            child: _buildTabItem(
              isSelected: _selectedTabIndex == 1,
              label: 'Activities',
              onTap: () => setState(() => _selectedTabIndex = 1),
              isDarkMode: isDarkMode,
            ),
          ),
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
    return MessageList(
      messages: _messages,
      onMessageTap: (message) {
        print('Tapped on message: ${message.id}');
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
