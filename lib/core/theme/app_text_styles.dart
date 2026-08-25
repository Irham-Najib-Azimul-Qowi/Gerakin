import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistem tipografi GERAKIN Inclusive Motion Design System (Plus Jakarta Sans).
///
/// Mengikuti skala tipografi DESIGN.md:
/// - Display: Bold (32px+)
/// - Heading: SemiBold (20px - 24px)
/// - Body Large: Medium (18px)
/// - Body Medium: Regular (16px)
/// - Caption: Regular (12px - 14px)
class AppTextStyles {
  AppTextStyles._();

  static String? get _fontFamily =>
      GoogleFonts.plusJakartaSans().fontFamily;

  // ── Display (Bold, 32px+) ────────────────────────────────
  static TextStyle get displayLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
        height: 1.15,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displaySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  // ── Heading / Headline (SemiBold, 20px - 24px) ───────────
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  // ── Title (SemiBold, 16px - 22px) ────────────────────────
  static TextStyle get titleLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ── Body Large (Medium, 18px) & Medium (Regular, 16px) ───
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: AppColors.textSecondary,
        height: 1.45,
      );

  // ── Caption (Regular, 12px - 14px) ───────────────────────
  static TextStyle get captionLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get captionMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get captionSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
        height: 1.35,
      );

  // ── Label (Medium / SemiBold) ────────────────────────────
  static TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: AppColors.textSecondary,
        height: 1.35,
      );

  /// Membuat [TextTheme] Material 3 dari style di atas.
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
