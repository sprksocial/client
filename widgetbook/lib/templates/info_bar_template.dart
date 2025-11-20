import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/templates/info_bar_template.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as wb;

@wb.UseCase(name: 'default', type: InfoBarTemplate)
Widget buildInfoBarTemplateUseCase(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InfoBarTemplate(
          displayName: 'Katie Middow',
          handle: 'katiemiddow.sprk.so',
          avatarUrl: 'https://picsum.photos/100',
          description: "This is my last creation, I'm happy to introduce...",
          informLabels: const ['Sensitive content'],
          showFollowButton: true,
          onFollow: () {},
          altAvailable: true,
          onAltTap: () {},
        ),
      ),
    ),
  );
}
