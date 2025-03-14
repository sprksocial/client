import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';

class EarlySupporterSheet extends StatelessWidget {
  const EarlySupporterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.deepPurple : CupertinoColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Match icon 
          SvgPicture.asset(
            'assets/images/match.svg',
            height: 48,
            width: 48,
            colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          ),
          
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Early supporter',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
                height: 1.5,
              ),
              children: const [
                TextSpan(text: 'This person was one of the '),
                TextSpan(
                  text: 'first matches to light our Spark',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '. Thanks to them for believing in us and supporting us when we were just an idea.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Bottom message
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
              ),
              children: const [
                TextSpan(text: 'Thanks to them, '),
                TextSpan(
                  text: 'Spark is a reality',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
} 