import 'package:flutter/material.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/utils/text_formatter.dart';
import 'package:spark/src/features/posting/models/mention.dart';

class MentionController extends ChangeNotifier {
  MentionController({String text = ''})
    : _textController = TextEditingController(text: text);

  final TextEditingController _textController;
  final List<Mention> _mentions = [];

  TextEditingController get textController => _textController;
  String get text => _textController.text;
  List<Mention> get mentions => List.unmodifiable(_mentions);

  void addMention(Mention mention) {
    _mentions.add(mention);
    notifyListeners();
  }

  void removeMention(Mention mention) {
    _mentions.remove(mention);
    notifyListeners();
  }

  void clearMentions() {
    _mentions.clear();
    notifyListeners();
  }

  void replaceMentions(List<Mention> mentions) {
    _mentions
      ..clear()
      ..addAll(mentions);
    notifyListeners();
  }

  void clear() {
    _textController.clear();
    _mentions.clear();
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
