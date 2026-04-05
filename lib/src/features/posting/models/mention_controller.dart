import 'package:flutter/material.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/utils/text_formatter.dart';
import 'package:spark/src/features/posting/models/mention.dart';
import 'package:spark/src/features/posting/models/mention_text_editing_controller.dart';

class MentionController extends ChangeNotifier {
  MentionController({String text = ''})
    : _textController = MentionTextEditingController(text: text);

  final MentionTextEditingController _textController;
  final List<Mention> _mentions = [];

  MentionTextEditingController get textController => _textController;
  String get text => _textController.text;
  List<Mention> get mentions => List.unmodifiable(_mentions);

  void addMention(Mention mention) {
    _mentions.add(mention);
    _syncMentionsToController();
    notifyListeners();
  }

  void removeMention(Mention mention) {
    _mentions.remove(mention);
    _syncMentionsToController();
    notifyListeners();
  }

  void clearMentions() {
    _mentions.clear();
    _syncMentionsToController();
    notifyListeners();
  }

  void replaceMentions(List<Mention> mentions) {
    _mentions
      ..clear()
      ..addAll(mentions);
    _syncMentionsToController();
    notifyListeners();
  }

  /// Syncs the mentions list to the text controller for visual highlighting.
  void _syncMentionsToController() {
    _textController.mentions = List.unmodifiable(_mentions);
  }

  void clear() {
    _textController.clear();
    _mentions.clear();
    _syncMentionsToController();
    notifyListeners();
  }

  List<Facet> buildFacets() {
    return TextFormatter.buildMentionFacets(_mentions);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
