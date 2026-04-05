import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final List<Widget>? leadingWidgets;
  final List<Widget>? actionWidgets;
  final VoidCallback? onSendMessage;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;

  const InputField._({
    required this.controller,
    required this.hintText,
    required this.leadingWidgets,
    required this.actionWidgets,
    required this.onSendMessage,
    required this.onSubmitted,
    required this.textInputAction,
    required this.maxLines,
    required this.minLines,
    super.key,
  });

  const InputField.comment({
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
         onSendMessage: null,
         onSubmitted: null,
         textInputAction: null,
         maxLines: null,
         minLines: null,
       );

  const InputField.chat({
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
         actionWidgets: null,
         onSubmitted: null,
         textInputAction: null,
         maxLines: null,
         minLines: null,
       );

  const InputField.search({
    Key? key,
    TextEditingController? controller,
    String hintText = '',
    List<Widget>? leadingWidgets,
    List<Widget>? actionWidgets,
    ValueChanged<String>? onSubmitted,
    TextInputAction? textInputAction,
    int? maxLines,
    int? minLines,
  }) : this._(
         key: key,
         controller: controller,
         hintText: hintText,
         leadingWidgets: leadingWidgets,
         actionWidgets: actionWidgets,
         onSendMessage: null,
         onSubmitted: onSubmitted,
         textInputAction: textInputAction,
         maxLines: maxLines,
         minLines: minLines,
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? leading;
    if (leadingWidgets != null && leadingWidgets!.isNotEmpty) {
      leading = leadingWidgets!.length == 1
          ? leadingWidgets!.first
          : Row(mainAxisSize: MainAxisSize.min, children: leadingWidgets!);
    }

    final trailingWidgets = <Widget>[
      if (actionWidgets != null) ...actionWidgets!,
      if (onSendMessage != null)
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: onSendMessage,
          icon: AppIcons.send(size: 18, color: theme.colorScheme.onSurface),
        ),
    ];

    Widget? trailing;
    if (trailingWidgets.isNotEmpty) {
      trailing = trailingWidgets.length == 1
          ? trailingWidgets.first
          : Row(mainAxisSize: MainAxisSize.min, children: trailingWidgets);
    }

    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: leading,
        suffixIcon: trailing,
      ),
    );
  }
}
