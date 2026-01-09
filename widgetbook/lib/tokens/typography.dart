import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'typography_preview.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

@UseCase(name: 'Default', type: AppTypography)
Widget buildDesignSystemTextStylesUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ListView(
        children: [
          TypographyPreview(
            name: 'Display',
            styles: {
              'Display XXL Bold': AppTypography.displayXxlBold,
              'Display XXL Medium': AppTypography.displayXxlMedium,
              'Display XXL Light': AppTypography.displayXxlLight,
              'Display XL Bold': AppTypography.displayXlBold,
              'Display XL Medium': AppTypography.displayXlMedium,
              'Display XL Light': AppTypography.displayXlLight,
              'Display Large Bold': AppTypography.displayLargeBold,
              'Display Large Medium': AppTypography.displayLargeMedium,
              'Display Large Thin': AppTypography.displayLargeThin,
              'Display Medium Bold': AppTypography.displayMediumBold,
              'Display Medium Medium': AppTypography.displayMediumMedium,
              'Display Medium Thin': AppTypography.displayMediumThin,
              'Display Small Bold': AppTypography.displaySmallBold,
              'Display Small Medium': AppTypography.displaySmallMedium,
              'Display Small Thin': AppTypography.displaySmallThin,
            },
          ),
          const SizedBox(height: 24),
          TypographyPreview(
            name: 'Headline',
            styles: {
              'Headline XL Bold': AppTypography.headlineXlBold,
              'Headline XL Medium': AppTypography.headlineXlMedium,
              'Headline XL Thin': AppTypography.headlineXlThin,
              'Headline Large Bold': AppTypography.headlineLargeBold,
              'Headline Large Medium': AppTypography.headlineLargeMedium,
              'Headline Large Thin': AppTypography.headlineLargeThin,
              'Headline Medium Bold': AppTypography.headlineMediumBold,
              'Headline Medium Medium': AppTypography.headlineMediumMedium,
              'Headline Medium Thin': AppTypography.headlineMediumThin,
              'Headline Small Bold': AppTypography.headlineSmallBold,
              'Headline Small Medium': AppTypography.headlineSmallMedium,
              'Headline Small Thin': AppTypography.headlineSmallThin,
            },
          ),
          const SizedBox(height: 24),
          TypographyPreview(
            name: 'Text',
            styles: {
              'Text XL Bold': AppTypography.textXlBold,
              'Text XL Medium': AppTypography.textXlMedium,
              'Text XL Thin': AppTypography.textXlThin,
              'Text Large Bold': AppTypography.textLargeBold,
              'Text Large Medium': AppTypography.textLargeMedium,
              'Text Large Thin': AppTypography.textLargeThin,
              'Text Medium Bold': AppTypography.textMediumBold,
              'Text Medium Medium': AppTypography.textMediumMedium,
              'Text Medium Thin': AppTypography.textMediumThin,
              'Text Small Bold': AppTypography.textSmallBold,
              'Text Small Medium': AppTypography.textSmallMedium,
              'Text Small Thin': AppTypography.textSmallThin,
              'Text Extra Small Bold': AppTypography.textExtraSmallBold,
              'Text Extra Small Medium': AppTypography.textExtraSmallMedium,
              'Text Extra Small Thin': AppTypography.textExtraSmallThin,
            },
          ),
          const SizedBox(height: 24),
          TypographyPreview(
            name: 'Banner',
            styles: {
              'Banner L Medium': AppTypography.bannerLMedium,
              'Banner M Medium': AppTypography.bannerMMedium,
            },
          ),
          const SizedBox(height: 24),
          TypographyPreview(
            name: 'Meta',
            styles: {'Meta Title': AppTypography.metaTitle},
          ),
        ],
      ),
    ),
  );
}
