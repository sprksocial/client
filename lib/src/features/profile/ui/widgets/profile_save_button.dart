import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/profile/providers/edit_profile_state.dart';
import 'package:sparksocial/src/features/profile/providers/edit_profile_provider.dart';

/// Button widget for saving profile changes
class ProfileSaveButton extends StatelessWidget {
  /// Current state of the profile being edited
  final EditProfileState state;

  /// The notifier to trigger actions on the profile
  final EditProfile notifier;

  /// Form key to validate the form before saving
  final GlobalKey<FormState> formKey;

  /// Logger for error reporting
  final SparkLogger logger;

  /// Creates a profile save button
  const ProfileSaveButton({super.key, required this.state, required this.notifier, required this.formKey, required this.logger});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            state.isSaving
                ? null
                : () async {
                  if (!formKey.currentState!.validate()) return;

                  try {
                    final result = await notifier.saveProfile();
                    if (result && context.mounted) {
                      context.router.maybePop(true);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
                    }
                  } catch (e) {
                    logger.e('Error saving profile', error: e);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
                    }
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            state.isSaving
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2),
                )
                : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
