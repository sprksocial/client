import 'dart:typed_data';

import 'package:bluesky/bluesky.dart' as bs;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
import '../services/sprk_client.dart';
import '../utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _loading = true;
  bs.ActorProfile? _bskyProfile;
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  dynamic _initialAvatar;
  dynamic _localAvatar;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadBskyProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadBskyProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final onboardingService = OnboardingService(authService);
    try {
      final profile = await onboardingService.getBskyProfile();
      if (!mounted) return;
      setState(() {
        _bskyProfile = profile;
        _loading = false;
        if (profile != null) {
          _displayNameController.text = profile.displayName ?? '';
          _descriptionController.text = profile.description ?? '';
          _initialAvatar = profile.avatar;
          _localAvatar = _initialAvatar;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bskyProfile = null;
        _loading = false;
      });
    }
  }

  Future<void> _handleSkipImport() async {
    setState(() => _loading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final onboardingService = OnboardingService(authService);
    await onboardingService.createEmptySparkProfile();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/import-follows');
  }

  Future<void> _handleCustomImport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final onboardingService = OnboardingService(authService);
    dynamic avatarToSend = _localAvatar;
    if (_localAvatar is Uint8List) {
      final sprkClient = SprkClient(authService);
      final resp = await sprkClient.repo.uploadBlob(_localAvatar as Uint8List);
      if (resp.status.code != 200) throw Exception('Failed to upload avatar blob');
      avatarToSend = resp.data.blob.toJson();
    }
    await onboardingService.importCustomProfile(
      displayName: _displayNameController.text.trim(),
      description: _descriptionController.text.trim(),
      avatar: avatarToSend,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/import-follows');
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _localAvatar = bytes);
  }

  String? _avatarUrlFrom(dynamic avatar) {
    if (avatar == null) return null;
    if (avatar is String) return avatar;
    final authService = Provider.of<AuthService>(context, listen: false);
    final did = authService.session?.did ?? '';
    final cid = avatar['ref']?['\$link'] as String?;
    if (did.isEmpty || cid == null || cid.isEmpty) return null;
    return 'https://media.sprk.so/img/tiny/$did/$cid';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    final bool isBytes = _localAvatar is Uint8List;
    final String? avatarUrl = !isBytes ? _avatarUrlFrom(_localAvatar) : null;
    final ImageProvider<Object>? avatarImage =
        isBytes
            ? MemoryImage(_localAvatar as Uint8List) as ImageProvider<Object>
            : avatarUrl != null
            ? NetworkImage(avatarUrl) as ImageProvider<Object>
            : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Complete your profile'),
        actions: [
          TextButton(
            onPressed: _handleSkipImport,
            style: TextButton.styleFrom(foregroundColor: AppColors.pink),
            child: const Text('Skip'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: avatarImage,
                        child: avatarImage == null ? const Icon(Icons.person, size: 50) : null,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_localAvatar != _initialAvatar)
                          IconButton(
                            icon: const Icon(Icons.undo, color: Colors.white),
                            onPressed: () => setState(() => _localAvatar = _initialAvatar),
                            tooltip: 'Revert avatar',
                          ),
                        if (_localAvatar != null)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => setState(() => _localAvatar = null),
                            tooltip: 'Remove avatar',
                          ),
                      ],
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
                    Stack(
                      children: [
                        TextFormField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            hintText: 'Display Name',
                            filled: true,
                            fillColor: backgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.pink),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.undo, size: 20),
                            onPressed: () => setState(() => _displayNameController.text = _bskyProfile?.displayName ?? ''),
                            tooltip: 'Revert display name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Bio',
                            filled: true,
                            fillColor: backgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.pink),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.undo, size: 20),
                            onPressed: () => setState(() => _descriptionController.text = _bskyProfile?.description ?? ''),
                            tooltip: 'Revert bio',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _handleCustomImport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [Text('Next'), SizedBox(width: 8), Icon(Icons.arrow_forward)],
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
    );
  }
}
