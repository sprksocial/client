import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../widgets/messages/message_list.dart';
import '../widgets/activities/activity_list.dart';
import '../widgets/activities/activity_icon.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedTabIndex = 0;

  // Mock data for messages
  final List<MessageData> _messages = List.generate(
    15,
    (index) => MessageData(
      id: 'msg_$index',
      username: 'user${index + 1}',
      messagePreview: index % 2 == 0 ? 'Check out my latest video! 🔥' : 'Hey, how are you doing?',
      timeString:
          index % 4 == 0
              ? 'Just now'
              : index % 4 == 1
              ? '5m ago'
              : index % 4 == 2
              ? '1h ago'
              : 'Yesterday',
      unreadCount: index % 3 == 0 ? 1 : null,
    ),
  );

  // Mock data for activities
  final List<ActivityData> _activities = List.generate(15, (index) {
    final ActivityType type = ActivityType.values[index % ActivityType.values.length];
    String? additionalInfo;

    if (type == ActivityType.comment) {
      additionalInfo = 'Wow, this looks amazing! 🔥';
    } else if (type == ActivityType.like) {
      additionalInfo = null;
    } else {
      additionalInfo = null;
    }

    return ActivityData(
      id: 'act_$index',
      username: 'user${index + 1}',
      type: type,
      timeString:
          index % 4 == 0
              ? 'Just now'
              : index % 4 == 1
              ? '5m ago'
              : index % 4 == 2
              ? '1h ago'
              : 'Yesterday',
      additionalInfo: additionalInfo,
      targetContentId: 'content_$index',
    );
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context, false),
      appBar: AppBar(
        title: Text('Messages', style: TextStyle(color: AppTheme.getTextColor(context), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // Action for new message
            },
            icon: Icon(FluentIcons.edit_24_regular, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: isDarkMode ? AppColors.darkBackground.withAlpha(242) : AppColors.background,
        elevation: 0, // No shadow
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom tab selector (full width and minimalistic)
            _buildCustomTabBar(),

            // Divider below tabs
            Container(
              height: 0.5,
              width: double.infinity,
              color: isDarkMode ? AppColors.divider.withAlpha(51) : AppColors.divider.withAlpha(128),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: SearchBar(
                hintText: 'Search',
                leading: Icon(FluentIcons.search_24_regular, color: AppTheme.getSecondaryTextColor(context), size: 18),
                onChanged: (value) {
                  // Handle search
                },
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(
                  isDarkMode ? AppColors.deepPurple.withAlpha(128) : AppColors.lightLavender.withAlpha(77),
                ),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),

            // Content based on selected tab
            Expanded(child: _selectedTabIndex == 0 ? _buildMessagesTab() : _buildActivitiesTab()),
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
          border: Border(bottom: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color:
                  isSelected
                      ? AppColors.primary
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
        // Handle message tap
        print('Tapped on message: ${message.id}');
      },
    );
  }

  Widget _buildActivitiesTab() {
    return ActivityList(
      activities: _activities,
      onActivityTap: (activity) {
        // Handle activity tap
        print('Tapped on activity: ${activity.id}');
      },
    );
  }
}
