import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:sparksocial/src/core/ui/widgets/widgets.dart';

@widgetbook.UseCase(name: 'default', type: GlassButton)
Widget useCaseGlassButton(BuildContext context) {
  return GlassButton(text: context.knobs.string(label: 'Button Text'),);
}
