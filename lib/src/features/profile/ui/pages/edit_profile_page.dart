import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/profile/providers/edit_profile_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_avatar_editor.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_save_button.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_text_field.dart';
import 'package:get_it/get_it.dart';

/// Edit profile page that allows users to update their profile information
class EditProfilePage extends ConsumerWidget {
  final Profile profile;
  
  /// Create a page to edit a profile
  const EditProfilePage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logger = GetIt.instance<LogService>().getLogger('EditProfilePage');
    
    // Using AsyncValue to handle the profile edit state
    final editProfileState = ref.watch(editProfileProvider(profile));
    final editProfileNotifier = ref.read(editProfileProvider(profile).notifier);
    
    // Create a form key to validate the form
    final formKey = GlobalKey<FormState>();
    
    // Get the theme data
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'), 
        backgroundColor: bgColor, 
        elevation: 0
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          color: bgColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  ProfileAvatarEditor(
                    state: editProfileState,
                    notifier: editProfileNotifier,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    initialValue: editProfileState.displayName,
                    hintText: 'Display Name',
                    onChanged: editProfileNotifier.updateDisplayName,
                    bgColor: bgColor,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    initialValue: editProfileState.description,
                    hintText: 'Description',
                    onChanged: editProfileNotifier.updateDescription,
                    bgColor: bgColor,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ProfileSaveButton(
                    state: editProfileState,
                    notifier: editProfileNotifier,
                    formKey: formKey,
                    logger: logger,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}