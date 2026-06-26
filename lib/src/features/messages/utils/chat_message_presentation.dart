import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';

extension ChatMessagePresentation on ChatMessageView {
  MessageView? get textMessage => switch (this) {
    ChatMessageViewMessage(:final data) => data,
    ChatMessageViewDeleted() || ChatMessageViewUnsupported() => null,
  };

  String previewText({
    required AppLocalizations l10n,
    required String Function(SenderView sender) embedPreview,
  }) {
    return switch (this) {
      ChatMessageViewMessage(:final data) => _textMessagePreview(
        data,
        embedPreview: embedPreview,
      ),
      ChatMessageViewDeleted() => l10n.messageDeleted,
      ChatMessageViewUnsupported() => l10n.messageUnsupported,
    };
  }

  String? systemLabel(AppLocalizations l10n) {
    return switch (this) {
      ChatMessageViewMessage() => null,
      ChatMessageViewDeleted() => l10n.messageDeleted,
      ChatMessageViewUnsupported() => l10n.messageUnsupported,
    };
  }
}

String _textMessagePreview(
  MessageView message, {
  required String Function(SenderView sender) embedPreview,
}) {
  final text = message.text.trim();
  if (text.isNotEmpty) {
    return text;
  }

  final embed = message.embed;
  if (embed != null && embed.isNotEmpty) {
    return embedPreview(message.sender);
  }

  return '';
}
