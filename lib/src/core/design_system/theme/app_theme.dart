import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sparksocial/src/core/design_system/theme/color_scheme.dart';
import 'package:sparksocial/src/core/design_system/theme/text_theme.dart';
import 'package:sparksocial/src/core/design_system/tokens/borders.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/spacing.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.light,
      textTheme: AppTextTheme.light,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(64, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelLarge,
          side: const BorderSide(
            color: AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(64, 40),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.borderFocus,
            width: AppBorders.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.borderError,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.borderError,
            width: AppBorders.borderWidthMedium,
          ),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.neutral500,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shadowColor: AppColors.shadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.cardRadius,
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.dialogRadius,
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.onSurface,
        ),
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusSm),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: AppTypography.titleSmall,
        unselectedLabelStyle: AppTypography.titleSmall,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppBorders.borderWidthMedium,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.neutral300;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        side: const BorderSide(
          color: AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusXs),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.neutral300,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withAlpha(31),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.dark,
      textTheme: AppTextTheme.dark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral800,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.surface,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.surface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.neutral900,
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(64, 40),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTypography.labelLarge,
          side: const BorderSide(
            color: AppColors.primaryLight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(64, 40),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.neutral600,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.neutral600,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: AppBorders.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.errorLight,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorders.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.errorLight,
            width: AppBorders.borderWidthMedium,
          ),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.neutral200,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.neutral500,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.errorLight,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.neutral800,
        shadowColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.cardRadius,
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.neutral900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.neutral800,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.dialogRadius,
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.surface,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.surface,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral700,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.surface,
        ),
        side: const BorderSide(
          color: AppColors.neutral600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.surface,
        ),
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.neutral200,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusSm),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.neutral800,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.neutral400,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.neutral400,
        labelStyle: AppTypography.titleSmall,
        unselectedLabelStyle: AppTypography.titleSmall,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: AppBorders.borderWidthMedium,
          ),
        ),
      ),
    );
  }
}
