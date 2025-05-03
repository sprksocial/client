import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';

class ATAccountInfoIcon extends StatelessWidget {
  const ATAccountInfoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showATAccountDialog(context),
      child: Container(
        width: 18,
        height: 18,
        margin: const EdgeInsets.only(top: 4, left: 4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.question_mark, size: 14, color: AppColors.primary),
        ),
      ),
    );
  }

  void _showATAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        title: Column(
          children: [
            SvgPicture.asset(
              'assets/images/ataccount.svg',
              height: 40,
            ),
            const SizedBox(height: 18),
            Text(
              'What is an AT Account?',
              style: TextStyle(
                color: AppColors.lightLavender,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            'An ATaccount is your identity on the decentralized AT Protocol.\n\nUse it across Spark, Bluesky, and other ATmosphere apps with just one login.\n\nIt keeps your data safe, gives you control over your content, and ensures a seamless experience across platforms.',
            style: TextStyle(color: AppColors.lightLavender, fontSize: 16, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await launchUrl(Uri.parse('https://atproto.com/specs/account'));
                  },
                  child: Text(
                    'Learn more',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 