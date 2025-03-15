import 'package:flutter/cupertino.dart';
import '../../utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ProfileMentions extends StatelessWidget {
  final List<String> usernames;
  final Function(String) onUsernameTap;

  const ProfileMentions({
    required this.usernames,
    required this.onUsernameTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug print to verify usernames are being passed
    if (kDebugMode) {
      print('Building ProfileMentions with ${usernames.length} usernames: $usernames');
    }
    
    if (usernames.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: usernames.map((username) => _buildUsernameItem(username)).toList(),
      ),
    );
  }

  Widget _buildUsernameItem(String username) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
      child: GestureDetector(
        onTap: () => onUsernameTap(username),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.mention_24_regular,
              size: 16,
              color: AppColors.primary, // Pink color for username mentions
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                // Remove @ if present for display purposes
                username.startsWith('@') ? username.substring(1) : username,
                style: const TextStyle(
                  color: AppColors.primary, // Pink color for username mentions
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 