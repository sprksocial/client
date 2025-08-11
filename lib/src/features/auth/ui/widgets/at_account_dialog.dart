import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays an information icon for AT Accounts.
/// When tapped, it shows a dialog explaining what an AT Account is.
class ATAccountInfoIcon extends StatelessWidget {
  /// Creates an ATAccountInfoIcon widget.
  const ATAccountInfoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showATAccountDialog(context),
      child: Container(
        width: 18,
        height: 18,
        margin: const EdgeInsets.only(top: 4, left: 4),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: const Center(child: Icon(Icons.question_mark, size: 14, color: AppColors.primary)),
      ),
    );
  }

  /// Shows a dialog explaining what an AT Account is.
  void _showATAccountDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const _ATAccountDialog());
  }
}

/// Dialog explaining what an AT Account is.
class _ATAccountDialog extends StatelessWidget {
  const _ATAccountDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.only(top: 32, left: 24, right: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      title: Column(
        children: [
          SvgPicture.asset('assets/images/ataccount.svg', height: 40),
          const SizedBox(height: 18),
          const Text(
            'What is an AT Account?',
            style: TextStyle(color: AppColors.lightLavender, fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: const Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          'An ATAccount is your identity on the decentralized AT Protocol.\n\nUse it across Spark, Bluesky, and other ATmosphere apps with just one login.\n\nIt keeps your data safe, gives you control over your content, and ensures a seamless experience across platforms.',
          style: TextStyle(color: AppColors.lightLavender, fontSize: 16, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        _ATAccountDialogActions(
          onLearnMore: () async {
            context.router.maybePop();
            await launchUrl(Uri.parse('https://atproto.com/specs/account'));
          },
          onGotIt: () => context.router.maybePop(),
        ),
      ],
    );
  }
}

/// Actions for the AT Account dialog.
class _ATAccountDialogActions extends StatelessWidget {
  const _ATAccountDialogActions({required this.onGotIt, required this.onLearnMore});
  final VoidCallback onGotIt;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onLearnMore,
            child: const Text(
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
            onPressed: onGotIt,
            child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
