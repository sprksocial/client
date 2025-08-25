import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:widgetbook_workspace/tokens/colors_preview.dart';

@UseCase(
  name: 'Default',
  type: AppColors,
)
Widget buildAppColorsUseCase(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColorPalettePreview(
            name: 'Primary',
            colors: [
              AppColors.primary50,
              AppColors.primary100,
              AppColors.primary200,
              AppColors.primary300,
              AppColors.primary400,
              AppColors.primary500,
              AppColors.primary600,
              AppColors.primary700,
              AppColors.primary800,
              AppColors.primary900,
            ],
          ),
          SizedBox(height: 24),
          ColorPalettePreview(
            name: 'Grey',
            colors: [
              AppColors.grey50,
              AppColors.grey100,
              AppColors.grey200,
              AppColors.grey300,
              AppColors.grey400,
              AppColors.grey500,
              AppColors.grey600,
              AppColors.grey700,
              AppColors.grey800,
              AppColors.grey900,
              AppColors.greyWhite,
              AppColors.greyBlack,
            ],
          ),
          SizedBox(height: 24),
          ColorPalettePreview(
            name: 'Coral Reef',
            colors: [
              AppColors.coralReef50,
              AppColors.coralReef100,
              AppColors.coralReef200,
              AppColors.coralReef300,
              AppColors.coralReef400,
              AppColors.coralReef500,
              AppColors.coralReef600,
              AppColors.coralReef700,
              AppColors.coralReef800,
              AppColors.coralReef900,
            ],
          ),
          SizedBox(height: 24),
          ColorPalettePreview(
            name: 'Turquoise',
            colors: [
              AppColors.turquoise50,
              AppColors.turquoise100,
              AppColors.turquoise200,
              AppColors.turquoise300,
              AppColors.turquoise400,
              AppColors.turquoise500,
              AppColors.turquoise600,
              AppColors.turquoise700,
              AppColors.turquoise800,
              AppColors.turquoise900,
            ],
          ),
          SizedBox(height: 24),
          ColorPalettePreview(
            name: 'Rajah',
            colors: [
              AppColors.rajah50,
              AppColors.rajah100,
              AppColors.rajah200,
              AppColors.rajah300,
              AppColors.rajah400,
              AppColors.rajah500,
              AppColors.rajah600,
              AppColors.rajah700,
              AppColors.rajah800,
              AppColors.rajah900,
            ],
          ),
           SizedBox(height: 24),
          ColorPalettePreview(
            name: 'Indigo',
            colors: [
              AppColors.indigo50,
              AppColors.indigo100,
              AppColors.indigo200,
              AppColors.indigo300,
              AppColors.indigo400,
              AppColors.indigo500,
              AppColors.indigo600,
              AppColors.indigo700,
              AppColors.indigo800,
              AppColors.indigo900,
            ],
          ),
           SizedBox(height: 24),
          ColorPalettePreview(
            name: 'Blue',
            colors: [
              AppColors.blue50,
              AppColors.blue100,
              AppColors.blue200,
              AppColors.blue300,
              AppColors.blue400,
              AppColors.blue500,
              AppColors.blue600,
              AppColors.blue700,
              AppColors.blue800,
              AppColors.blue900,
            ],
          ),
           SizedBox(height: 24),
           ColorPalettePreview(
            name: 'Red',
            colors: [
              AppColors.red50,
              AppColors.red100,
              AppColors.red200,
              AppColors.red300,
              AppColors.red400,
              AppColors.red500,
              AppColors.red600,
              AppColors.red700,
              AppColors.red800,
              AppColors.red900,
            ],
          ),
           SizedBox(height: 24),
           ColorPalettePreview(
            name: 'Green',
            colors: [
              AppColors.green50,
              AppColors.green100,
              AppColors.green200,
              AppColors.green300,
              AppColors.green400,
              AppColors.green500,
              AppColors.green600,
              AppColors.green700,
              AppColors.green800,
              AppColors.green900,
            ],
          ),
        ],
      ),
    ),
  );
}
