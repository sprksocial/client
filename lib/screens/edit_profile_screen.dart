import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/sprk_client.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/common/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  dynamic _initialAvatar;
  dynamic _localAvatar;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initialAvatar = widget.profile.avatarUrl;
    _localAvatar = _initialAvatar;
    _displayNameController = TextEditingController(text: widget.profile.displayName ?? '');
    _descriptionController = TextEditingController(text: widget.profile.description ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _localAvatar = bytes;
    });
  }

  void _revertAvatar() {
    setState(() {
      _localAvatar = _initialAvatar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppTheme.getBackgroundColor(context);
    ImageProvider<Object>? avatarImageProvider;
    if (_localAvatar is Uint8List) {
      avatarImageProvider = MemoryImage(_localAvatar as Uint8List);
    } else if (_localAvatar is String) {
      avatarImageProvider = CachedNetworkImageProvider(_localAvatar as String);
    } else {
      avatarImageProvider = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: bgColor, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: avatarImageProvider,
                        child: avatarImageProvider == null ? const Icon(Icons.person, size: 50) : null,
                      ),
                    ),
                    if (_localAvatar is Uint8List)
                      IconButton(icon: const Icon(Icons.undo), onPressed: _revertAvatar, color: AppColors.pink),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(controller: _displayNameController, hintText: 'Display Name', fillColor: bgColor),
                const SizedBox(height: 16),
                CustomTextField(controller: _descriptionController, hintText: 'Description', fillColor: bgColor, maxLines: 3),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Save',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final profileService = Provider.of<ProfileService>(context, listen: false);
      final client = SprkClient(authService);
      dynamic avatarToSend;
      if (_localAvatar is Uint8List) {
        // Upload new avatar blob
        final respBlob = await client.repo.uploadBlob(_localAvatar as Uint8List);
        if (respBlob.status.code != 200) {
          throw Exception('Failed to upload avatar blob');
        }
        avatarToSend = respBlob.data.blob.toJson();
      } else {
        // No new avatar selected: fetch existing record to get blob ref
        final uri = AtUri.parse('at://${widget.profile.did}/so.sprk.actor.profile/self');
        final recRes = await client.repo.getRecord(uri: uri);
        final recordData = recRes.data.value as Map<String, dynamic>;
        avatarToSend = recordData['avatar'];
      }
      await profileService.updateProfile(
        displayName: _displayNameController.text.trim(),
        description: _descriptionController.text.trim(),
        avatar: avatarToSend,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
