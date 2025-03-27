import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import 'feed_blur_widget.dart';

/// Example widget showing how to use the feed blur functionality
class FeedBlurExample extends StatelessWidget {
  const FeedBlurExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Blur Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showFeedSettings(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildFeedItem(context, index);
        },
      ),
    );
  }

  Widget _buildFeedItem(BuildContext context, int index) {
    final isNsfw = index % 3 == 0; // Example: Some content might be sensitive
    
    // Option 1: Using the FeedBlurWidget directly
    if (index % 2 == 0) {
      return FeedBlurWidget(
        forceBlur: isNsfw, // Force blur on NSFW content regardless of settings
        child: _buildItemContent(index),
      );
    }
    
    // Option 2: Using the extension method (more concise)
    return _buildItemContent(index).withFeedBlur(forceBlur: isNsfw);
  }
  
  Widget _buildItemContent(int index) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feed Item ${index + 1}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is some content that might be sensitive. '
              'The feed blur setting will apply a blur effect to this content '
              'if enabled or if it\'s marked as sensitive.',
            ),
            const Spacer(),
            if (index % 3 == 0)
              const Chip(label: Text('Sensitive Content')),
          ],
        ),
      ),
    );
  }

  void _showFeedSettings(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feed Blur Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable Feed Blur'),
              subtitle: const Text(
                'Blur sensitive content in your feed',
                style: TextStyle(fontSize: 12),
              ),
              value: settingsService.feedBlurEnabled,
              onChanged: (value) {
                settingsService.setFeedBlur(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 