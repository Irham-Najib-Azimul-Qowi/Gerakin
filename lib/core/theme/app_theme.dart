import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Tema aplikasi GERAKIN – Inclusive Motion Design System (Material 3).
///
/// Mengikuti spesifikasi DESIGN.md:
/// - Primary: Purple (#7C5CFC)
/// - Secondary: Sky Blue (#5EC8FF)
/// - Accent: Mint (#7AE7C7)
/// - Background: #F8FAFC
/// - Surface / Card: #FFFFFF (24px radius, soft shadow)
/// - Text Primary: #1E293B, Text Secondary: #64748B
/// - Buttons: 24px radius, min 48px touch target
class AppTheme {
  AppTheme._();

  // ── Light Theme (Default) ────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceVariant,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.border,
          outlineVariant: AppColors.outlineVariant,
          shadow: AppColors.shadow,
          scrim: AppColors.scrim,
          inverseSurface: AppColors.inverseSurface,
          onInverseSurface: AppColors.onInverseSurface,
          inversePrimary: AppColors.inversePrimary,
        ),
        textTheme: AppTextStyles.textTheme,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryContainer,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(color: AppColors.textSecondary, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.captionSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              );
            }
            return AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            );
          }),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXxl,
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusXxl,
            ),
            textStyle: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            elevation: 0,
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusXxl,
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            textStyle: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            textStyle: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          disabledColor: AppColors.disabledBackground,
          selectedColor: AppColors.primaryContainer,
          secondarySelectedColor: AppColors.secondaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusSm, // 8px for chips
            side: const BorderSide(color: AppColors.border),
          ),
          labelStyle: AppTextStyles.captionMedium.copyWith(color: AppColors.textPrimary),
          secondaryLabelStyle: AppTextStyles.captionMedium.copyWith(color: AppColors.primary),
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: AppSpacing.paddingAllLg,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusXxl,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusXxl,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusXxl,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusXxl,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusXxl,
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral400),
          errorStyle: AppTextStyles.captionSmall.copyWith(color: AppColors.error),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      );

  // ── Dark Theme ───────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.surfaceDark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.onPrimaryContainer,
          onPrimaryContainer: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.onSecondaryContainer,
          onSecondaryContainer: AppColors.secondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.onTertiaryContainer,
          onTertiaryContainer: AppColors.tertiaryContainer,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.onErrorContainer,
          onErrorContainer: AppColors.errorContainer,
          surface: AppColors.surfaceContainerDark,
          onSurface: AppColors.onSurfaceDark,
          surfaceContainerHighest: AppColors.surfaceVariantDark,
          onSurfaceVariant: AppColors.onSurfaceVariantDark,
          outline: AppColors.outlineDark,
          outlineVariant: AppColors.outlineVariantDark,
          shadow: AppColors.shadow,
          scrim: AppColors.scrim,
          inverseSurface: AppColors.onSurfaceDark,
          onInverseSurface: AppColors.surfaceDark,
          inversePrimary: AppColors.primaryDark,
        ),
        textTheme: AppTextStyles.textTheme,
      );
}
