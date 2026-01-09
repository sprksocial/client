import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/ui/widgets/user_avatar.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/profile/providers/profile_provider.dart';

class MessageInput extends ConsumerWidget {
  const MessageInput({
    required this.controller,
    required this.onSend,
    required this.otherDid,
    required this.imagePicker,
    super.key,
    this.isLoading = false,
  });

  final TextEditingController controller;
  final ImagePicker imagePicker;
  final VoidCallback onSend;
  final bool isLoading;
  final String otherDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).session;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                UserAvatar(
                  imageUrl: ref
                      .read(profileProvider(did: session?.did ?? ''))
                      .when(
                        data: (profileData) =>
                            profileData.profile?.avatar?.toString() ?? '',
                        error: (error, stackTrace) => '',
                        loading: () => '',
                      ),
                  username: session?.handle ?? '',
                  size: 28,
                ),
                const SizedBox(width: 8),
                // _AttachmentButton(
                //   state: state,
                //   notifier: notifier,
                //   context: context,
                //   borderColor: Theme.of(context).colorScheme.outline,
                //   textColor: Theme.of(context).colorScheme.onSurface,
                // ),
                // const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            onSend();
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            FluentIcons.send_24_filled,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
            // if (state.selectedImages.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 8.0),
            //     child: _SelectedImagesPreview(
            //       state: state,
            //       notifier: notifier,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}

// class _AttachmentButton extends StatelessWidget {
//   const _AttachmentButton({
//     required this.state,
//     required this.notifier,
//     required this.context,
//     required this.borderColor,
//     required this.textColor,
//   });

//   final EmbedInputState state;
//   final EmbedInput notifier;
//   final BuildContext context;
//   final Color borderColor;
//   final Color textColor;

//   @override
//   Widget build(BuildContext context) {
//     final bool canAddMoreImages = state.selectedImages.length < 4;
//     final bool enabled = !state.isPosting && canAddMoreImages;

//     return IconButton(
//       padding: EdgeInsets.zero,
//       visualDensity: VisualDensity.compact,
//       constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
//       onPressed: enabled ? () => notifier.pickMedia(context) : null,
//       tooltip: enabled
//           ? 'Add media (up to 4)'
//           : (state.isPosting ? 'Posting...' : 'Maximum files reached'),
//       icon: Icon(
//         FluentIcons.image_24_regular,
//         size: 24,
//         color: Theme.of(context).colorScheme.primary,
//       ),
//     );
//   }
// }

// class _SelectedImagesPreview extends StatelessWidget {
//   const _SelectedImagesPreview({
//     required this.state,
//     required this.notifier,
//   });

//   final EmbedInputState state;
//   final EmbedInput notifier;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 72,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: state.selectedImages.length,
//         itemBuilder: (context, index) {
//           final imageFile = state.selectedImages[index];
//           return Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 // Image Thumbnail with rounded corners and shadow
//                 Container(
//                   width: 72,
//                   height: 72,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Theme.of(context).colorScheme.outline,
//                       width: 0.5,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 26),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                     image: DecorationImage(
//                       image: FileImage(File(imageFile.path)),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 // Remove Button (top right)
//                 Positioned(
//                   top: 4,
//                   right: 4,
//                   child: Material(
//                     color: Colors.black.withValues(alpha: 128),
//                     shape: const CircleBorder(),
//                     child: InkWell(
//                       onTap: () => notifier.removeImage(index),
//                       customBorder: const CircleBorder(),
//                       child: Container(
//                         padding: const EdgeInsets.all(2),
//                         child: const Icon(
//                           FluentIcons.dismiss_16_filled,
//                           color: Colors.white,
//                           size: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
