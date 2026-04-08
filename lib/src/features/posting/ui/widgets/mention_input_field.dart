import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/molecules/input_field.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/utils/image_url_resolver.dart';
import 'package:spark/src/core/utils/text_formatter.dart';
import 'package:spark/src/features/posting/models/mention.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_provider.dart';

class MentionInputField extends ConsumerStatefulWidget {
  const MentionInputField({
    required this.controller,
    required this.onMentionsChanged,
    required this.hintText,
    this.maxChars = AppConstants.postDescriptionMaxChars,
    this.maxLines = 5,
    this.minLines = 1,
    this.focusNode,
    this.enabled = true,
    super.key,
  });

  final MentionController controller;
  final ValueChanged<List<Mention>> onMentionsChanged;
  final String hintText;
  final int maxChars;
  final int maxLines;
  final int minLines;
  final FocusNode? focusNode;
  final bool enabled;

  @override
  ConsumerState<MentionInputField> createState() => _MentionInputFieldState();
}

class _MentionInputFieldState extends ConsumerState<MentionInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  int? _queryStartIndex;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _previousText = widget.controller.text;
    widget.controller.textController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant MentionInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.textController.removeListener(_onTextChanged);
      _previousText = widget.controller.text;
      widget.controller.textController.addListener(_onTextChanged);
    }

    if (!widget.enabled && oldWidget.enabled != widget.enabled) {
      _hideSuggestions(clearTypeahead: true);
    }
  }

  @override
  void dispose() {
    widget.controller.textController.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text != _previousText) {
      _syncMentions(previousText: _previousText, currentText: text);
      _previousText = text;
    }

    if (!widget.enabled) {
      _hideSuggestions(clearTypeahead: true);
      return;
    }

    final cursorPosition = widget.controller.textController.selection.start;
    if (cursorPosition >= 0) {
      _detectMentionQuery(text, cursorPosition);
    }
  }

  void _hideSuggestions({required bool clearTypeahead}) {
    final hadSuggestions = _showSuggestions || _queryStartIndex != null;

    if (clearTypeahead) {
      ref.read(actorTypeaheadProvider.notifier).clear();
    }

    if (!hadSuggestions) {
      return;
    }

    if (mounted) {
      setState(() {
        _showSuggestions = false;
        _queryStartIndex = null;
      });
      return;
    }

    _showSuggestions = false;
    _queryStartIndex = null;
  }

  void _syncMentions({
    required String previousText,
    required String currentText,
  }) {
    final validMentions = _recalculateMentions(
      previousText: previousText,
      currentText: currentText,
    );
    if (_sameMentions(validMentions, widget.controller.mentions)) {
      return;
    }

    widget.controller.replaceMentions(validMentions);
    widget.onMentionsChanged(validMentions);
  }

  List<Mention> _recalculateMentions({
    required String previousText,
    required String currentText,
  }) {
    if (widget.controller.mentions.isEmpty) {
      return const [];
    }

    final editRange = _computeEditRange(previousText, currentText);
    final validMentions = <Mention>[];
    for (final mention in widget.controller.mentions) {
      final oldStart = TextFormatter.byteIndexToCharIndex(
        previousText,
        mention.byteStart,
      );
      final mentionToken = '@${mention.handle}';
      var newStart = oldStart;

      if (editRange != null) {
        if (editRange.oldEnd <= oldStart) {
          newStart += editRange.delta;
        } else {
          final oldEnd = TextFormatter.byteIndexToCharIndex(
            previousText,
            mention.byteEnd,
          );
          if (editRange.start < oldEnd) {
            continue;
          }
        }
      }

      final newEnd = newStart + mentionToken.length;
      if (newStart < 0 || newEnd > currentText.length) {
        continue;
      }

      if (currentText.substring(newStart, newEnd) != mentionToken) {
        continue;
      }

      validMentions.add(
        mention.copyWith(
          byteStart: TextFormatter.charIndexToByteIndex(currentText, newStart),
          byteEnd: TextFormatter.charIndexToByteIndex(currentText, newEnd),
        ),
      );
    }

    return validMentions;
  }

  ({int start, int oldEnd, int delta})? _computeEditRange(
    String previousText,
    String currentText,
  ) {
    if (previousText == currentText) {
      return null;
    }

    var prefixLength = 0;
    final maxPrefix = previousText.length < currentText.length
        ? previousText.length
        : currentText.length;
    while (prefixLength < maxPrefix &&
        previousText.codeUnitAt(prefixLength) ==
            currentText.codeUnitAt(prefixLength)) {
      prefixLength++;
    }

    var previousSuffixStart = previousText.length;
    var currentSuffixStart = currentText.length;
    while (previousSuffixStart > prefixLength &&
        currentSuffixStart > prefixLength &&
        previousText.codeUnitAt(previousSuffixStart - 1) ==
            currentText.codeUnitAt(currentSuffixStart - 1)) {
      previousSuffixStart--;
      currentSuffixStart--;
    }

    return (
      start: prefixLength,
      oldEnd: previousSuffixStart,
      delta:
          (currentSuffixStart - prefixLength) -
          (previousSuffixStart - prefixLength),
    );
  }

  bool _sameMentions(List<Mention> next, List<Mention> current) {
    if (next.length != current.length) {
      return false;
    }

    for (var i = 0; i < next.length; i++) {
      if (next[i] != current[i]) {
        return false;
      }
    }

    return true;
  }

  void _detectMentionQuery(String text, int cursorPosition) {
    if (cursorPosition <= 0 || cursorPosition > text.length) {
      _hideSuggestions(clearTypeahead: true);
      return;
    }

    var atIndex = -1;
    for (var i = cursorPosition - 1; i >= 0; i--) {
      final char = text[i];
      if (char == '@') {
        atIndex = i;
        break;
      }
      if (char == ' ' || char == '\n') break;
    }

    if (atIndex == -1) {
      _hideSuggestions(clearTypeahead: true);
      return;
    }

    if (atIndex > 0) {
      final prevChar = text[atIndex - 1];
      if (prevChar != ' ' && prevChar != '\n') {
        _hideSuggestions(clearTypeahead: true);
        return;
      }
    }

    final query = text.substring(atIndex + 1, cursorPosition);
    setState(() {
      _showSuggestions = query.isNotEmpty;
      _queryStartIndex = atIndex;
    });

    if (query.isNotEmpty) {
      ref.read(actorTypeaheadProvider.notifier).updateQuery(query);
    }
  }

  void _onSuggestionSelected(String handle, String did) {
    final startIndex = _queryStartIndex;
    if (startIndex == null) return;

    final textController = widget.controller.textController;
    final text = textController.text;
    final cursorPosition = textController.selection.start;
    final cursor = cursorPosition >= 0 ? cursorPosition : text.length;

    var endIndex = cursor;
    while (endIndex < text.length &&
        text[endIndex] != ' ' &&
        text[endIndex] != '\n') {
      endIndex++;
    }

    final mentionToken = '@$handle';
    final mentionText = '$mentionToken ';
    final newText = text.replaceRange(startIndex, endIndex, mentionText);
    textController.text = newText;
    textController.selection = TextSelection.collapsed(
      offset: startIndex + mentionText.length,
    );

    final byteStart = TextFormatter.charIndexToByteIndex(newText, startIndex);
    final byteEnd = TextFormatter.charIndexToByteIndex(
      newText,
      startIndex + mentionToken.length,
    );

    final mention = Mention(
      handle: handle,
      did: did,
      byteStart: byteStart,
      byteEnd: byteEnd,
    );

    final dedupedMentions =
        widget.controller.mentions
            .where(
              (existing) =>
                  existing.byteStart != mention.byteStart ||
                  existing.byteEnd != mention.byteEnd,
            )
            .toList()
          ..add(mention);
    widget.controller.replaceMentions(dedupedMentions);
    widget.onMentionsChanged(widget.controller.mentions);

    ref.read(actorTypeaheadProvider.notifier).clear();

    setState(() {
      _showSuggestions = false;
      _queryStartIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeaheadState = ref.watch(actorTypeaheadProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InputField.search(
          controller: widget.controller.textController,
          focusNode: widget.focusNode ?? _focusNode,
          hintText: widget.hintText,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          enabled: widget.enabled,
        ),
        if (widget.enabled &&
            _showSuggestions &&
            typeaheadState.results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withAlpha(128),
                ),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: typeaheadState.results.length,
              itemBuilder: (context, index) {
                final actor = typeaheadState.results[index];
                final avatarUrl = resolveImageUrlObject(actor.avatar);
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  title: Text(
                    actor.displayName ?? actor.handle,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    '@${actor.handle}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => _onSuggestionSelected(actor.handle, actor.did),
                );
              },
            ),
          ),
        if (widget.enabled && _showSuggestions && typeaheadState.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}
