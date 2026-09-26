import 'package:material_ui/material_ui.dart';
import 'package:spark/src/core/design_system/theme/action_icon_theme.dart';
import 'package:spark/src/core/design_system/theme/color_scheme.dart';
import 'package:spark/src/core/design_system/theme/text_theme.dart';

/// Keeps the media editors dark regardless of the selected app theme.
ThemeData get editorTheme => ThemeData(
  useMaterial3: true,
  actionIconTheme: appActionIconTheme,
  colorScheme: AppColorScheme.dark,
  textTheme: AppTextTheme.dark,
);
