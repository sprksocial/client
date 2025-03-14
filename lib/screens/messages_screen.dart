import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
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
      messagePreview: index % 2 == 0
          ? 'Check out my latest video! 🔥'
          : 'Hey, how are you doing?',
      timeString: index % 4 == 0
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
  final List<ActivityData> _activities = List.generate(
    15,
    (index) {
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
        timeString: index % 4 == 0
            ? 'Just now'
            : index % 4 == 1
                ? '5m ago'
                : index % 4 == 2
                    ? '1h ago'
                    : 'Yesterday',
        additionalInfo: additionalInfo,
        targetContentId: 'content_$index',
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(context, false),
      navigationBar: CupertinoNavigationBar(
        middle: Text('Messages', style: TextStyle(color: AppTheme.getTextColor(context))),
        trailing: Icon(Ionicons.create_outline, color: AppTheme.getTextColor(context)),
        backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Tab selector
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CupertinoSegmentedControl<int>(
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text('Messages'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text('Activities'),
                  ),
                },
                onValueChanged: (value) {
                  setState(() {
                    _selectedTabIndex = value;
                  });
                },
                groupValue: _selectedTabIndex,
                selectedColor: AppColors.primary,
                unselectedColor: isDarkMode ? AppColors.deepPurple : AppColors.lightLavender,
                borderColor: AppColors.primary,
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                placeholder: 'Search',
                prefixIcon: Icon(
                  Ionicons.search_outline,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
                onChanged: (value) {
                  // Handle search
                },
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                ),
                placeholderStyle: TextStyle(
                  color: AppTheme.getSecondaryTextColor(context),
                ),
                backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.white,
              ),
            ),

            // Content based on selected tab
            Expanded(
              child: _selectedTabIndex == 0
                ? _buildMessagesTab()
                : _buildActivitiesTab(),
            ),
          ],
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