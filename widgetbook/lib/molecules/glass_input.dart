import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/glass_input.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

final _chatControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});
final _chatMessagesProvider = StateProvider.autoDispose<List<String>>((_) => const []);

@UseCase(name: 'comment', type: GlassInput)
Widget buildGlassInputCommentUseCase(BuildContext context) {
  return Center(
    child: Container(
      constraints: BoxConstraints(maxWidth: context.knobs.double.slider(label: 'width', initialValue: 210, min: 160, max: 400, divisions: 24)),
      child: GlassInput.comment(
        hintText: context.knobs.string(label: 'hint', initialValue: 'Add a comment...'),
        leadingWidgets: [if (context.knobs.boolean(label: 'show_avatar', initialValue: true)) const CircleAvatar(radius: 10)],
        actionWidgets: [if (context.knobs.boolean(label: 'show_action_icon', initialValue: true)) AppIcons.smiley()],
      ),
    ),
  );
}

@UseCase(name: 'search', type: GlassInput)
Widget buildGlassInputSearchUseCase(BuildContext context) {
  return Center(
    child: SizedBox(
      width: context.knobs.double.slider(label: 'width', initialValue: 280, min: 160, max: 400, divisions: 24),
      child: GlassInput.search(
        hintText: context.knobs.string(label: 'hint', initialValue: 'Search...'),
        leadingWidgets: [const Icon(Icons.search, size: 18, color: Colors.white70)],
        actionWidgets: [
          if (context.knobs.boolean(label: 'show_clear', initialValue: true))
            GestureDetector(
              onTap: () => print('Clear pressed'),
              child: const Icon(Icons.close, size: 16, color: Colors.white70),
            ),
        ],
      ),
    ),
  );
}

@UseCase(name: 'chat_interactive', type: GlassInput)
Widget buildGlassInputChatInteractiveUseCase(BuildContext context) {
  return ProviderScope(
    child: Center(
      child: _ChatDemo(
        showSend: context.knobs.boolean(label: 'show_send', initialValue: true),
        placeholder: context.knobs.string(label: 'hint', initialValue: 'Message...'),
      ),
    ),
  );
}

class _ChatDemo extends ConsumerWidget {
  const _ChatDemo({required this.showSend, required this.placeholder});
  final bool showSend;
  final String placeholder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(_chatControllerProvider);
    final messages = ref.watch(_chatMessagesProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 160,
          width: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              border: Border.all(color: Colors.white.withAlpha(40)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(msg, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 320,
          child: GlassInput.chat(
            controller: controller,
            hintText: placeholder,
            leadingWidgets: const [Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white70)],
            onSendMessage: showSend
                ? () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    ref.read(_chatMessagesProvider.notifier).state = [...messages, text];
                    controller.clear();
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
