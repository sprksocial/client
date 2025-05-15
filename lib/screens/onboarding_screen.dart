import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
import '../services/settings_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_text_field.dart';
import 'follow_mode_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _loading = true;
  Map<String, dynamic>? _bskyProfile;
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
          final value = profile['value'] as Map<String, dynamic>?;
          if (value != null) {
            _displayNameController.text = value['displayName'] as String? ?? '';
            _descriptionController.text = value['description'] as String? ?? '';
            _initialAvatar = value['avatar'];
            _localAvatar = _initialAvatar;
          }
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

  Future<void> _handleCustomImport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      if (_bskyProfile == null) {
        final settingsService = Provider.of<SettingsService>(context, listen: false);
        await settingsService.setFollowMode('sprk');
        if (!mounted) return;
        final authService = Provider.of<AuthService>(context, listen: false);
        final onboardingService = OnboardingService(authService);

        await onboardingService.finalizeProfileCreation(
          displayName: _displayNameController.text.trim(),
          description: _descriptionController.text.trim(),
          avatar: _localAvatar,
        );

        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => FollowModeScreen(
                  displayName: _displayNameController.text.trim(),
                  description: _descriptionController.text.trim(),
                  avatar: _localAvatar,
                ),
          ),
        );
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error processing profile: ${e.toString()}')));
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
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
        centerTitle: true,
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
                          GestureDetector(
                            onTap: () => setState(() => _localAvatar = _initialAvatar),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.undo, size: 16, color: Colors.white),
                            ),
                          ),
                        if (_localAvatar != null)
                          GestureDetector(
                            onTap: () => setState(() => _localAvatar = null),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
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
                    CustomTextField(
                      controller: _displayNameController,
                      hintText: 'Display Name',
                      fillColor: backgroundColor,
                      onUndo: () {
                        if (_bskyProfile != null) {
                          final value = _bskyProfile!['value'] as Map<String, dynamic>?;
                          setState(() => _displayNameController.text = value?['displayName'] as String? ?? '');
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Display Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Bio',
                      fillColor: backgroundColor,
                      maxLines: 3,
                      onUndo: () {
                        if (_bskyProfile != null) {
                          final value = _bskyProfile!['value'] as Map<String, dynamic>?;
                          setState(() => _descriptionController.text = value?['description'] as String? ?? '');
                        }
                      },
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
