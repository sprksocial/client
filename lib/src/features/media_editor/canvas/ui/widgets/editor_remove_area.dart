import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

/// Drop target for removing a layer while it is being transformed.
class EditorRemoveArea extends StatelessWidget {
  const EditorRemoveArea({
    required this.removeAreaKey,
    required this.editor,
    required this.rebuildStream,
    required this.isLayerBeingTransformed,
    super.key,
  });

  final GlobalKey removeAreaKey;
  final ProImageEditorState editor;
  final Stream<void> rebuildStream;
  final bool isLayerBeingTransformed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: SafeArea(
      child: StreamBuilder<void>(
        stream: rebuildStream,
        builder: (context, snapshot) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: isLayerBeingTransformed
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    key: removeAreaKey,
                    height: kToolbarHeight,
                    width: kToolbarHeight,
                    decoration: BoxDecoration(
                      color: AppColors.red500.withAlpha(
                        editor.layerInteractionManager.hoverRemoveBtn
                            ? 255
                            : 100,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: AppIcon(
                        AppIconData.delete,
                        size: 28,
                        color: AppColors.greyWhite,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    ),
  );
}
