import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class GlassInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final List<Widget>? leadingWidgets;
  final List<Widget>? actionWidgets;
  final VoidCallback? onSendMessage;
  final double borderRadius;

  const GlassInput._({
    required this.controller,
    required this.hintText,
    required this.leadingWidgets,
    required this.actionWidgets,
    required this.onSendMessage,
    required this.borderRadius,
    super.key,
  });

  const GlassInput.comment({
    Key? key,
    TextEditingController? controller,
    String hintText = '',
    List<Widget>? leadingWidgets,
    List<Widget>? actionWidgets,
  }) : this._(
         key: key,
         controller: controller,
         hintText: hintText,
         leadingWidgets: leadingWidgets,
         actionWidgets: actionWidgets,
         borderRadius: 50,
         onSendMessage: null,
       );

  const GlassInput.chat({
    Key? key,
    TextEditingController? controller,
    String hintText = '',
    List<Widget>? leadingWidgets,
    VoidCallback? onSendMessage,
  }) : this._(
         key: key,
         controller: controller,
         hintText: hintText,
         leadingWidgets: leadingWidgets,
         onSendMessage: onSendMessage,
         borderRadius: 25,
         actionWidgets: null,
       );

  const GlassInput.search({
    Key? key,
    TextEditingController? controller,
    String hintText = '',
    List<Widget>? leadingWidgets,
    List<Widget>? actionWidgets,
  }) : this._(
         key: key,
         controller: controller,
         hintText: hintText,
         leadingWidgets: leadingWidgets,
         actionWidgets: actionWidgets,
         borderRadius: 15,
         onSendMessage: null,
       );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(37) : Colors.black.withAlpha(37),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (leadingWidgets != null) ...leadingWidgets!,

                if (leadingWidgets != null && leadingWidgets!.isNotEmpty) const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: controller,
                    style: AppTypography.textExtraSmallThin,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTypography.textExtraSmallThin,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusColor: Colors.transparent,
                      fillColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    ),
                  ),
                ),

                if (actionWidgets != null && actionWidgets!.isNotEmpty) const SizedBox(width: 8),

                if (actionWidgets != null) ...actionWidgets!,

                if (onSendMessage != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onSendMessage,
                    icon: AppIcons.send(size: 18, color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
