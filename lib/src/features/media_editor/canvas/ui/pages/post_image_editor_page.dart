import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class PostImageEditorPage extends StatelessWidget {
  const PostImageEditorPage({required this.source, super.key});

  final XFile source;

  static Future<XFile?> open(BuildContext context, XFile source) {
    return Navigator.of(context).push<XFile?>(
      MaterialPageRoute(builder: (_) => PostImageEditorPage(source: source)),
    );
  }

  Future<void> _complete(BuildContext context, List<int> bytes) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'spark_edited_$timestamp.jpg';
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pop(XFile(file.path, mimeType: 'image/jpeg', name: filename));
  }

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(source.path),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) => _complete(context, bytes),
      ),
    );
  }
}
