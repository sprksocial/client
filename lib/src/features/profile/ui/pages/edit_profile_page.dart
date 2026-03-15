import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/ui/widgets/custom_text_field.dart';
import 'package:spark/src/features/profile/providers/edit_profile_provider.dart';

/// Edit profile page that allows users to update their profile information
@RoutePage()
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({required this.profile, super.key});
  final ProfileViewDetailed profile;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _descriptionController = TextEditingController();

    // Initialize controllers with current profile data
    _displayNameController.text = widget.profile.displayName ?? '';
    _descriptionController.text = widget.profile.description ?? '';

    // Add listeners to update state when text changes
    _displayNameController.addListener(() {
      final editProfileNotifier = ref.read(
        editProfileProvider(widget.profile).notifier,
      );
      final currentState = ref.read(editProfileProvider(widget.profile));
      if (_displayNameController.text != currentState.displayName) {
        editProfileNotifier.updateDisplayName(_displayNameController.text);
      }
    });

    _descriptionController.addListener(() {
      final editProfileNotifier = ref.read(
        editProfileProvider(widget.profile).notifier,
      );
      final currentState = ref.read(editProfileProvider(widget.profile));
      if (_descriptionController.text != currentState.description) {
        editProfileNotifier.updateDescription(_descriptionController.text);
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final editProfileNotifier = ref.read(
        editProfileProvider(widget.profile).notifier,
      );
      await editProfileNotifier.saveProfile();

      if (!mounted) return;

      // Go back to previous screen
      context.router.pop();
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editProfileState = ref.watch(editProfileProvider(widget.profile));
    final editProfileNotifier = ref.read(
      editProfileProvider(widget.profile).notifier,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen(editProfileProvider(widget.profile), (_, next) {
      if (_displayNameController.text != next.displayName) {
        _displayNameController.text = next.displayName;
      }
      if (_descriptionController.text != next.description) {
        _descriptionController.text = next.description;
      }
    });

    ImageProvider<Object>? avatarImageProvider;

    if (editProfileState.localAvatar != null) {
      if (editProfileState.localAvatar is List<int>) {
        avatarImageProvider = MemoryImage(
          Uint8List.fromList(editProfileState.localAvatar as List<int>),
        );
      } else if (editProfileState.localAvatar is String &&
          (editProfileState.localAvatar as String).isNotEmpty) {
        avatarImageProvider = NetworkImage(
          editProfileState.localAvatar as String,
        );
      } else {
        if (editProfileState.localAvatar.toString().isNotEmpty) {
          final avatarUrl = editProfileState.localAvatar.toString();
          avatarImageProvider = NetworkImage(avatarUrl);
        }
      }
    } else if (widget.profile.avatar != null) {
      final avatarUrl = widget.profile.avatar!.toString();
      if (avatarUrl.isNotEmpty) {
        avatarImageProvider = NetworkImage(avatarUrl);
      }
    }

    final hasLocalAvatar =
        editProfileState.localAvatar != null &&
        editProfileState.localAvatar != editProfileState.initialAvatar;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.pageTitleEditProfile),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: const AutoLeadingButton(),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: editProfileNotifier.pickAvatar,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: avatarImageProvider,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            child: avatarImageProvider == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasLocalAvatar)
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: GestureDetector(
                                    onTap: editProfileNotifier.revertAvatar,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.undo,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _displayNameController,
                          hintText: l10n.hintDisplayName,
                          fillColor:
                              theme.inputDecorationTheme.fillColor ??
                              theme.colorScheme.surface,
                          onUndo:
                              (widget.profile.displayName != null &&
                                  _displayNameController.text !=
                                      (widget.profile.displayName ?? ''))
                              ? () {
                                  _displayNameController.text =
                                      widget.profile.displayName ?? '';
                                  editProfileNotifier.updateDisplayName(
                                    widget.profile.displayName ?? '',
                                  );
                                }
                              : null,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.inputErrorRequired;
                            }
                            if (value.trim().length > 64) {
                              return 'Display Name cannot exceed 64 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _descriptionController,
                          hintText: l10n.hintBio,
                          fillColor:
                              theme.inputDecorationTheme.fillColor ??
                              theme.colorScheme.surface,
                          maxLines: 3,
                          onUndo:
                              (widget.profile.description != null &&
                                  _descriptionController.text !=
                                      (widget.profile.description ?? ''))
                              ? () {
                                  _descriptionController.text =
                                      widget.profile.description ?? '';
                                  editProfileNotifier.updateDescription(
                                    widget.profile.description ?? '',
                                  );
                                }
                              : null,
                          validator: (value) {
                            if (value != null && value.trim().length > 256) {
                              return 'Bio cannot exceed 256 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSaveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l10n.buttonSave),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.save),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
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
