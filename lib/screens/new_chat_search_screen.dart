import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/sprk_client.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/common/user_avatar.dart';
import 'chat_screen.dart';

class NewChatSearchScreen extends StatefulWidget {
  const NewChatSearchScreen({super.key});

  @override
  State<NewChatSearchScreen> createState() => _NewChatSearchScreenState();
}

class _NewChatSearchScreenState extends State<NewChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  Timer? _debounce;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _chatService.setAuthService(authService);
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _error = '';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final sprkClient = SprkClient(authService);
      final response = await sprkClient.actor.searchActors(query);
      final actors = response.data['actors'] as List<dynamic>?;
      setState(() {
        _searchResults = actors ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search users';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(query);
    });
  }

  Future<void> _startNewChat(Map<String, dynamic> user) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserDid = authService.session?.did ?? 'current_user_id';
    final userDid = user['did'];
    
    if (userDid == currentUserDid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot start a chat with yourself'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final currentUser = ChatParticipant(
        id: currentUserDid,
        username: authService.session?.handle ?? 'current_user',
        displayName: 'You',
        isOnline: true,
      );

      final otherUser = ChatParticipant(
        id: userDid,
        username: user['handle'] ?? '',
        displayName: user['displayName'] ?? user['handle'] ?? '',
        avatarUrl: user['avatar'] ?? '',
        isOnline: false,
      );

      final dmConversation = Conversation(
        id: 'dm_${currentUserDid}_${userDid}_${DateTime.now().millisecondsSinceEpoch}',
        type: ConversationType.direct,
        participants: [currentUser, otherUser],
        lastActivity: DateTime.now(),
        unreadCount: 0,
      );

      final conversation = await _chatService.createOrGetConversation(dmConversation);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Started chat with ${otherUser.displayName ?? otherUser.username}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(conversation: conversation),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getAvatarColor(int seed) {
    final colors = [
      AppColors.primary,
      AppColors.pink,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[seed.abs() % colors.length];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'New Chat',
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            FluentIcons.arrow_left_24_regular,
            color: AppTheme.getTextColor(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 0.5,
            width: double.infinity,
            color: isDarkMode ? AppColors.divider.withAlpha(51) : AppColors.divider.withAlpha(128),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _onSearchChanged(value.trim()),
                             decoration: InputDecoration(
                 hintText: 'Search for users...',
                 hintStyle: TextStyle(
                   color: AppTheme.getSecondaryTextColor(context),
                 ),
                 prefixIcon: Icon(
                   FluentIcons.search_24_regular,
                   color: AppTheme.getSecondaryTextColor(context),
                 ),
                 filled: true,
                 fillColor: isDarkMode 
                   ? AppColors.darkPurple.withAlpha(128)
                   : AppColors.lightLavender.withAlpha(50),
                 enabledBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8),
                   borderSide: BorderSide(
                     color: isDarkMode 
                       ? AppColors.darkPurple.withAlpha(128)
                       : AppColors.border.withAlpha(128),
                   ),
                 ),
                 focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8),
                   borderSide: BorderSide(
                     color: AppColors.primary,
                     width: 2,
                   ),
                 ),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8),
                   borderSide: BorderSide(
                     color: isDarkMode 
                       ? AppColors.darkPurple.withAlpha(128)
                       : AppColors.border.withAlpha(128),
                   ),
                 ),
                 contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
               ),
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

    Widget _buildSearchResults() {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error.isNotEmpty) {
      return Center(
        child: Text(
          _error,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.search_24_regular,
              size: 64,
              color: AppTheme.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for users',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.getSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type a username to start a new chat',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.person_search_24_regular,
              size: 64,
              color: AppTheme.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.getSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different username',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final authService = Provider.of<AuthService>(context, listen: false);
        final currentDid = authService.session?.did;
        final userDid = user['did'];
        final isCurrentUser = userDid == currentDid;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _startNewChat(user),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode 
                  ? AppColors.darkPurple.withAlpha(102)
                  : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode 
                    ? AppColors.darkPurple.withAlpha(128)
                    : AppColors.border.withAlpha(128),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: user['avatar'] ?? '',
                    username: user['handle'] ?? '',
                    size: 48,
                    backgroundColor: _getAvatarColor((user['handle'] ?? '').hashCode),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['displayName'] ?? user['handle'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user['handle'] ?? ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                        if (user['description'] != null && user['description'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCurrentUser)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'You',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Icon(
                      FluentIcons.chat_24_regular,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 